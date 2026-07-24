use gtk4::prelude::*;
use gtk4::{Box, Label, ListBox, ListBoxRow, Orientation, Scale, Separator};
use libadwaita::prelude::*;
use libadwaita::{
    AboutDialog, ActionRow, Application, ApplicationWindow, HeaderBar,
    NavigationPage, NavigationSplitView, NavigationView, PreferencesGroup,
    PreferencesPage, SwitchRow,
};

fn main() {
    let app = Application::builder()
        .application_id("com.blacknode.settings")
        .build();
    app.connect_activate(build_ui);
    app.run();
}

fn css() -> gtk4::CssProvider {
    let p = gtk4::CssProvider::new();
    p.load_from_string(
        ".sidebar-row { padding: 10px 16px; border-radius: 10px; margin: 1px 6px; }
         .sidebar-row label { font-size: 14px; }
         .sidebar-cat { padding: 16px 16px 4px; font-weight: 700; font-size: 11px;
                        letter-spacing: 0.5px; opacity: 0.6; text-transform: uppercase; }
         .page-title { font-size: 24px; font-weight: 700; padding: 16px 24px 4px; }
         .page-sub { font-size: 13px; padding: 0 24px 12px; opacity: 0.7; }
         .pomo-time { font-size: 48px; font-weight: 700; font-family: monospace; }",
    );
    p
}

fn build_ui(app: &Application) {
    gtk4::style_context_add_provider_for_display(
        &gtk4::gdk::Display::default().expect("display"),
        &css(),
        gtk4::STYLE_PROVIDER_PRIORITY_APPLICATION,
    );

    let window = ApplicationWindow::builder()
        .application(app)
        .title("BlackNode Settings")
        .default_width(920)
        .default_height(620)
        .build();

    let nav = NavigationView::new();
    nav.set_hexpand(true);
    nav.set_vexpand(true);
    nav.push(&page_system(app));

    let content_page = NavigationPage::new(&nav, "Settings");
    let sidebar = build_sidebar(app, &nav);
    let sidebar_page = NavigationPage::new(&sidebar, "Categories");

    let split = NavigationSplitView::new();
    split.set_sidebar(Some(&sidebar_page));
    split.set_content(Some(&content_page));
    split.set_sidebar_position(gtk4::PackType::Start);

    let header = HeaderBar::builder().show_start_title_buttons(true).build();
    let main_box = Box::new(Orientation::Vertical, 0);
    main_box.append(&header);
    main_box.append(&split);

    window.set_content(Some(&main_box));
    window.present();
}

