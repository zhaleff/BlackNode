//! Learning algorithms. All are incremental (one sample at a time), local,
//! and behind the [`Model`] trait so they are swappable without core changes.
//!
//! Each algorithm documents its justification and time complexity.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// A model consumes a feature vector (or scalar signal) and updates its
/// internal state incrementally. `predict` returns a normalized score in
/// [0,1] for downstream decision making.
pub trait Model: Send {
    fn update(&mut self, x: &[f64]);
    fn predict(&self) -> f64;
    fn save_state(&self) -> ModelState;
    fn load_state(&mut self, s: &ModelState);
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ModelState {
    Ewma(f64),
    Markov(HashMap<String, HashMap<String, f64>>, Vec<String>),
    Bayes(HashMap<String, f64>, f64),
    Cluster(Vec<Vec<f64>>, Vec<f64>),
    Anomaly(f64, f64),
}

// ---------------------------------------------------------------------------
// EWMA — Exponentially Weighted Moving Average
// ---------------------------------------------------------------------------
/// Justification: smooths a noisy scalar signal (e.g. focus intensity) so
/// short spikes don't dominate. Standard for streaming rate estimation.
/// Update: O(1). Predict: O(1). Memory: O(1).
pub struct Ewma {
    pub alpha: f64,
    pub value: f64,
}

impl Ewma {
    pub fn new(alpha: f64) -> Self {
        Ewma { alpha, value: 0.0 }
    }
}

impl Model for Ewma {
    fn update(&mut self, x: &[f64]) {
        if let Some(v) = x.first() {
            self.value = self.alpha * v + (1.0 - self.alpha) * self.value;
        }
    }
    fn predict(&self) -> f64 {
        self.value.clamp(0.0, 1.0)
    }
    fn save_state(&self) -> ModelState {
        ModelState::Ewma(self.value)
    }
    fn load_state(&mut self, s: &ModelState) {
        if let ModelState::Ewma(v) = s {
            self.value = *v;
        }
    }
}

// ---------------------------------------------------------------------------
// Markov chain — transition prediction over discrete states
// ---------------------------------------------------------------------------
/// Justification: user behavior is sequential (app A -> app B). A first-order
/// Markov chain captures transition likelihoods and predicts the next state.
/// Update: O(1) (one map lookup + insert). Predict: O(k) over outgoing states.
/// Memory: O(s^2) states, s = vocabulary size (bounded by noise filter).
pub struct Markov {
    pub transitions: HashMap<String, HashMap<String, f64>>,
    pub vocab: Vec<String>,
}

impl Markov {
    pub fn new() -> Self {
        Markov {
            transitions: HashMap::new(),
            vocab: Vec::new(),
        }
    }
    /// Register a state name, returning its stable vocab index. The predictor
    /// must call this before `update` so transitions are keyed by name.
    pub fn register(&mut self, s: &str) -> usize {
        if let Some(i) = self.vocab.iter().position(|v| v == s) {
            i
        } else {
            self.vocab.push(s.to_string());
            self.vocab.len() - 1
        }
    }
}

impl Model for Markov {
    fn update(&mut self, x: &[f64]) {
        // x encodes [from_idx, to_idx]; the predictor maps app names -> vocab
        // indices before calling, registering them via `markov_idx`.
        if x.len() < 2 {
            return;
        }
        let from = x[0] as usize;
        let to = x[1] as usize;
        let fk = self
            .vocab
            .get(from)
            .cloned()
            .unwrap_or_else(|| format!("s{from}"));
        let tk = self
            .vocab
            .get(to)
            .cloned()
            .unwrap_or_else(|| format!("s{to}"));
        let entry = self.transitions.entry(fk).or_default();
        *entry.entry(tk).or_insert(0.0) += 1.0;
    }
    fn predict(&self) -> f64 {
        let connected = self
            .transitions
            .values()
            .filter(|m| m.values().sum::<f64>() > 0.0)
            .count() as f64;
        connected / self.transitions.len().max(1) as f64
    }
    fn save_state(&self) -> ModelState {
        ModelState::Markov(self.transitions.clone(), self.vocab.clone())
    }
    fn load_state(&mut self, s: &ModelState) {
        if let ModelState::Markov(t, v) = s {
            self.transitions = t.clone();
            self.vocab = v.clone();
        }
    }
}

// ---------------------------------------------------------------------------
// Bayesian update — belief over discrete hypotheses
// ---------------------------------------------------------------------------
/// Justification: maintain a belief distribution over hypotheses (e.g. is the
// user in a "focus" mode?). Each observation updates priors via Bayes rule
/// with a fixed likelihood. Robust to sparse data, naturally forgets old
/// evidence through prior decay.
/// Update: O(h) hypotheses. Predict: O(h). Memory: O(h).
pub struct Bayes {
    pub belief: HashMap<String, f64>,
    pub prior_decay: f64,
    pub total: f64,
}

impl Bayes {
    pub fn new(hypotheses: &[&str], prior_decay: f64) -> Self {
        let mut belief = HashMap::new();
        for h in hypotheses {
            belief.insert(h.to_string(), 1.0);
        }
        Bayes {
            belief,
            prior_decay,
            total: hypotheses.len() as f64,
        }
    }
    /// Update belief that `hyp` produced the observation with likelihood `lh`.
    pub fn observe(&mut self, hyp: &str, lh: f64) {
        self.total *= self.prior_decay;
        self.total += 1.0;
        if let Some(b) = self.belief.get_mut(hyp) {
            *b = *b * self.prior_decay + lh;
        }
    }
    pub fn prob(&self, hyp: &str) -> f64 {
        let raw = self.belief.get(hyp).copied().unwrap_or(0.0);
        if self.total > 0.0 {
            raw / self.total
        } else {
            0.0
        }
    }
}

impl Model for Bayes {
    fn update(&mut self, x: &[f64]) {
        // x[0] = hypothesis index, x[1] = likelihood
        if x.len() < 2 {
            return;
        }
        let keys: Vec<String> = self.belief.keys().cloned().collect();
        if let Some(h) = keys.get(x[0] as usize) {
            self.observe(&h, x[1]);
        }
    }
    fn predict(&self) -> f64 {
        self.belief
            .values()
            .map(|v| *v)
            .fold(0.0_f64, f64::max)
            / self.total.max(1.0)
    }
    fn save_state(&self) -> ModelState {
        ModelState::Bayes(self.belief.clone(), self.total)
    }
    fn load_state(&mut self, s: &ModelState) {
        if let ModelState::Bayes(b, t) = s {
            self.belief = b.clone();
            self.total = *t;
        }
    }
}

// ---------------------------------------------------------------------------
// KMeans clustering (online, fixed clusters) — behavioral segmentation
// ---------------------------------------------------------------------------
/// Justification: group feature vectors into stable behavioral modes
/// (e.g. "deep work", "browsing", "idle"). Online Lloyd with fixed k and
/// running centroid sums. Segmentation enables per-mode adaptation.
/// Update: O(k*d) per sample. Predict (assign): O(k*d). Memory: O(k*d).
pub struct KMeans {
    pub centroids: Vec<Vec<f64>>,
    pub counts: Vec<f64>,
    pub dims: usize,
}

impl KMeans {
    pub fn new(k: usize, dims: usize, seed: &[f64]) -> Self {
        let n = seed.len().max(1);
        let mut centroids = Vec::with_capacity(k);
        for i in 0..k {
            // Deterministic spread: each cluster gets a distinct "anchor"
            // dimension, seeded high there and low elsewhere, so initial
            // centroids are well separated regardless of input scale.
            let anchor = i % dims;
            let c: Vec<f64> = (0..dims)
                .map(|j| {
                    let base = seed[(i * dims + j) % n];
                    if j == anchor { base.max(0.8) } else { base.min(0.2) }
                })
                .collect();
            centroids.push(c);
        }
        KMeans {
            centroids,
            counts: vec![0.0; k],
            dims,
        }
    }
    pub fn assign(&self, x: &[f64]) -> usize {
        let mut best = 0;
        let mut best_d = f64::MAX;
        for (i, c) in self.centroids.iter().enumerate() {
            let d = sq_dist(x, c);
            if d < best_d {
                best_d = d;
                best = i;
            }
        }
        best
    }
}

impl Model for KMeans {
    fn update(&mut self, x: &[f64]) {
        if x.len() != self.dims {
            return;
        }
        let i = self.assign(x);
        self.counts[i] += 1.0;
        let lr = 0.05;
        for j in 0..self.dims {
            self.centroids[i][j] += lr * (x[j] - self.centroids[i][j]);
        }
    }
    fn predict(&self) -> f64 {
        // Score = cohesion of the most populated cluster (lower variance).
        let max_c = self.counts.iter().cloned().fold(0.0_f64, f64::max);
        (max_c / self.counts.iter().cloned().sum::<f64>().max(1.0)).clamp(0.0, 1.0)
    }
    fn save_state(&self) -> ModelState {
        ModelState::Cluster(self.centroids.clone(), self.counts.clone())
    }
    fn load_state(&mut self, s: &ModelState) {
        if let ModelState::Cluster(c, n) = s {
            self.centroids = c.clone();
            self.counts = n.clone();
        }
    }
}

// ---------------------------------------------------------------------------
// Anomaly detection — EWMA-based z-score on a scalar signal
// ---------------------------------------------------------------------------
/// Justification: flag rare deviations (e.g. sudden distraction burst, or a
/// session far from the user's norm). Uses running mean + variance (Welford)
/// so it is O(1) per sample and never stores the full history.
/// Update: O(1). Predict (anomaly score): O(1). Memory: O(1).
pub struct Anomaly {
    pub mean: f64,
    pub m2: f64,
    pub n: f64,
    pub last: f64,
}

impl Anomaly {
    pub fn new() -> Self {
        Anomaly {
            mean: 0.0,
            m2: 0.0,
            n: 0.0,
            last: 0.0,
        }
    }
    /// Returns a z-score-like anomaly score for `x`.
    pub fn score(&self, x: f64) -> f64 {
        if self.n < 2.0 {
            return 0.0;
        }
        let var = self.m2 / (self.n - 1.0);
        if var <= 0.0 {
            return 0.0;
        }
        ((x - self.mean) / var.sqrt()).abs()
    }
}

impl Model for Anomaly {
    fn update(&mut self, x: &[f64]) {
        if let Some(v) = x.first() {
            self.n += 1.0;
            let delta = v - self.mean;
            self.mean += delta / self.n;
            self.m2 += delta * (v - self.mean);
            self.last = *v;
        }
    }
    fn predict(&self) -> f64 {
        // Normalize z-score to [0,1] with a soft sigmoid on |z|.
        let z = self.score(self.last);
        (1.0 - (-z / 3.0).exp()).clamp(0.0, 1.0)
    }
    fn save_state(&self) -> ModelState {
        ModelState::Anomaly(self.mean, self.m2)
    }
    fn load_state(&mut self, s: &ModelState) {
        if let ModelState::Anomaly(m, v) = s {
            self.mean = *m;
            self.m2 = *v;
        }
    }
}

fn sq_dist(a: &[f64], b: &[f64]) -> f64 {
    a.iter()
        .zip(b.iter())
        .map(|(x, y)| (x - y) * (x - y))
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ewma_smooths() {
        let mut m = Ewma::new(0.5);
        m.update(&[1.0]);
        m.update(&[0.0]);
        let v = m.predict();
        assert!(v > 0.0 && v < 1.0);
    }

    #[test]
    fn ewma_state_roundtrip() {
        let mut m = Ewma::new(0.3);
        m.update(&[0.8]);
        let s = m.save_state();
        let mut m2 = Ewma::new(0.3);
        m2.load_state(&s);
        assert_eq!(m.predict(), m2.predict());
    }

    #[test]
    fn bayes_favors_observed() {
        let mut b = Bayes::new(&["a", "b"], 0.9);
        b.observe("a", 0.9);
        b.observe("a", 0.9);
        assert!(b.prob("a") > b.prob("b"));
    }

    #[test]
    fn anomaly_flags_deviation() {
        let mut a = Anomaly::new();
        for v in [0.4, 0.5, 0.6, 0.5, 0.4, 0.5, 0.6, 0.5, 0.4, 0.5] {
            a.update(&[v]);
        }
        assert!(a.score(0.5) < a.score(3.0));
    }

    #[test]
    fn kmeans_assigns_stable() {
        let mut k = KMeans::new(2, 2, &[0.0, 1.0, 1.0, 0.0]);
        k.update(&[0.1, 0.1]);
        k.update(&[0.9, 0.9]);
        let c1 = k.assign(&[0.1, 0.1]);
        let c2 = k.assign(&[0.9, 0.9]);
        assert_ne!(c1, c2);
    }

    #[test]
    fn markov_learns_transition() {
        let mut m = Markov::new();
        let _ = m.register("a");
        let _ = m.register("b");
        m.update(&[0.0, 1.0]);
        m.update(&[0.0, 1.0]);
        let out = m.transitions.get("a").unwrap();
        assert!(out.get("b").copied().unwrap_or(0.0) >= 2.0);
    }
}
