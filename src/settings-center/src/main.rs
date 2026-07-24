use gtk4::prelude::*;
use gtk4::{Box, Orientation, Scale};
use libadwaita::prelude::*;
use libadwaita::{
    AboutDialog, ActionRow, Application, ApplicationWindow, HeaderBar,
    PreferencesGroup, PreferencesPage, SwitchRow, ViewSwitcher, ViewStack,
};

fn main() {
    let app = Application::builder()
        .application_id("com.blacknode.settings")
        .build();

    app.connect_activate(build_ui);
    app.run();
}

fn build_ui(app: &Application) {
    let window = ApplicationWindow::builder()
        .application(app)
        .title("BlackNode Settings")
        .default_width(720)
        .default_height(500)
        .build();

    let stack = ViewStack::new();
    stack.set_vexpand(true);
    stack.set_hexpand(true);

    stack.add_titled(&build_display_page(), Some("display"), "Display");
    stack.add_titled(&build_audio_page(), Some("audio"), "Audio");
    stack.add_titled(&build_notifications_page(), Some("notifications"), "Notifications");
    stack.add_titled(&build_system_page(), Some("system"), "System");
    stack.add_titled(&build_about_page(), Some("about"), "About");

    let switcher = ViewSwitcher::new();
    switcher.set_stack(Some(&stack));
    switcher.set_policy(libadwaita::ViewSwitcherPolicy::Wide);

    let header = HeaderBar::new();
    header.set_title_widget(Some(&switcher));

    let main_vbox = Box::new(Orientation::Vertical, 0);
    main_vbox.append(&header);
    main_vbox.append(&stack);

    window.set_content(Some(&main_vbox));
    window.present();
}

fn build_display_page() -> PreferencesPage {
    let page = PreferencesPage::new();

    let group = PreferencesGroup::new();
    group.set_title("Brightness");
    group.set_description(Some("Adjust your screen level"));

    let scale = Scale::with_range(Orientation::Horizontal, 0.0, 100.0, 5.0);
    scale.set_value(80.0);
    scale.set_hexpand(true);
    scale.set_margin_top(8);
    scale.set_margin_bottom(8);
    scale.set_margin_start(12);
    scale.set_margin_end(12);
    group.add(&scale);

    let night = SwitchRow::new();
    night.set_title("Night Mode");
    night.set_subtitle("Reduce blue light after sunset");
    group.add(&night);

    let dark = SwitchRow::new();
    dark.set_title("Dark Theme");
    dark.set_subtitle("Use dark colour scheme");
    dark.set_active(true);
    group.add(&dark);

    page.add(&group);
    page
}

fn build_audio_page() -> PreferencesPage {
    let page = PreferencesPage::new();

    let group = PreferencesGroup::new();
    group.set_title("Output");
    group.set_description(Some("Volume and mute controls"));

    let scale = Scale::with_range(Orientation::Horizontal, 0.0, 100.0, 5.0);
    scale.set_value(65.0);
    scale.set_hexpand(true);
    scale.set_margin_top(8);
    scale.set_margin_bottom(8);
    scale.set_margin_start(12);
    scale.set_margin_end(12);
    group.add(&scale);

    let mute = SwitchRow::new();
    mute.set_title("Mute");
    mute.set_subtitle("Silence all output");
    group.add(&mute);

    let group2 = PreferencesGroup::new();
    group2.set_title("Input");
    group2.set_description(Some("Microphone level"));

    let mic = Scale::with_range(Orientation::Horizontal, 0.0, 100.0, 5.0);
    mic.set_value(70.0);
    mic.set_hexpand(true);
    mic.set_margin_top(8);
    mic.set_margin_bottom(8);
    mic.set_margin_start(12);
    mic.set_margin_end(12);
    group2.add(&mic);

    page.add(&group);
    page.add(&group2);
    page
}

fn build_notifications_page() -> PreferencesPage {
    let page = PreferencesPage::new();

    let group = PreferencesGroup::new();
    group.set_title("Focus");
    group.set_description(Some("Notification behaviour"));

    let dnd = SwitchRow::new();
    dnd.set_title("Do Not Disturb");
    dnd.set_subtitle("Suppress non-critical alerts");
    group.add(&dnd);

    let silent = SwitchRow::new();
    silent.set_title("Silent Hours");
    silent.set_subtitle("Auto-mute during night period");
    silent.set_active(true);
    group.add(&silent);

    let group2 = PreferencesGroup::new();
    group2.set_title("Behaviour");
    group2.set_description(Some("Delivery preferences"));

    let timeout_row = ActionRow::new();
    timeout_row.set_title("Timeout");
    timeout_row.set_subtitle("5 seconds");
    group2.add(&timeout_row);

    page.add(&group);
    page.add(&group2);
    page
}

fn build_system_page() -> PreferencesPage {
    let page = PreferencesPage::new();

    let group = PreferencesGroup::new();
    group.set_title("Power");
    group.set_description(Some("Performance and battery"));

    let perf = ActionRow::new();
    perf.set_title("Power Profile");
    perf.set_subtitle("Balanced");
    group.add(&perf);

    let updates = ActionRow::new();
    updates.set_title("Updates");
    updates.set_subtitle("3 packages pending");
    group.add(&updates);

    let group2 = PreferencesGroup::new();
    group2.set_title("Profile");
    group2.set_description(Some("Current Hyprland profile"));

    let profile = ActionRow::new();
    profile.set_title("Active Profile");
    profile.set_subtitle("Default");
    group2.add(&profile);

    page.add(&group);
    page.add(&group2);
    page
}

fn build_about_page() -> PreferencesPage {
    let page = PreferencesPage::new();

    let group = PreferencesGroup::new();
    group.set_title("BlackNode");

    let info = ActionRow::new();
    info.set_title("Settings Center");
    info.set_subtitle("Version 0.1.0");
    group.add(&info);

    let btn = gtk4::Button::with_label("Open About");
    btn.set_margin_top(12);
    btn.set_margin_bottom(12);
    btn.set_margin_start(12);
    btn.set_margin_end(12);
    btn.set_halign(gtk4::Align::Start);

    btn.connect_clicked(|_| {
        let about = AboutDialog::builder()
            .application_name("BlackNode Settings")
            .version("0.1.0")
            .developer_name("BlackNode")
            .website("https://github.com/zhaleff/BlackNode")
            .issue_url("https://github.com/zhaleff/BlackNode/issues")
            .build();
        about.present(None::<&gtk4::Widget>);
    });

    group.add(&btn);
    page.add(&group);
    page
}