fn build_sidebar(app: &Application, nav: &NavigationView) -> Box {
    let side = Box::new(Orientation::Vertical, 0);
    side.set_width_request(220);

    let title = Label::new(Some("Settings"));
    title.set_css_classes(&["page-title"]);
    title.set_margin_start(12);
    title.set_margin_end(12);
    side.append(&title);

    let list = ListBox::new();
    list.set_selection_mode(gtk4::SelectionMode::Single);

    let items: Vec<(&str, &str, Vec<(&str, &str, fn(&Application) -> NavigationPage)>)> = vec![
        ("SYSTEM", "⚡", vec![
            ("Power & Performance", "_power", |a| page_system(a)),
            ("Services", "_svc", |_| page_services()),
            ("System Health", "_health", |_| page_health()),
            ("About BlackNode", "_about", |_| page_about()),
        ]),
        ("DISPLAY", "🖥️", vec![
            ("Brightness & Night Mode", "_disp", |_| page_display()),
            ("Wallpaper", "_wall", |_| page_wallpaper()),
            ("Animations", "_anim", |_| page_animations()),
            ("Themes", "_theme", |_| page_themes()),
        ]),
        ("AUDIO", "🔊", vec![
            ("Volume & Output", "_aud", |_| page_audio()),
            ("Input & Mic", "_mic", |_| page_mic()),
            ("Audio Profiles", "_ap", |_| page_audio_profiles()),
        ]),
        ("INPUT", "⌨️", vec![
            ("Keybinds", "_kb", |_| page_keybinds()),
            ("Keyboard Layout", "_kl", |_| page_layout()),
        ]),
        ("WINDOW", "🪟", vec![
            ("Layout & Behavior", "_win", |_| page_window()),
            ("Workspaces", "_ws", |_| page_workspaces()),
            ("Window Rules", "_wr", |_| page_rules()),
        ]),
        ("APPEARANCE", "🎨", vec![
            ("Colors & Style", "_col", |_| page_colors()),
            ("Fonts", "_font", |_| page_fonts()),
            ("Icons & Cursor", "_icon", |_| page_icons()),
        ]),
        ("NOTIFICATIONS", "🔔", vec![
            ("Focus & DnD", "_notif", |_| page_notifications()),
            ("Behaviour", "_nb", |_| page_notif_behav()),
        ]),
        ("WAYBAR", "📊", vec![
            ("Style & Position", "_wb", |_| page_waybar()),
            ("Modules", "_wbm", |_| page_waybar_modules()),
        ]),
        ("PROFILES", "📐", vec![
            ("Default", "_pd", |_| page_profile_default()),
            ("Programming", "_pp", |_| page_profile_prog()),
            ("Gaming", "_pg", |_| page_profile_game()),
            ("Presentation", "_ppr", |_| page_profile_pres()),
        ]),
        ("PACKAGES", "📦", vec![
            ("Updates", "_pkg", |_| page_packages()),
        ]),
        ("CONFIG FILES", "📝", vec![
            ("Hyprland", "_ch", |_| page_cfg_hypr()),
            ("Waybar", "_cw", |_| page_cfg_waybar()),
            ("Dunst", "_cd", |_| page_cfg_dunst()),
            ("Rofi", "_cr", |_| page_cfg_rofi()),
            ("BlackNode", "_cbn", |_| page_cfg_bn()),
        ]),
        ("POMODORO", "🍅", vec![
            ("Timer", "_pomo", |_| page_pomo()),
            ("Settings", "_ps", |_| page_pomo_settings()),
        ]),
    ];

    for (cat, icon, pages) in items {
        let sep = Separator::new(Orientation::Horizontal);
        sep.set_margin_top(4);
        sep.set_margin_bottom(2);
        list.append(&sep);

        let cat_lbl = Label::new(Some(&format!("{}  {}", icon, cat)));
        cat_lbl.set_css_classes(&["sidebar-cat"]);
        list.append(&cat_lbl);

        for (name, _id, builder) in pages {
            let row = ListBoxRow::new();
            let rb = Box::new(Orientation::Horizontal, 8);
            rb.set_margin_start(12);
            rb.set_margin_end(12);
            rb.set_margin_top(6);
            rb.set_margin_bottom(6);
            let lbl = Label::new(Some(name));
            lbl.set_halign(gtk4::Align::Start);
            rb.append(&lbl);
            row.set_child(Some(&rb));
            row.set_css_classes(&["sidebar-row"]);

            let nav_clone = nav.clone();
            let app_clone = app.clone();
            row.connect_activate(move |_| {
                let page = builder(&app_clone);
                nav_clone.push(&page);
            });

            list.append(&row);
        }
    }

    let scroll = gtk4::ScrolledWindow::builder().hscrollbar_policy(gtk4::PolicyType::Never).build();
    scroll.set_child(Some(&list));
    side.append(&scroll);
    side
}

fn make_page(title: &str, _subtitle: &str, build: fn(&PreferencesPage)) -> NavigationPage {
    let prefs = PreferencesPage::new();
    build(&prefs);
    NavigationPage::new(&prefs, title)
}

fn add_switch(group: &PreferencesGroup, title: &str, sub: &str, active: bool) -> SwitchRow {
    let s = SwitchRow::new();
    s.set_title(title);
    s.set_subtitle(sub);
    s.set_active(active);
    group.add(&s);
    s
}

fn add_action(group: &PreferencesGroup, title: &str, sub: &str) -> ActionRow {
    let a = ActionRow::new();
    a.set_title(title);
    a.set_subtitle(sub);
    group.add(&a);
    a
}

fn add_scale(group: &PreferencesGroup, _label: &str, val: f64) {
    let s = Scale::with_range(Orientation::Horizontal, 0.0, 100.0, 5.0);
    s.set_value(val);
    s.set_hexpand(true);
    s.set_margin_top(6);
    s.set_margin_bottom(6);
    s.set_margin_start(12);
    s.set_margin_end(12);
    group.add(&s);
}

