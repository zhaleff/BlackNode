# BlackNode Brain

Local intelligence engine. Learns only from data on this machine. No external
models, no network calls, no uploads. All state lives under
`~/.local/share/blacknode/brain/`.

## Design

The engine is a pipeline:

```
capture (events) → features (sliding windows) → algorithms (incremental models)
                                             → predictor (orchestrates) → scheduler (loop)
                                             → api (plugins act on predictions)
```

Each stage is behind a trait so it can be swapped without touching the rest:

- `capture::CaptureSource` — event producers (hyprland, stdin, synthetic).
- `features::FeatureExtractor` — raw events → fixed feature vectors.
- `algorithms::Model` — incremental learners (EWMA, Markov, Bayes, KMeans, Anomaly).
- `api::EngineApi` — plugins that act on `Prediction` via `ActionSink`.

## Algorithms (and why)

All are incremental (one sample at a time), fixed-memory, and local.

| Algorithm | Role | Update | Memory |
|-----------|------|--------|--------|
| EWMA | smooth noisy focus signal | O(1) | O(1) |
| Markov chain | predict next app from transitions | O(1) | O(s²) |
| Bayes update | belief over focus/browse/idle | O(h) | O(h) |
| KMeans (online) | behavioral segmentation | O(k·d) | O(k·d) |
| Anomaly (Welford) | flag rare deviations | O(1) | O(1) |

Justification per algorithm is in the module docs (`src/algorithms/mod.rs`).

## Memory & privacy

- Event log is capacity-bounded (ring buffer, default 4096). Old events drop.
- Model state is fixed-size; persisted atomically (temp file + rename) so a
  crash mid-write never corrupts on-disk state.
- Behavioral data never leaves the machine.

## Build & install

```sh
cargo build --release
install -Dm755 target/release/blacknode-brain ~/.local/bin/blacknode-brain
```

## Run

```sh
# live: capture from hyprland
blacknode-brain

# debug: feed synthetic events from stdin ("kind value" per line)
echo -e "window kitty\nfocus 1\nwindow firefox\ndistract 1" | blacknode-brain --stdin
```

## Plugins

Implement `api::EngineApi` and register it in `main.rs`. The `first_of_kind`
callback lets a plugin act once per key (e.g. once per day), preventing spam.
No core module needs to change to add a new behavior.

## Tests

```sh
cargo test
```

Covers EWMA smoothing, Bayes favoring observed hypotheses, Markov transitions,
KMeans separation, Anomaly deviation detection, bounded event log, atomic
write round-trip, feature extraction, and end-to-end predictor behavior.
