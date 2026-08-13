use ratatui::layout::{Alignment, Constraint, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Clear, List, ListItem, ListState, Paragraph, Wrap};
use ratatui::Frame;

use crate::app::{App, Mode};
use crate::content::Block as ContentBlock;

const ACCENT: Color = Color::Cyan;
const DIM: Color = Color::DarkGray;

pub fn render(frame: &mut Frame, app: &App) {
    let area = frame.area();
    let chunks = Layout::vertical([
        Constraint::Length(7),
        Constraint::Min(0),
        Constraint::Length(1),
    ])
    .split(area);

    render_header(frame, app, chunks[0]);
    match app.mode {
        Mode::Picker => render_picker(frame, app, chunks[1]),
        Mode::Done => render_done(frame, app, chunks[1]),
        Mode::Keys => render_keys(frame, chunks[1]),
        Mode::Normal => render_step(frame, app, chunks[1]),
    }
    render_footer(frame, app, chunks[2]);
}

fn render_header(frame: &mut Frame, app: &App, area: Rect) {
    let total = app.course.chapters.len();
    let current = app.chapter + 1;
    let pct = current * 100 / total;
    let bar_len = 20usize;
    let filled = pct * bar_len / 100;
    let bar: String = format!("{}{}", "━".repeat(filled), "─".repeat(bar_len - filled));

    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title_top(Line::from(format!(" {} ", app.course.title)))
        .title_top(
            Line::from(Span::styled(
                format!(" Chapter {current}/{total} {pct}% "),
                Style::default().fg(ACCENT),
            ))
            .alignment(Alignment::Right),
        );

    let lines = vec![
        Line::from(Span::styled(&app.course.subtitle, Style::default().fg(DIM))),
        Line::from(""),
        Line::from(Span::styled(
            app.chapter_title(),
            Style::default().fg(ACCENT).add_modifier(Modifier::BOLD),
        )),
        Line::from(""),
        Line::from(Span::styled(bar, Style::default().fg(ACCENT))),
    ];

    frame.render_widget(Paragraph::new(lines).block(block), area);
}

fn render_step(frame: &mut Frame, app: &App, area: Rect) {
    let step = app.step();
    let steps = app.course.chapters[app.chapter].steps.len();
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title_top(Line::from(format!(" {} ", step.title)))
        .title_top(
            Line::from(Span::styled(
                format!(" {}/{} ", app.step + 1, steps),
                Style::default().fg(DIM),
            ))
            .alignment(Alignment::Right),
        );

    let lines = block_lines(app);
    frame.render_widget(
        Paragraph::new(lines)
            .block(block)
            .wrap(Wrap { trim: false })
            .scroll((app.scroll as u16, 0)),
        area,
    );
}

fn block_lines<'a>(app: &'a App) -> Vec<Line<'a>> {
    let mut lines: Vec<Line> = Vec::new();
    for (index, block) in app.step().blocks.iter().enumerate() {
        if index > 0 {
            lines.push(Line::from(""));
        }
        match block {
            ContentBlock::Paragraph { text } => {
                lines.push(Line::from(text.as_str()));
            }
            ContentBlock::Bullets { items } => {
                for item in items {
                    lines.push(Line::from(vec![
                        Span::styled("• ", Style::default().fg(ACCENT)),
                        Span::raw(item.clone()),
                    ]));
                }
            }
            ContentBlock::Keybinding { text } => {
                lines.push(Line::from(vec![
                    Span::styled("› ", Style::default().fg(ACCENT)),
                    Span::styled(
                        text.clone(),
                        Style::default().fg(ACCENT).add_modifier(Modifier::BOLD),
                    ),
                ]));
            }
            ContentBlock::Code { text } => {
                lines.push(Line::from(vec![Span::styled(
                    format!("  {text}"),
                    Style::default()
                        .fg(Color::White)
                        .bg(Color::Indexed(236)),
                )]));
            }
            ContentBlock::Tip { text } => {
                lines.push(Line::from(vec![
                    Span::styled("i ", Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)),
                    Span::styled(text.clone(), Style::default().fg(Color::Yellow)),
                ]));
            }
        }
    }
    lines
}