// ─── SYSTEM ─────────────────────────────────────────────────────────

fn page_system(_app: &Application) -> NavigationPage {
    make_page("Power & Performance", "CPU governor, profiles, battery", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Power Profile");
        add_action(&g, "Active Profile", "Balanced");
        add_action(&g, "Available", "performance · balanced · power-saver");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Performance");
        add_switch(&g2, "Performance Mode", "Boost CPU/GPU when plugged in", true);
        add_switch(&g2, "Adaptive Brightness", "Auto-adjust by ambient", false);
        p.add(&g2);
    })
}

fn page_services() -> NavigationPage {
    make_page("Services", "System daemons and processes", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Running Services");
        add_action(&g, "NetworkManager", "● running");
        add_action(&g, "PipeWire", "● running");
        add_action(&g, "Hypridle", "● running");
        add_action(&g, "Dunst", "● running");
        add_action(&g, "Waybar", "● running");
        p.add(&g);
    })
}

fn page_health() -> NavigationPage {
    make_page("System Health", "Hardware status and diagnostics", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Hardware");
        add_action(&g, "GPU", "NVIDIA / Intel / AMD");
        add_action(&g, "Memory", "3.2 GB / 7.6 GB");
        add_action(&g, "Disk", "45% used");
        add_action(&g, "CPU", "Ryzen 5 · 15% load");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Sensors");
        add_action(&g2, "CPU Temperature", "52°C");
        add_action(&g2, "Fan Speed", "2100 RPM");
        p.add(&g2);
    })
}

fn page_about() -> NavigationPage {
    make_page("About BlackNode", "Version, repo, credits", |p| {
        let g = PreferencesGroup::new();
        g.set_title("BlackNode");
        add_action(&g, "Version", "0.1.0");
        add_action(&g, "Repository", "github.com/zhaleff/BlackNode");
        add_action(&g, "Shell", "Zsh");
        add_action(&g, "Compositor", "Hyprland 0.56");
        let btn = gtk4::Button::with_label("About Dialog");
        btn.add_css_class("suggested-action");
        btn.set_halign(gtk4::Align::Start);
        btn.set_margin_start(12);
        btn.set_margin_bottom(8);
        btn.connect_clicked(|_| {
            let d = AboutDialog::builder()
                .application_name("BlackNode Settings")
                .version("0.1.0").developer_name("BlackNode")
                .website("https://github.com/zhaleff/BlackNode").build();
            d.present(None::<&gtk4::Widget>);
        });
        g.add(&btn);
        p.add(&g);
    })
}

// ─── DISPLAY ────────────────────────────────────────────────────────

fn page_display() -> NavigationPage {
    make_page("Brightness & Night Mode", "Screen levels, eye comfort", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Brightness");
        add_scale(&g, "Level", 80.0);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Night Mode");
        add_switch(&g2, "Night Light", "Reduce blue light after sunset", true);
        add_action(&g2, "Schedule", "Sunset to sunrise");
        add_switch(&g2, "Dark Theme", "Dark colour scheme", true);
        p.add(&g2);
    })
}

fn page_wallpaper() -> NavigationPage {
    make_page("Wallpaper", "Current background and rotation", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Current Wallpaper");
        add_action(&g, "Image", "hyprland-1848.jpg");
        add_action(&g, "Engine", "hyprpaper");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Actions");
        add_action(&g2, "Change Wallpaper", "Open wallpaper selector");
        add_switch(&g2, "Auto-Rotate", "Change every hour", false);
        add_action(&g2, "Last Changed", "Today · 09:15");
        p.add(&g2);
    })
}

fn page_animations() -> NavigationPage {
    make_page("Animations", "Window animation presets", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Animation Style");
        for s in &["BlackNode-Flow", "BlackNode-Eclipse", "BlackNode-Snappy", "BlackNode-Elastic", "BlackNode-Linear"] {
            add_action(&g, s, if *s == "BlackNode-Flow" { "● active" } else { "" });
        }
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Effects");
        add_switch(&g2, "Blur", "Window blur effect", true);
        add_switch(&g2, "Shadow", "Window drop shadows", false);
        add_switch(&g2, "Dim Inactive", "Dim unfocused windows", true);
        add_action(&g2, "Rounding", "10 px");
        p.add(&g2);
    })
}

