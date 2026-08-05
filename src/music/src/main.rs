use std::collections::HashMap;
use std::env;
use std::process::{Command, Stdio};

fn playerctl(args: &[&str]) -> Option<String> {
    Command::new("playerctl")
        .args(args)
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .output()
        .ok()
        .and_then(|o| {
            let s = String::from_utf8_lossy(&o.stdout).trim().to_string();
            if s.is_empty() { None } else { Some(s) }
        })
}

fn active_player() -> Option<String> {
    let players = playerctl(&["-l"])?;
    let players: Vec<&str> = players.lines().filter(|l| !l.is_empty()).collect();
    if players.is_empty() { return None; }
    for p in &players {
        if let Some(s) = playerctl(&["--player", p, "status"]) {
            if s.trim() == "Playing" { return Some(p.to_string()); }
        }
    }
    Some(players[0].to_string())
}

fn collect_meta(player: &str) -> Option<HashMap<String, String>> {
    let fmt = "{{title}}|||{{artist}}|||{{album}}|||{{duration(position)}}|||{{duration(mpris:length)}}|||{{status}}|||{{mpris:artUrl}}|||{{playerName}}";
    let out = playerctl(&["--player", player, "metadata", "--format", fmt])?;
    let parts: Vec<&str> = out.split("|||").collect();
    if parts.len() < 3 { return None; }
    let mut m = HashMap::new();
    m.insert("title".into(), parts[0].to_string());
    m.insert("artist".into(), parts.get(1).unwrap_or(&"").to_string());
    m.insert("album".into(), parts.get(2).unwrap_or(&"").to_string());
    m.insert("position".into(), parts.get(3).unwrap_or(&"").to_string());
    m.insert("length".into(), parts.get(4).unwrap_or(&"").to_string());
    m.insert("status".into(), parts.get(5).unwrap_or(&"").to_string());
    m.insert("artUrl".into(), parts.get(6).unwrap_or(&"").to_string());
    m.insert("playerName".into(), parts.get(7).unwrap_or(&"").to_string());
    Some(m)
}

fn player_icon(name: &str) -> &'static str {
    let n = name.to_lowercase();
    if n.contains("spotify") { "\u{f04c7}" }
    else if n.contains("firefox") || n.contains("browser") || n.contains("chromium") { "\u{f05c3}" }
    else if n.contains("vlc") { "\u{f05d7}" }
    else { "\u{f075a}" }
}

fn show() {
    let player = match active_player() {
        Some(p) => p,
        None => {
            let out = serde_json::json!({
                "text": "\u{f075a}  No music",
                "tooltip": "No music playing",
                "class": "stopped",
                "alt": "stopped",
            });
            println!("{}", serde_json::to_string(&out).unwrap());
            return;
        }
    };

    let meta = match collect_meta(&player) {
        Some(m) => m,
        None => {
            let out = serde_json::json!({
                "text": "\u{f075a}  No music",
                "tooltip": "No music playing",
                "class": "stopped",
                "alt": "stopped",
            });
            println!("{}", serde_json::to_string(&out).unwrap());
            return;
        }
    };

    let title = meta.get("title").map(|s| s.as_str()).unwrap_or("");
    let artist = meta.get("artist").map(|s| s.as_str()).unwrap_or("");
    let album = meta.get("album").map(|s| s.as_str()).unwrap_or("");
    let status = meta.get("status").map(|s| s.as_str()).unwrap_or("");
    let pos = meta.get("position").map(|s| s.as_str()).unwrap_or("");
    let len = meta.get("length").map(|s| s.as_str()).unwrap_or("");
    let pname = meta.get("playerName").map(|s| s.as_str()).unwrap_or("");
    let icon = player_icon(pname);

    let text = if title.is_empty() {
        format!("{icon}  No music")
    } else {
        let label = if artist.is_empty() { title.to_string() } else { format!("{title} — {artist}") };
        format!("{icon}  {label}")
    };

    let sep = "\u{2501}".repeat(20);
    let status_sym = if status == "Playing" { "\u{25b6}" } else { "\u{23f8}" };

    let player_line = if !pname.is_empty() { format!("\nPlayer: {pname}") } else { String::new() };
    let pos_line = if !pos.is_empty() && !len.is_empty() { format!("\nTime:   {pos} / {len}") } else if !pos.is_empty() { format!("\nTime:   {pos}") } else { String::new() };

    let tooltip = format!(
        "<b>Now Playing</b>\n\
         {sep}\n\
         {icon} {title}\n\
         Artist: {artist}\n\
         Album:  {album}{player_line}\n\
         Status: {status_sym} {status}{pos_line}"
    );

    let class = match status {
        "Playing" => "playing",
        "Paused" => "paused",
        _ => "stopped",
    };

    let out = serde_json::json!({
        "text": text,
        "tooltip": tooltip,
        "class": class,
        "alt": status,
    });
    println!("{}", serde_json::to_string(&out).unwrap());
}

fn control(action: &str) {
    let players = playerctl(&["-l"]).unwrap_or_default();
    let players: Vec<&str> = players.lines().filter(|l| !l.is_empty()).collect();
    if players.is_empty() { std::process::exit(1); }

    let arg = match action {
        "play-pause" => "play-pause",
        "next" => "next",
        "previous" => "previous",
        "stop" => "stop",
        _ => return,
    };

    for p in &players {
        Command::new("playerctl")
            .args(["--player", p, arg])
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .ok();
    }
}

fn status() {
    let playing = active_player()
        .and_then(|p| playerctl(&["--player", &p, "status"]))
        .map(|s| s.trim() == "Playing")
        .unwrap_or(false);

    let icon = if playing { "\u{f28b}" } else { "\u{f144}" };

    let out = serde_json::json!({
        "text": icon,
        "alt": if playing { "playing" } else { "paused" },
        "class": if playing { "playing" } else { "paused" },
    });
    println!("{}", serde_json::to_string(&out).unwrap());
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let cmd = args.get(1).map(|s| s.as_str()).unwrap_or("show");

    match cmd {
        "show" => show(),
        "status" => status(),
        "play-pause" | "next" | "previous" | "stop" => control(cmd),
        _ => {
            eprintln!("Usage: blacknode-music <show|status|play-pause|next|previous|stop>");
            std::process::exit(1);
        }
    }
}