fn centered(area: Rect, width: u16, height: u16) -> Rect {
    let x = area.x + area.width.saturating_sub(width) / 2;
    let y = area.y + area.height.saturating_sub(height) / 2;
    Rect::new(x, y, width.min(area.width), height.min(area.height))
}

fn render_picker(frame: &mut Frame, app: &App, area: Rect) {
    let items: Vec<ListItem> = app
        .course
        .chapters
        .iter()
        .enumerate()
        .map(|(i, chapter)| {
            let cursor = if i == app.picker { "▸ " } else { "  " };
            let seen = if app.state.seen.contains(&chapter.id) { "✓ " } else { "  " };
            let style = if i == app.chapter {
                Style::default().fg(ACCENT)
            } else {
                Style::default()
            };
            ListItem::new(Line::from(Span::styled(format!("{cursor}{seen}{}", chapter.title), style)))
        })
        .collect();

    let list = List::new(items)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_type(BorderType::Rounded)
                .title(" Chapters "),
        )
        .highlight_style(Style::default().bg(Color::Indexed(240)).add_modifier(Modifier::BOLD))
        .highlight_symbol("");

    let rect = centered(area, 44, app.course.chapters.len() as u16 + 2);
    let mut list_state = ListState::default();
    list_state.select(Some(app.picker));

    frame.render_widget(Clear, rect);
    frame.render_stateful_widget(list, rect, &mut list_state);
}

fn render_done(frame: &mut Frame, app: &App, area: Rect) {
    let lines = vec![
        Line::from(Span::styled(
            "Welcome to BlackNode!",
            Style::default().fg(ACCENT).add_modifier(Modifier::BOLD),
        )),
        Line::from(""),
        Line::from(format!(
            "You toured {} of {} chapters.",
            app.state.seen.len(),
            app.course.chapters.len()
        )),
        Line::from(Span::styled(
            "The whole desktop is yours to explore — every piece is one menu away.",
            Style::default().fg(DIM),
        )),
        Line::from(""),
        Line::from(Span::styled(
            "Reopen this tour anytime with SUPER + F1.",
            Style::default().fg(DIM),
        )),
        Line::from(""),
        Line::from(Span::styled("Press enter to start again, or q to quit.", Style::default().fg(DIM))),
    ];

    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title(" Done ");
    let paragraph = Paragraph::new(lines).block(block).alignment(Alignment::Center);
    frame.render_widget(Clear, area);
    frame.render_widget(paragraph, centered(area, area.width - 4, 12));
}

const KEY_HELP: &[(&str, &str)] = &[
    ("enter / →", "next step"),
    ("←", "previous step"),
    ("tab", "next chapter"),
    ("shift+tab", "previous chapter"),
    ("c", "jump to a chapter"),
    ("j / k", "scroll content"),
    ("?", "this help"),
    ("q / esc", "quit"),
];

fn render_keys(frame: &mut Frame, area: Rect) {
    let lines: Vec<Line> = KEY_HELP
        .iter()
        .map(|(key, what)| {
            Line::from(vec![
                Span::styled(format!("  {key:<12} "), Style::default().fg(ACCENT).add_modifier(Modifier::BOLD)),
                Span::styled(what.to_string(), Style::default().fg(DIM)),
            ])
        })
        .collect();

    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title(" Keys ");
    let paragraph = Paragraph::new(lines).block(block);
    let rect = centered(area, 44, KEY_HELP.len() as u16 + 2);
    frame.render_widget(Clear, rect);
    frame.render_widget(paragraph, rect);
}

fn render_footer(frame: &mut Frame, app: &App, area: Rect) {
    let hints = match app.mode {
        Mode::Picker => "↑↓ select   enter jump   esc back",
        Mode::Done => "enter restart   q quit",
        Mode::Keys => "esc back",
        Mode::Normal => "enter next   ← prev   tab chapter   c chapters   ? keys   q quit",
    };
    frame.render_widget(
        Paragraph::new(Line::from(Span::styled(hints, Style::default().fg(DIM)))),
        area,
    );
}
