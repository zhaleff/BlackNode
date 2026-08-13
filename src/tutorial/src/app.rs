use crate::content::Course;
use crate::state::{Position, State};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Mode {
    Normal,
    Picker,
    Done,
    Keys,
}

pub struct App {
    pub course: Course,
    pub state: State,
    pub chapter: usize,
    pub step: usize,
    pub scroll: usize,
    pub mode: Mode,
    pub picker: usize,
    pub quit: bool,
}

impl App {
    pub fn new(course: Course, state: State) -> Self {
        let last = course.chapters.len().saturating_sub(1);
        let (chapter, step) = if state.completed {
            (0, 0)
        } else {
            (state.current.chapter.min(last), state.current.step)
        };
        Self {
            course,
            state,
            chapter,
            step,
            scroll: 0,
            mode: Mode::Normal,
            picker: chapter,
            quit: false,
        }
    }

    pub fn chapter_title(&self) -> &str {
        &self.course.chapters[self.chapter].title
    }

    pub fn step(&self) -> &crate::content::Step {
        let chapter = &self.course.chapters[self.chapter];
        &chapter.steps[self.step.min(chapter.steps.len().saturating_sub(1))]
    }

    fn mark_current_seen(&mut self) {
        let id = &self.course.chapters[self.chapter].id;
        if !self.state.seen.contains(id) {
            self.state.seen.push(id.clone());
        }
    }

    pub fn next_page(&mut self) {
        self.scroll = 0;
        let steps = self.course.chapters[self.chapter].steps.len();
        if self.step + 1 < steps {
            self.step += 1;
        } else if self.chapter + 1 < self.course.chapters.len() {
            self.mark_current_seen();
            self.chapter += 1;
            self.step = 0;
            self.picker = self.chapter;
        } else {
            self.mark_current_seen();
            self.state.completed = true;
            self.mode = Mode::Done;
        }
    }

    pub fn prev_page(&mut self) {
        self.scroll = 0;
        if self.step > 0 {
            self.step -= 1;
        } else if self.chapter > 0 {
            self.chapter -= 1;
            self.step = self.course.chapters[self.chapter].steps.len().saturating_sub(1);
            self.picker = self.chapter;
        }
    }

    pub fn next_chapter(&mut self) {
        self.scroll = 0;
        if self.chapter + 1 < self.course.chapters.len() {
            self.mark_current_seen();
            self.chapter += 1;
            self.step = 0;
            self.picker = self.chapter;
        } else {
            self.mark_current_seen();
            self.state.completed = true;
            self.mode = Mode::Done;
        }
    }

    pub fn prev_chapter(&mut self) {
        self.scroll = 0;
        if self.chapter > 0 {
            self.chapter -= 1;
            self.step = 0;
            self.picker = self.chapter;
        }
    }

    pub fn picker_up(&mut self) {
        self.picker = self.picker.saturating_sub(1);
    }

    pub fn picker_down(&mut self) {
        if self.picker + 1 < self.course.chapters.len() {
            self.picker += 1;
        }
    }

    pub fn picker_select(&mut self) {
        self.scroll = 0;
        self.chapter = self.picker;
        self.step = 0;
        self.mode = Mode::Normal;
    }

    pub fn toggle_keys(&mut self) {
        self.mode = if self.mode == Mode::Keys {
            Mode::Normal
        } else {
            Mode::Keys
        };
    }

    pub fn restart(&mut self) {
        self.chapter = 0;
        self.step = 0;
        self.scroll = 0;
        self.picker = 0;
        self.mode = Mode::Normal;
    }

    pub fn persist(&self) {
        let mut state = self.state.clone();
        state.current = Position {
            chapter: self.chapter,
            step: self.step,
        };
        state.save();
    }
}

#[cfg(test)]
fn course_with_steps() -> Course {
    let course = r#"
title = "T"
[[chapters]]
id = "a"
title = "A"
[[chapters.steps]]
title = "a1"
[[chapters.steps.blocks]]
kind = "paragraph"
text = "x"
[[chapters.steps]]
title = "a2"
[[chapters.steps.blocks]]
kind = "paragraph"
text = "y"

[[chapters]]
id = "b"
title = "B"
[[chapters.steps]]
title = "b1"
[[chapters.steps.blocks]]
kind = "paragraph"
text = "z"
"#;
    toml::from_str(course).unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn app() -> App {
        App::new(course_with_steps(), State::default())
    }

    #[test]
    fn advances_within_and_across_chapters() {
        let mut app = app();
        assert_eq!((app.chapter, app.step), (0, 0));
        app.next_page();
        assert_eq!((app.chapter, app.step), (0, 1));
        app.next_page();
        assert_eq!((app.chapter, app.step), (1, 0));
        app.next_page();
        assert_eq!(app.mode, Mode::Done);
        assert!(app.state.completed);
        assert!(app.state.seen.contains(&"a".to_string()));
        assert!(app.state.seen.contains(&"b".to_string()));
    }

    #[test]
    fn goes_back_to_previous_step() {
        let mut app = app();
        app.next_page();
        app.prev_page();
        assert_eq!((app.chapter, app.step), (0, 0));
    }

    #[test]
    fn skips_chapters_forward_and_back() {
        let mut app = app();
        app.next_chapter();
        assert_eq!((app.chapter, app.step), (1, 0));
        app.prev_chapter();
        assert_eq!((app.chapter, app.step), (0, 0));
    }

    #[test]
    fn picker_jumps_to_any_chapter() {
        let mut app = app();
        app.picker = 1;
        app.picker_select();
        assert_eq!(app.chapter, 1);
        assert_eq!(app.step, 0);
        assert_eq!(app.mode, Mode::Normal);
    }

    #[test]
    fn restart_resets_position() {
        let mut app = app();
        app.next_chapter();
        app.restart();
        assert_eq!((app.chapter, app.step), (0, 0));
        assert_eq!(app.mode, Mode::Normal);
    }
}