fn page_themes() -> NavigationPage {
    make_page("Themes", "Color schemes and decoration", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Active Theme");
        add_action(&g, "Current", "BlackNode Dark");
        add_action(&g, "Scheme", "Generated by Matugen");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Colors");
        add_action(&g2, "Accent", "#ff6d00 (custom)");
        add_action(&g2, "Regenerate", "Run matugen with wallpaper");
        p.add(&g2);
    })
}

// ─── AUDIO ──────────────────────────────────────────────────────────

fn page_audio() -> NavigationPage {
    make_page("Volume & Output", "Speaker/headphone levels", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Output Volume");
        add_scale(&g, "Volume", 65.0);
        add_switch(&g, "Mute", "Silence output", false);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Output Device");
        add_action(&g2, "Default Sink", "@DEFAULT_AUDIO_SINK@");
        add_action(&g2, "Available", "Built-in Audio · HDMI");
        p.add(&g2);
    })
}

fn page_mic() -> NavigationPage {
    make_page("Input & Mic", "Microphone and recording", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Microphone");
        add_scale(&g, "Input Level", 70.0);
        add_switch(&g, "Mute Mic", "Silence microphone", false);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Device");
        add_action(&g2, "Default Source", "@DEFAULT_AUDIO_SOURCE@");
        p.add(&g2);
    })
}

fn page_audio_profiles() -> NavigationPage {
    make_page("Audio Profiles", "Per-app audio routing", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Active Profiles");
        add_switch(&g, "Music Mode", "Bass boost for Spotify", false);
        add_switch(&g, "Voice Mode", "Mic priority for Discord", true);
        add_switch(&g, "Game Mode", "Surround emulation", false);
        p.add(&g);
    })
}

// ─── INPUT ──────────────────────────────────────────────────────────

fn page_keybinds() -> NavigationPage {
    make_page("Keybinds", "All keyboard shortcuts", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Applications");
        add_action(&g, "SUPER + B", "Firefox");
        add_action(&g, "SUPER + D", "Kitty");
        add_action(&g, "SUPER + E", "Dolphin");
        add_action(&g, "SUPER + R", "Rofi drun");
        add_action(&g, "SUPER + SPACE", "bn-menu");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("System");
        add_action(&g2, "SUPER + X", "wlogout");
        add_action(&g2, "SUPER + L", "hyprlock");
        add_action(&g2, "SUPER + COMMA", "Settings");
        add_action(&g2, "SUPER + Q", "Close window");
        add_action(&g2, "SUPER + F", "Toggle float");
        add_action(&g2, "SUPER + SHIFT + F", "Toggle fullscreen");
        p.add(&g2);
        let g3 = PreferencesGroup::new();
        g3.set_title("Screenshots");
        add_action(&g3, "SUPER + H", "hyprshot menu");
        add_action(&g3, "SUPER + SHIFT + H", "wf-recorder");
        p.add(&g3);
        let g4 = PreferencesGroup::new();
        g4.set_title("Utility");
        add_action(&g4, "SUPER + C", "clipse clipboard");
        add_action(&g4, "SUPER + V", "Config HUD");
        add_action(&g4, "SUPER + T", "Music player");
        add_action(&g4, "SUPER + S", "Scratchpad");
        p.add(&g4);
    })
}

fn page_layout() -> NavigationPage {
    make_page("Keyboard Layout", "Layout and switching", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Layout");
        add_action(&g, "Current", "US (English)");
        add_action(&g, "Available", "US · ES · FR");
        add_switch(&g, "Show in Bar", "Layout indicator in waybar", true);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Shortcut");
        add_action(&g2, "Switch Layout", "SUPER + SHIFT + SPACE");
        p.add(&g2);
    })
}

// ─── WINDOW ─────────────────────────────────────────────────────────

fn page_window() -> NavigationPage {
    make_page("Layout & Behavior", "WM layout and gaps", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Layout");
        add_action(&g, "Active Layout", "Dwindle");
        add_switch(&g, "Master Layout", "Use master-stack", false);
        add_switch(&g, "Smart Split", "Auto-split by window count", true);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Gaps");
        add_action(&g2, "Gaps In", "4 px");
        add_action(&g2, "Gaps Out", "8 px");
        p.add(&g2);
        let g3 = PreferencesGroup::new();
        g3.set_title("Behavior");
        add_switch(&g3, "Follow Mouse", "Focus follows cursor", true);
        add_switch(&g3, "Float Rules", "Apply floating rules", true);
        p.add(&g3);
    })
}

