//! Long-term memory: the brain's durable, self-evolving knowledge.
//!
//! Every observation is stored with a timestamp. On read, counts are decayed
//! by age using an exponential half-life, so habits the user no longer
//! repeats fade away on their own. This is what makes the brain learn over
//! time instead of freezing its first impression of you.

pub mod model;
pub mod store;

pub use store::Memory;
