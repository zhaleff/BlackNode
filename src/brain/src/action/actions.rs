//! Concrete action implementations. Each maps a `Decision` to a real desktop
//! effect via a system command.

use crate::action::Action;
use crate::bus::Decision;
use std::process::Command;

fn run(cmd: &str, args: &[&str]) {
    let _ = Command::new(cmd).args(args).status();
}

/// Pause (enable) Do-Not-Disturb via dunst.
pub struct EnableDnd;
impl Action for EnableDnd {
    fn name(&self) -> &str {
        "EnableDND"
    }
    fn execute(&self, _: &Decision) {
        run("dunstctl", &["set-paused", "true"]);
    }
}

/// Resume notifications (disable DND) via dunst.
pub struct DisableDnd;
impl Action for DisableDnd {
    fn name(&self) -> &str {
        "DisableDND"
    }
    fn execute(&self, _: &Decision) {
        run("dunstctl", &["set-paused", "false"]);
    }
}

/// Set the power profile (power-profiles-daemon).
pub struct PowerProfile;
impl Action for PowerProfile {
    fn name(&self) -> &str {
        "PowerProfile"
    }
    fn execute(&self, dec: &Decision) {
        if let Some(p) = dec.params.get("profile") {
            run("powerprofilesctl", &["set", p]);
        }
    }
}

/// Change the wallpaper via swww.
pub struct Wallpaper;
impl Action for Wallpaper {
    fn name(&self) -> &str {
        "Wallpaper"
    }
    fn execute(&self, dec: &Decision) {
        if let Some(w) = dec.params.get("wallpaper") {
            run("swww", &["img", w]);
        }
    }
}

/// Adjust brightness via brightnessctl.
pub struct Brightness;
impl Action for Brightness {
    fn name(&self) -> &str {
        "Brightness"
    }
    fn execute(&self, dec: &Decision) {
        if let Some(b) = dec.params.get("level") {
            run("brightnessctl", &["set", b]);
        }
    }
}

/// Suggest (and switch) a BlackNode profile via profiles.sh.
pub struct ProfileSuggest;
impl Action for ProfileSuggest {
    fn name(&self) -> &str {
        "ProfileSuggest"
    }
    fn execute(&self, dec: &Decision) {
        if let Some(p) = dec.params.get("profile") {
            run("profiles.sh", &["set", p]);
        }
    }
}

/// Plain desktop notification carrying the reason chain.
pub struct Notify;
impl Action for Notify {
    fn name(&self) -> &str {
        "Notify"
    }
    fn execute(&self, dec: &Decision) {
        let reason = dec.reason.join("; ");
        run("notify-send", &["BlackNode", &reason]);
    }
}

/// Rewrite the dynamic HUD file consumed by the waybar module.
pub struct ChangeHud;
impl Action for ChangeHud {
    fn name(&self) -> &str {
        "ChangeHUD"
    }
    fn execute(&self, dec: &Decision) {
        if let Some(hud) = dec.params.get("hud") {
            let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
            let path = std::path::Path::new(&home).join(".local/share/blacknode/brain/hud.json");
            let _ = std::fs::write(&path, hud);
        }
    }
}