fn page_workspaces() -> NavigationPage {
    make_page("Workspaces", "Workspace configuration", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Workspaces");
        add_action(&g, "Count", "9 (1-9)");
        add_switch(&g, "Scroll Wrap", "Wrap workspaces on scroll", true);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Special");
        add_action(&g2, "Scratchpad", "SUPER + S to toggle");
        add_switch(&g2, "Pin to Monitor", "Keep scratchpad on same monitor", true);
        p.add(&g2);
    })
}

fn page_rules() -> NavigationPage {
    make_page("Window Rules", "Floating and workspace rules", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Floating Rules");
        add_action(&g, "kitty", "Floating · opacity 1.0");
        add_action(&g, "pavucontrol", "Floating");
        add_action(&g, "firefox pip", "Floating · pin");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Workspace Rules");
        add_action(&g2, "kitty terminal", "→ special:term");
        add_action(&g2, "nvim/obsidian", "→ special:notes");
        p.add(&g2);
    })
}

// ─── APPEARANCE ─────────────────────────────────────────────────────

fn page_colors() -> NavigationPage {
    make_page("Colors & Style", "Accent and decoration", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Accent Color");
        add_action(&g, "Active", "#ff6d00 · Deep Orange");
        add_action(&g, "Picker", "Select from palette");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Decoration");
        add_switch(&g2, "Dim Special", "Dim scratchpad", true);
        add_action(&g2, "Active Opacity", "1.0");
        add_action(&g2, "Inactive Opacity", "0.3");
        add_action(&g2, "Rounding", "10 px");
        p.add(&g2);
    })
}

fn page_fonts() -> NavigationPage {
    make_page("Fonts", "UI and monospace fonts", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Fonts");
        add_action(&g, "UI Font", "JetBrains Mono · 10");
        add_action(&g, "Monospace", "JetBrains Mono · 10");
        add_action(&g, "Scale", "1.0");
        p.add(&g);
    })
}

fn page_icons() -> NavigationPage {
    make_page("Icons & Cursor", "Theme and cursor size", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Icons");
        add_action(&g, "Theme", "Papirus-Dark");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Cursor");
        add_action(&g2, "Theme", "Bibata-Modern-Classic");
        add_action(&g2, "Size", "24");
        p.add(&g2);
    })
}

// ─── NOTIFICATIONS ──────────────────────────────────────────────────

fn page_notifications() -> NavigationPage {
    make_page("Focus & DnD", "Do not disturb and focus", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Do Not Disturb");
        add_switch(&g, "Do Not Disturb", "Suppress non-critical", false);
        add_switch(&g, "Silent Hours", "Auto-mute 23:00-07:00", true);
        add_action(&g, "Schedule", "23:00 - 07:00");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Psychology Engine");
        add_switch(&g2, "IKEA Effect", "IKEA framing for actions", true);
        add_switch(&g2, "Companion Tone", "Friendly companion", true);
        add_switch(&g2, "Identity Reinforcement", "Streaks and identity", true);
        add_switch(&g2, "Zeigarnik Effect", "Incomplete task reminders", true);
        p.add(&g2);
    })
}

fn page_notif_behav() -> NavigationPage {
    make_page("Behaviour", "Delivery and sensor alerts", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Delivery");
        add_action(&g, "Timeout", "5 seconds");
        add_action(&g, "Max Visible", "3");
        add_switch(&g, "Stack", "Group similar", true);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Sensors");
        add_switch(&g2, "Battery Alerts", "Low battery warnings", true);
        add_switch(&g2, "Device Connect", "USB connect/disconnect", true);
        add_switch(&g2, "Weather Alerts", "Severe weather", true);
        add_switch(&g2, "Water Reminder", "Hydration prompts", true);
        p.add(&g2);
    })
}

// ─── WAYBAR ─────────────────────────────────────────────────────────

