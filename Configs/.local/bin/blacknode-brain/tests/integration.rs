//! Integration test: feed synthetic events through the predictor and verify
//! the engine learns (focus intensity rises under focus events).

use blacknode_brain::capture::Event;
use blacknode_brain::predictor::Predictor;
use blacknode_brain::storage::EventLog;

#[test]
fn predictor_rises_under_focus() {
    let mut p = Predictor::new();
    let log = EventLog::with_capacity(256);
    let now = 1_000_000;

    for i in 0..20 {
        let e = Event::new("focus", "1");
        // re-create a fresh log each ingest like the scheduler does
        let mut tmp = EventLog::with_capacity(256);
        tmp.push(e);
        p.ingest(&tmp.iter().next().unwrap().clone(), &log, now + i * 1000);
    }
    let pred = p.predict();
    assert!(pred.focus_intensity > 0.5, "expected high focus, got {}", pred.focus_intensity);
}

#[test]
fn predictor_anomaly_quiet() {
    let mut p = Predictor::new();
    let log = EventLog::with_capacity(256);
    for i in 0..30 {
        let e = Event::new("window", "kitty");
        let mut tmp = EventLog::with_capacity(256);
        tmp.push(e);
        p.ingest(&tmp.iter().next().unwrap().clone(), &log, 1000 + i * 2000);
    }
    let pred = p.predict();
    assert!(pred.anomaly >= 0.0 && pred.anomaly <= 1.0);
}
