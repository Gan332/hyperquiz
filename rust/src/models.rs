use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum QuestionType {
    SingleChoice,
    MultipleChoice,
    TrueFalse,
    FillBlank,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Question {
    pub id: i64,
    pub subject: String,
    pub question_type: QuestionType,
    pub content: String,
    pub options: Vec<String>,
    pub answer: Vec<String>,
    pub explanation: String,
    pub tags: Vec<String>,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QuizRecord {
    pub id: i64,
    pub subject: String,
    pub started_at: String,
    pub finished_at: Option<String>,
    pub duration_secs: i64,
    pub total_count: i32,
    pub correct_count: i32,
    pub wrong_count: i32,
    pub score: f64,
    pub details: Vec<AnswerDetail>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnswerDetail {
    pub question_id: i64,
    pub user_answer: Vec<String>,
    pub is_correct: bool,
    pub answered_at: String,
    pub time_spent_secs: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubjectStats {
    pub subject: String,
    pub total_questions: i32,
    pub total_practice_count: i32,
    pub total_correct: i32,
    pub total_wrong: i32,
    pub avg_score: f64,
    pub total_time_secs: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DailyStats {
    pub date: String,
    pub practice_count: i32,
    pub total_questions: i32,
    pub correct_count: i32,
    pub total_time_secs: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ImportExportData {
    pub version: String,
    pub exported_at: String,
    pub questions: Vec<Question>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AppSettings {
    pub theme_color: String,
    pub dark_mode: bool,
    pub enable_timer: bool,
    pub default_subject: String,
}
