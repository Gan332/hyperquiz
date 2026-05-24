use chrono::Utc;
use crate::models::*;
use crate::database;

pub enum QuizSession {
    Idle,
    Active {
        questions: Vec<Question>,
        current_index: usize,
        answers: Vec<(usize, Vec<String>, i64, String)>, // (q_index, answer, time_spent, answered_at)
        started_at: String,
        subject: String,
    },
}

impl QuizSession {
    pub fn new() -> Self {
        QuizSession::Idle
    }

    pub fn start(&mut self, subject: Option<&str>, question_ids: Option<&[i64]>) -> Result<(), String> {
        let questions = if let Some(ids) = question_ids {
            database::get_questions_by_ids(ids).map_err(|e| e.to_string())?
        } else {
            database::get_all_questions(subject).map_err(|e| e.to_string())?
        };

        if questions.is_empty() {
            return Err("No questions available".to_string());
        }

        *self = QuizSession::Active {
            questions,
            current_index: 0,
            answers: Vec::new(),
            started_at: Utc::now().format("%Y-%m-%dT%H:%M:%S%.3fZ").to_string(),
            subject: subject.unwrap_or("All").to_string(),
        };
        Ok(())
    }

    pub fn current_question(&self) -> Option<&Question> {
        match self {
            QuizSession::Active { questions, current_index, .. } => {
                questions.get(*current_index)
            }
            _ => None,
        }
    }

    pub fn answer_current(&mut self, user_answer: Vec<String>, time_spent_secs: i64) -> Result<(), String> {
        match self {
            QuizSession::Active { current_index, answers, .. } => {
                answers.push((
                    *current_index,
                    user_answer,
                    time_spent_secs,
                    Utc::now().format("%Y-%m-%dT%H:%M:%S%.3fZ").to_string(),
                ));
                *current_index += 1;
                Ok(())
            }
            _ => Err("No active quiz session".to_string()),
        }
    }

    pub fn next_question(&mut self) -> Option<&Question> {
        match self {
            QuizSession::Active { current_index, questions, .. } => {
                *current_index += 1;
                questions.get(*current_index)
            }
            _ => None,
        }
    }

    pub fn prev_question(&mut self) -> Option<&Question> {
        match self {
            QuizSession::Active { current_index, questions, .. } if *current_index > 0 => {
                *current_index -= 1;
                questions.get(*current_index)
            }
            _ => None,
        }
    }

    pub fn progress(&self) -> (usize, usize) {
        match self {
            QuizSession::Active { current_index, questions, .. } => (*current_index, questions.len()),
            _ => (0, 0),
        }
    }

    pub fn finish(&mut self) -> Result<QuizRecord, String> {
        match self {
            QuizSession::Active { questions, answers, started_at, subject, .. } => {
                let total = questions.len() as i32;
                let mut correct_count = 0;
                let mut wrong_count = 0;
                let mut details = Vec::new();
                let mut total_time = 0i64;

                for (q_idx, ans, time, answered_at) in answers.iter() {
                    let q = &questions[*q_idx];
                    let is_correct = is_answer_correct(q, ans);
                    if is_correct {
                        correct_count += 1;
                    } else {
                        wrong_count += 1;
                    }
                    total_time += time;
                    details.push(AnswerDetail {
                        question_id: q.id,
                        user_answer: ans.clone(),
                        is_correct,
                        answered_at: answered_at.clone(),
                        time_spent_secs: *time,
                    });
                }

                let score = if total > 0 {
                    (correct_count as f64 / total as f64) * 100.0
                } else {
                    0.0
                };

                let finished_at = Utc::now().format("%Y-%m-%dT%H:%M:%S%.3fZ").to_string();

                let record = QuizRecord {
                    id: 0,
                    subject: subject.clone(),
                    started_at: started_at.clone(),
                    finished_at: Some(finished_at),
                    duration_secs: total_time,
                    total_count: total,
                    correct_count,
                    wrong_count,
                    score,
                    details,
                };

                *self = QuizSession::Idle;
                Ok(record)
            }
            _ => Err("No active quiz session".to_string()),
        }
    }

    pub fn is_active(&self) -> bool {
        matches!(self, QuizSession::Active { .. })
    }
}

pub fn is_answer_correct(question: &Question, user_answer: &[String]) -> bool {
    let mut correct = question.answer.clone();
    let mut user = user_answer.to_vec();
    correct.sort();
    user.sort();
    correct == user
}

pub fn shuffle_questions(mut questions: Vec<Question>) -> Vec<Question> {
    use rand::seq::SliceRandom;
    let mut rng = rand::thread_rng();
    questions.shuffle(&mut rng);
    questions
}