fn page_waybar() -> NavigationPage {
    make_page("Style & Position", "Appearance and location", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Position");
        add_switch(&g, "Top Bar", "Bar at screen top", true);
        add_action(&g, "Height", "36 px");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Style");
        add_switch(&g2, "Transparent", "Transparent bg", true);
        add_switch(&g2, "Blurred", "Background blur", true);
        add_switch(&g2, "Rounded", "Rounded corners", true);
        p.add(&g2);
    })
}

fn page_waybar_modules() -> NavigationPage {
    make_page("Modules", "Active waybar modules", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Always On");
        add_switch(&g, "Workspaces", "Workspace switcher", true);
        add_switch(&g, "Clock", "Date and time", true);
        add_switch(&g, "Volume", "Audio indicator", true);
        add_switch(&g, "Network", "WiFi status", true);
        add_switch(&g, "Battery", "Battery percentage", true);
        add_switch(&g, "Tray", "System tray", true);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Optional");
        add_switch(&g2, "CPU", "CPU usage", false);
        add_switch(&g2, "Memory", "RAM usage", false);
        add_switch(&g2, "Temperature", "CPU temp", false);
        p.add(&g2);
    })
}

// ─── PROFILES ───────────────────────────────────────────────────────

fn page_profile_default() -> NavigationPage {
    make_page("Default", "General purpose profile", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Default");
        add_action(&g, "Layout", "Dwindle");
        add_action(&g, "Factor", "0.50");
        add_switch(&g, "Active", "Currently active", true);
        p.add(&g);
    })
}

fn page_profile_prog() -> NavigationPage {
    make_page("Programming", "Coding-optimized", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Programming");
        add_action(&g, "Layout", "Master (60/40)");
        add_switch(&g, "Activate", "Switch to programming", false);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Overrides");
        add_action(&g2, "Scale", "1.2");
        add_action(&g2, "Scratchpads", "term · notes");
        add_switch(&g2, "Full Opacity", "Override all to 1.0", true);
        p.add(&g2);
    })
}

fn page_profile_game() -> NavigationPage {
    make_page("Gaming", "Gaming-optimized", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Gaming");
        add_switch(&g, "Activate", "Switch to gaming", false);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Overrides");
        add_switch(&g2, "Fullscreen", "Auto fullscreen", true);
        add_switch(&g2, "No Animations", "Zero animations", true);
        add_switch(&g2, "No Blur", "Disable blur", true);
        p.add(&g2);
    })
}

fn page_profile_pres() -> NavigationPage {
    make_page("Presentation", "Screen sharing optimised", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Presentation");
        add_switch(&g, "Activate", "Switch to presentation", false);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Overrides");
        add_switch(&g2, "DnD", "Disable notifications", true);
        add_switch(&g2, "High DPI", "Scale for sharing", false);
        p.add(&g2);
    })
}

// ─── PACKAGES ───────────────────────────────────────────────────────

fn page_packages() -> NavigationPage {
    make_page("Updates", "Official and AUR packages", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Package Manager");
        add_action(&g, "Official", "2 pending");
        add_action(&g, "AUR", "1 pending");
        add_action(&g, "Total", "3 updates");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Settings");
        add_switch(&g2, "Auto-Check", "Check on startup", true);
        add_action(&g2, "Last Check", "Today 09:00");
        p.add(&g2);
    })
}

// ─── CONFIG FILES (direct return, no closure capture needed) ────────

fn cfg_nav_page(title: &str, files: &[(&str, &str)]) -> NavigationPage {
    let prefs = PreferencesPage::new();
    let g = PreferencesGroup::new();
    g.set_title("Configuration Files");
    for (name, path) in files {
        let a = ActionRow::new();
        a.set_title(name);
        a.set_subtitle(path);
        let btn = gtk4::Button::with_label("Edit");
        btn.add_css_class("flat");
        btn.add_css_class("suggested-action");
        let p = path.to_string();
        btn.connect_clicked(move |_| {
            let home = std::env::var("HOME").unwrap_or_default();
            let full = p.replace('~', &home);
            std::process::Command::new("xdg-open").arg(&full).spawn().ok();
        });
        a.add_suffix(&btn);
        a.set_activatable_widget(Some(&btn));
        g.add(&a);
    }
    prefs.add(&g);
    NavigationPage::new(&prefs, title)
}

