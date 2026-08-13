use std::env;
use std::fs;
use std::path::PathBuf;

use serde::Deserialize;

#[derive(Debug, Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum Block {
    Paragraph { text: String },
    Bullets { items: Vec<String> },
    Keybinding { text: String },
    Code { text: String },
    Tip { text: String },
}

#[derive(Debug, Deserialize)]
pub struct Step {
    pub title: String,
    #[serde(default)]
    pub blocks: Vec<Block>,
}

#[derive(Debug, Deserialize)]
pub struct Chapter {
    pub id: String,
    pub title: String,
    #[serde(default)]
    pub steps: Vec<Step>,
}

#[derive(Debug, Deserialize)]
pub struct Course {
    pub title: String,
    #[serde(default)]
    pub subtitle: String,
    #[serde(default)]
    pub chapters: Vec<Chapter>,
}

fn home() -> PathBuf {
    PathBuf::from(env::var("HOME").unwrap_or_else(|_| ".".into()))
}

pub fn content_dirs() -> Vec<PathBuf> {
    vec![
        home().join(".local/share/blacknode/tutorial"),
        home().join("BlackNode/Configs/.local/share/blacknode/tutorial"),
    ]
}

pub fn detect_lang() -> String {
    for var in ["LC_ALL", "LC_MESSAGES", "LANG"] {
        if let Ok(value) = env::var(var) {
            if let Some(code) = value.split(['_', '.']).next() {
                let code = code.to_lowercase();
                if code.len() == 2 {
                    return code;
                }
            }
        }
    }
    "en".into()
}

pub fn load(force_lang: Option<&str>) -> Result<Course, String> {
    let lang = force_lang.map(str::to_string).unwrap_or_else(detect_lang);
    let mut tried = Vec::new();

    for dir in content_dirs() {
        let specific = dir.join(format!("course.{lang}.toml"));
        tried.push(specific.display().to_string());
        if let Ok(raw) = fs::read_to_string(&specific) {
            if let Ok(course) = toml::from_str::<Course>(&raw) {
                return Ok(course);
            }
        }
        if force_lang.is_none() {
            let default = dir.join("course.toml");
            tried.push(default.display().to_string());
            if let Ok(raw) = fs::read_to_string(&default) {
                if let Ok(course) = toml::from_str::<Course>(&raw) {
                    return Ok(course);
                }
            }
        }
    }

    Err(format!("No course content found. Tried: {}", tried.join(", ")))
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE: &str = r#"
title = "Test course"
subtitle = "for tests"

[[chapters]]
id = "one"
title = "First"
[[chapters.steps]]
title = "Step A"
[[chapters.steps.blocks]]
kind = "paragraph"
text = "Hello"
[[chapters.steps.blocks]]
kind = "bullets"
items = ["a", "b"]
[[chapters.steps.blocks]]
kind = "keybinding"
text = "SUPER + D — terminal"

[[chapters]]
id = "two"
title = "Second"
"#;

    #[test]
    fn parses_course_from_toml() {
        let course: Course = toml::from_str(SAMPLE).unwrap();
        assert_eq!(course.title, "Test course");
        assert_eq!(course.chapters.len(), 2);
        assert_eq!(course.chapters[0].steps.len(), 1);
        assert_eq!(course.chapters[0].steps[0].blocks.len(), 3);
        assert!(course.chapters[1].steps.is_empty());
    }

    #[test]
    fn lang_detection_is_two_letters() {
        assert_eq!(detect_lang().len(), 2);
    }
}
