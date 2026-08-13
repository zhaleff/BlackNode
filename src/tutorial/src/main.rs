mod app;
mod content;
mod state;
mod ui;

use std::env;
use std::io;
use std::io::IsTerminal;
use std::time::Duration;

use crossterm::event::{self, Event, KeyCode, KeyEvent, KeyEventKind};
use crossterm::terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen};
use ratatui::backend::CrosstermBackend;
use ratatui::Terminal;

use app::{App, Mode};
use content::load;
use state::State;

const USAGE: &str = "\
blacknode-tutorial — interactive BlackNode guide

Usage:
  blacknode-tutorial [--lang <code>] [--chapter <id>]   run the tutorial
  blacknode-tutorial --status                           print new|in-progress|completed
  blacknode-tutorial --check                            open/notify on first run (autostart)
  blacknode-tutorial --reset                            delete saved progress
  blacknode-tutorial --help                             show this help
";

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.iter().any(|a| a == "--help" || a == "-h") {
        print!("{USAGE}");
        return;
    }
    if args.iter().any(|a| a == "--reset") {
        State::reset();
        println!("Progress reset.");
        return;
    }
    if args.iter().any(|a| a == "--status" || a == "--check") {
        let mut state = State::load();
        let status = state.status();
        println!("{status}");
        if args.iter().any(|a| a == "--check") && status == "new" && !state.nudged {
            state.nudged = true;
            state.save();
            first_run_welcome();
        }
        return;
    }

    let lang = arg_value(&args, "--lang");
    let course = match load(lang.as_deref()) {
        Ok(course) => course,
        Err(err) => {
            eprintln!("blacknode-tutorial: {err}");
            std::process::exit(1);
        }
    };

    let mut app = App::new(course, State::load());
    if let Some(id) = arg_value(&args, "--chapter") {
        match app.course.chapters.iter().position(|c| c.id == id) {
            Some(index) => {
                app.chapter = index;
                app.step = 0;
                app.scroll = 0;
                app.picker = index;
            }
            None => {
                eprintln!("No chapter with id '{id}'. Available:");
                for chapter in &app.course.chapters {
                    eprintln!("  {}", chapter.id);
                }
                std::process::exit(1);
            }
        }
    }

    match run(&mut app) {
        Ok(()) => app.persist(),
        Err(err) => {
            eprintln!("blacknode-tutorial: {err}");
            std::process::exit(1);
        }
    }
}

fn arg_value(args: &[String], flag: &str) -> Option<String> {
    args.windows(2).find(|w| w[0] == flag).map(|w| w[1].clone())
}

fn first_run_welcome() {
    let message = "Welcome to BlackNode! Take the guided tour: press SUPER + F1";
    let launched = std::process::Command::new("kitty")
        .args(["-e", "blacknode-tutorial"])
        .spawn()
        .map(|mut child| child.wait().is_ok())
        .unwrap_or(false);
    if !launched {
        let _ = std::process::Command::new("notify-send")
            .args(["-a", "BlackNode", "BlackNode", message])
            .spawn();
    }
}

fn run(app: &mut App) -> io::Result<()> {
    if !io::stdout().is_terminal() {
        return Err(io::Error::new(
            io::ErrorKind::NotConnected,
            "an interactive terminal is required (use --status or --check headlessly)",
        ));
    }

    enable_raw_mode()?;
    let mut stdout = io::stdout();
    crossterm::execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let result = event_loop(&mut terminal, app);

    disable_raw_mode()?;
    crossterm::execute!(io::stdout(), LeaveAlternateScreen)?;
    result
}

fn event_loop(
    terminal: &mut Terminal<CrosstermBackend<io::Stdout>>,
    app: &mut App,
) -> io::Result<()> {
    loop {
        terminal.draw(|frame| ui::render(frame, app))?;
        if app.quit {
            break;
        }
        if event::poll(Duration::from_millis(250))? {
            if let Event::Key(key) = event::read()? {
                if key.kind == KeyEventKind::Press {
                    handle_key(app, key);
                }
            }
        }
    }
    Ok(())
}

fn handle_key(app: &mut App, key: KeyEvent) {
    match app.mode {
        Mode::Picker => match key.code {
            KeyCode::Up | KeyCode::Char('k') => app.picker_up(),
            KeyCode::Down | KeyCode::Char('j') => app.picker_down(),
            KeyCode::Enter => app.picker_select(),
            KeyCode::Esc | KeyCode::Char('q') => app.mode = Mode::Normal,
            _ => {}
        },
        Mode::Done => match key.code {
            KeyCode::Enter => app.restart(),
            KeyCode::Esc | KeyCode::Char('q') => app.quit = true,
            _ => {}
        },
        Mode::Keys => match key.code {
            KeyCode::Esc | KeyCode::Char('?') => app.mode = Mode::Normal,
            _ => {}
        },
        Mode::Normal => match key.code {
            KeyCode::Enter | KeyCode::Right | KeyCode::Char('l') => app.next_page(),
            KeyCode::Left | KeyCode::Char('h') => app.prev_page(),
            KeyCode::Tab => app.next_chapter(),
            KeyCode::BackTab => app.prev_chapter(),
            KeyCode::Char('c') => app.mode = Mode::Picker,
            KeyCode::Char('?') => app.toggle_keys(),
            KeyCode::Up | KeyCode::Char('k') => app.scroll = app.scroll.saturating_sub(1),
            KeyCode::Down | KeyCode::Char('j') => app.scroll += 1,
            KeyCode::Esc | KeyCode::Char('q') => app.quit = true,
            _ => {}
        },
    }
}