fn page_cfg_hypr() -> NavigationPage {
    cfg_nav_page("Hyprland", &[
        ("Main Config", "~/.config/hypr/hyprland.lua"),
        ("Keybinds", "~/.config/hypr/settings/keybinds.lua"),
        ("Autostart", "~/.config/hypr/settings/autostart.lua"),
        ("Misc", "~/.config/hypr/settings/misc.lua"),
        ("Dwindle", "~/.config/hypr/settings/dwindle.lua"),
        ("Colors", "~/.config/hypr/colors.lua"),
        ("Hypridle", "~/.config/hypr/hypridle.conf"),
        ("Hyprlock", "~/.config/hypr/hyprlock.conf"),
    ])
}

fn page_cfg_waybar() -> NavigationPage {
    cfg_nav_page("Waybar", &[
        ("Style CSS", "~/.config/waybar/style.css"),
        ("Config", "~/.config/waybar/config.jsonc"),
    ])
}

fn page_cfg_dunst() -> NavigationPage {
    cfg_nav_page("Dunst", &[
        ("Main Config", "~/.config/dunst/dunstrc"),
        ("Assets Dir", "~/.config/dunst/assets/"),
    ])
}

fn page_cfg_rofi() -> NavigationPage {
    cfg_nav_page("Rofi", &[
        ("Config Theme", "~/.config/rofi/config.rasi"),
        ("Menu Theme", "~/.config/rofi/menu.rasi"),
        ("Launcher", "~/.config/rofi/launcher/launcher.sh"),
        ("Clipboard", "~/.config/rofi/scripts/clipboard.sh"),
        ("Hyprshot", "~/.config/rofi/scripts/hyprshot.sh"),
    ])
}

fn page_cfg_bn() -> NavigationPage {
    cfg_nav_page("BlackNode", &[
        ("Psych Messages", "~/.local/share/blacknode/psych-messages.json"),
        ("Changelog", "~/.local/share/blacknode/changelog.json"),
        ("Greeter", "~/.local/share/blacknode/greeter-phrases.txt"),
        ("Behavior Schema", "~/.local/share/blacknode/behavior.schema.json"),
        ("PsychEngine Core", "~/.local/lib/blacknode/psyche/core.py"),
        ("Framing", "~/.local/lib/blacknode/psyche/framing.py"),
        ("Composers", "~/.local/lib/blacknode/notify/composers.py"),
    ])
}

// ─── POMODORO ───────────────────────────────────────────────────────

fn page_pomo() -> NavigationPage {
    make_page("Timer", "Focus sessions and breaks", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Timer");
        let time = Label::new(Some("25:00"));
        time.set_css_classes(&["pomo-time"]);
        time.set_margin_top(16);
        time.set_margin_bottom(8);
        g.add(&time);
        let btn_box = Box::new(Orientation::Horizontal, 8);
        btn_box.set_halign(gtk4::Align::Center);
        btn_box.set_margin_bottom(12);
        let start = gtk4::Button::with_label("Start");
        start.add_css_class("suggested-action");
        let reset = gtk4::Button::with_label("Reset");
        reset.add_css_class("flat");
        btn_box.append(&start);
        btn_box.append(&reset);
        g.add(&btn_box);
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Today");
        add_action(&g2, "Sessions", "3 completed");
        add_action(&g2, "Focus Time", "1h 15m");
        add_action(&g2, "Longest", "45m");
        p.add(&g2);
    })
}

fn page_pomo_settings() -> NavigationPage {
    make_page("Pomodoro Settings", "Timer durations and behaviour", |p| {
        let g = PreferencesGroup::new();
        g.set_title("Durations");
        add_action(&g, "Focus", "25 min");
        add_action(&g, "Short Break", "5 min");
        add_action(&g, "Long Break", "15 min");
        add_action(&g, "Long After", "4 sessions");
        p.add(&g);
        let g2 = PreferencesGroup::new();
        g2.set_title("Behaviour");
        add_switch(&g2, "Auto Start Break", "Auto-start break", true);
        add_switch(&g2, "Auto Start Focus", "Auto-start focus", false);
        add_switch(&g2, "Sound", "Play alarm on end", true);
        add_switch(&g2, "DnD During Focus", "Auto DnD", true);
        p.add(&g2);
    })
}