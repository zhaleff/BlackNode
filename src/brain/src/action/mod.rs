//! Action trait + concrete desktop actions.
//!
//! An `Action` takes a `Decision` and does something real on the desktop:
//! toggle DND, change the wallpaper, set power profile, rewrite the HUD, etc.
//! Every action is a thin wrapper around a system command so the brain's
//! effect is observable, not just a notification.

use crate::bus::Decision;

pub trait Action: Send + Sync + 'static {
    fn name(&self) -> &str;
    fn execute(&self, dec: &Decision);
}

mod actions;
pub use actions::*;

use crate::config::Config;

/// Build the enabled action set from config.
pub fn register(config: &Config) -> Vec<Box<dyn Action>> {
    let mut out: Vec<Box<dyn Action>> = Vec::new();
    if config.action_on("EnableDND") {
        out.push(Box::new(EnableDnd));
    }
    if config.action_on("DisableDND") {
        out.push(Box::new(DisableDnd));
    }
    if config.action_on("PowerProfile") {
        out.push(Box::new(PowerProfile));
    }
    if config.action_on("Wallpaper") {
        out.push(Box::new(Wallpaper));
    }
    if config.action_on("Brightness") {
        out.push(Box::new(Brightness));
    }
    if config.action_on("ProfileSuggest") {
        out.push(Box::new(ProfileSuggest));
    }
    if config.action_on("Notify") {
        out.push(Box::new(Notify));
    }
    if config.action_on("ChangeHUD") {
        out.push(Box::new(ChangeHud));
    }
    out
}
