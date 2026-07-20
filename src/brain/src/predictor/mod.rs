//! Predictor: orchestrates the algorithm ensemble.
//!
//! Maps incoming events into per-algorithm signals and runs incremental
//! updates. Exposes a consolidated [`Prediction`] used by the API/scheduler
//! to drive system behavior (e.g. suggest focus, shift ambient).
//!
//! The predictor owns the models behind the [`Model`] trait, so any algorithm
//! can be swapped without changing this module.

use crate::algorithms::{Anomaly, Bayes, Ewma, KMeans, Markov, Model, ModelState};
use crate::capture::Event;
use crate::features::{window_events, DefaultExtractor, FeatureExtractor, Features};
use crate::storage::EventLog;

pub struct Predictor {
    ewma: Ewma,
    markov: Markov,
    bayes: Bayes,
    kmeans: KMeans,
    anomaly: Anomaly,
    extractor: DefaultExtractor,
    last_window_class: Option<String>,
}

#[derive(Debug, Clone, Default)]
pub struct Prediction {
    /// Smoothed focus intensity in [0,1].
    pub focus_intensity: f64,
    /// Anomaly score in [0,1] (higher = more unusual).
    pub anomaly: f64,
    /// Probability the user is in `focus` mode (Bayes).
    pub focus_belief: f64,
    /// Dominant behavioral cluster index.
    pub cluster: usize,
    /// Next predicted app class from Markov (None if untrained).
    pub next_app: Option<String>,
}

impl Predictor {
    pub fn new() -> Self {
        Predictor {
            ewma: Ewma::new(0.1),
            markov: Markov::new(),
            bayes: Bayes::new(&["focus", "browse", "idle"], 0.995),
            kmeans: KMeans::new(3, 4, &[0.2, 0.8, 0.5, 0.1, 0.9, 0.3, 0.6, 0.4, 0.7, 0.2, 0.4, 0.8]),
            anomaly: Anomaly::new(),
            extractor: DefaultExtractor,
            last_window_class: None,
        }
    }

    /// Feed one event. Splits it into the signals each model expects, then
    /// runs incremental updates. O(1)-O(k*d) depending on model.
    pub fn ingest(&mut self, e: &Event, log: &EventLog, now: u64) {
        let feats: Features = {
            let evs = window_events(log, 60_000, now);
            self.extractor.extract(&evs)
        };

        // EWMA on focus intensity: from focus events + low distraction.
        let focus_signal = if e.kind == "focus" {
            1.0
        } else if e.kind == "distract" {
            0.0
        } else {
            feats.by_kind.get("focus").copied().unwrap_or(0.0) * 0.1
        };
        self.ewma.update(&[focus_signal]);

        // Bayes: observe focus/browse/idle based on event kind.
        let (hyp, lh) = match e.kind.as_str() {
            "focus" => ("focus", 0.9),
            "distract" => ("browse", 0.8),
            "window" => ("browse", 0.3),
            "session" => ("idle", 0.4),
            _ => ("idle", 0.2),
        };
        let keys: Vec<String> = self.bayes.belief.keys().cloned().collect();
        if let Some(i) = keys.iter().position(|k| k == hyp) {
            self.bayes.update(&[i as f64, lh]);
        }

        // Markov: transition between consecutive window classes.
        if e.kind == "window" {
            let prev = self.last_window_class.clone();
            if let Some(prev) = prev {
                let fi = self.markov.register(&prev);
                let ti = self.markov.register(&e.value);
                self.markov.update(&[fi as f64, ti as f64]);
            }
            self.last_window_class = Some(e.value.clone());
        }

        // KMeans: feature vector [count, focus, browse, distract].
        let fvec = vec![
            feats.count / 100.0,
            feats.by_kind.get("focus").copied().unwrap_or(0.0) / 10.0,
            feats.by_kind.get("window").copied().unwrap_or(0.0) / 10.0,
            feats.by_kind.get("distract").copied().unwrap_or(0.0) / 10.0,
        ];
        self.kmeans.update(&fvec);

        // Anomaly on event rate (events per minute normalized).
        let rate = feats.count;
        self.anomaly.update(&[rate]);
    }

    pub fn predict(&self) -> Prediction {
        let mut p = Prediction::default();
        p.focus_intensity = self.ewma.predict();
        p.anomaly = self.anomaly.predict();
        p.focus_belief = self.bayes.prob("focus");
        p.cluster = self.kmeans.assign(&[
            self.ewma.predict(),
            self.bayes.prob("focus"),
            self.bayes.prob("browse"),
            self.bayes.prob("idle"),
        ]);
        p.next_app = self.last_window_class.clone();
        p
    }

    pub fn save(&self, dir: &std::path::PathBuf) {
        use crate::storage::atomic_write;
        let _ = atomic_write(&dir.join("ewma.json"), &self.ewma.save_state());
        let _ = atomic_write(&dir.join("markov.json"), &self.markov.save_state());
        let _ = atomic_write(&dir.join("bayes.json"), &self.bayes.save_state());
        let _ = atomic_write(&dir.join("kmeans.json"), &self.kmeans.save_state());
        let _ = atomic_write(&dir.join("anomaly.json"), &self.anomaly.save_state());
    }

    pub fn load(&mut self, dir: &std::path::PathBuf) {
        use crate::storage::read_json;
        if let Some(s) = read_json::<ModelState>(&dir.join("ewma.json")) {
            self.ewma.load_state(&s);
        }
        if let Some(s) = read_json::<ModelState>(&dir.join("markov.json")) {
            self.markov.load_state(&s);
        }
        if let Some(s) = read_json::<ModelState>(&dir.join("bayes.json")) {
            self.bayes.load_state(&s);
        }
        if let Some(s) = read_json::<ModelState>(&dir.join("kmeans.json")) {
            self.kmeans.load_state(&s);
        }
        if let Some(s) = read_json::<ModelState>(&dir.join("anomaly.json")) {
            self.anomaly.load_state(&s);
        }
    }
}
