use rusqlite::{params, Connection, Result};
use std::sync::Mutex;

use crate::models::*;

static DB: once_cell::sync::Lazy<Mutex<Option<Connection>>> =
    once_cell::sync::Lazy::new(|| Mutex::new(None));

pub fn init_database(db_path: &str) -> Result<()> {
    let conn = Connection::open(db_path)?;
    conn.execute_batch("PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;")?;

    conn.execute_batch(
        "CREATE TABLE IF NOT EXISTS questions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT NOT NULL DEFAULT '',
            question_type TEXT NOT NULL DEFAULT 'SingleChoice',
            content TEXT NOT NULL,
            options TEXT NOT NULL DEFAULT '[]',
            answer TEXT NOT NULL DEFAULT '[]',
            explanation TEXT NOT NULL DEFAULT '',
            tags TEXT NOT NULL DEFAULT '[]',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS quiz_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT NOT NULL DEFAULT '',
            started_at TEXT NOT NULL,
            finished_at TEXT,
            duration_secs INTEGER NOT NULL DEFAULT 0,
            total_count INTEGER NOT NULL DEFAULT 0,
            correct_count INTEGER NOT NULL DEFAULT 0,
            wrong_count INTEGER NOT NULL DEFAULT 0,
            score REAL NOT NULL DEFAULT 0.0,
            details TEXT NOT NULL DEFAULT '[]'
        );

        CREATE TABLE IF NOT EXISTS app_settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        );",
    )?;

    let mut db = DB.lock().unwrap();
    *db = Some(conn);
    Ok(())
}

fn with_db<F, T>(f: F) -> Result<T>
where
    F: FnOnce(&Connection) -> Result<T>,
{
    let db = DB.lock().unwrap();
    let conn = db.as_ref().ok_or_else(|| {
        rusqlite::Error::InvalidParameterName("Database not initialized".to_string())
    })?;
    f(conn)
}

// --- Questions CRUD ---

pub fn add_question(q: &Question) -> Result<i64> {
    with_db(|conn| {
        conn.execute(
            "INSERT INTO questions (subject, question_type, content, options, answer, explanation, tags, created_at, updated_at)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
            params![
                q.subject,
                serde_json::to_string(&q.question_type).unwrap(),
                q.content,
                serde_json::to_string(&q.options).unwrap(),
                serde_json::to_string(&q.answer).unwrap(),
                q.explanation,
                serde_json::to_string(&q.tags).unwrap(),
                q.created_at,
                q.updated_at,
            ],
        )?;
        Ok(conn.last_insert_rowid())
    })
}

pub fn update_question(q: &Question) -> Result<()> {
    with_db(|conn| {
        conn.execute(
            "UPDATE questions SET subject=?1, question_type=?2, content=?3, options=?4, answer=?5, explanation=?6, tags=?7, updated_at=?8 WHERE id=?9",
            params![
                q.subject,
                serde_json::to_string(&q.question_type).unwrap(),
                q.content,
                serde_json::to_string(&q.options).unwrap(),
                serde_json::to_string(&q.answer).unwrap(),
                q.explanation,
                serde_json::to_string(&q.tags).unwrap(),
                q.updated_at,
                q.id,
            ],
        )?;
        Ok(())
    })
}

pub fn delete_question(id: i64) -> Result<()> {
    with_db(|conn| {
        conn.execute("DELETE FROM questions WHERE id=?1", params![id])?;
        Ok(())
    })
}

pub fn get_question(id: i64) -> Result<Option<Question>> {
    with_db(|conn| {
        let mut stmt = conn.prepare(
            "SELECT id, subject, question_type, content, options, answer, explanation, tags, created_at, updated_at FROM questions WHERE id=?1",
        )?;
        let mut rows = stmt.query_map(params![id], row_to_question)?;
        Ok(rows.next().transpose()?)
    })
}

pub fn get_all_questions(subject: Option<&str>) -> Result<Vec<Question>> {
    with_db(|conn| {
        let sql = if subject.is_some() {
            "SELECT id, subject, question_type, content, options, answer, explanation, tags, created_at, updated_at FROM questions WHERE subject=?1 ORDER BY created_at DESC"
        } else {
            "SELECT id, subject, question_type, content, options, answer, explanation, tags, created_at, updated_at FROM questions ORDER BY created_at DESC"
        };
        let mut stmt = conn.prepare(sql)?;
        let rows = if let Some(s) = subject {
            stmt.query_map(params![s], row_to_question)?
        } else {
            stmt.query_map([], row_to_question)?
        };
        rows.collect()
    })
}

pub fn get_subjects() -> Result<Vec<String>> {
    with_db(|conn| {
        let mut stmt = conn.prepare("SELECT DISTINCT subject FROM questions ORDER BY subject")?;
        let rows = stmt.query_map([], |row| row.get::<_, String>(0))?;
        rows.collect()
    })
}

pub fn get_questions_by_ids(ids: &[i64]) -> Result<Vec<Question>> {
    if ids.is_empty() {
        return Ok(vec![]);
    }
    with_db(|conn| {
        let placeholders: Vec<String> = ids.iter().map(|_| "?".to_string()).collect();
        let sql = format!(
            "SELECT id, subject, question_type, content, options, answer, explanation, tags, created_at, updated_at FROM questions WHERE id IN ({}) ORDER BY RANDOM()",
            placeholders.join(",")
        );
        let mut stmt = conn.prepare(&sql)?;
        let params: Vec<&dyn rusqlite::types::ToSql> =
            ids.iter().map(|id| id as &dyn rusqlite::types::ToSql).collect();
        let rows = stmt.query_map(params.as_slice(), row_to_question)?;
        rows.collect()
    })
}

fn row_to_question(row: &rusqlite::Row) -> rusqlite::Result<Question> {
    let qtype_str: String = row.get(2)?;
    let options_str: String = row.get(4)?;
    let answer_str: String = row.get(5)?;
    let tags_str: String = row.get(7)?;

    Ok(Question {
        id: row.get(0)?,
        subject: row.get(1)?,
        question_type: serde_json::from_str(&qtype_str).unwrap_or(QuestionType::SingleChoice),
        content: row.get(3)?,
        options: serde_json::from_str(&options_str).unwrap_or_default(),
        answer: serde_json::from_str(&answer_str).unwrap_or_default(),
        explanation: row.get(6)?,
        tags: serde_json::from_str(&tags_str).unwrap_or_default(),
        created_at: row.get(8)?,
        updated_at: row.get(9)?,
    })
}

// --- Records ---

pub fn add_record(r: &QuizRecord) -> Result<i64> {
    with_db(|conn| {
        conn.execute(
            "INSERT INTO quiz_records (subject, started_at, finished_at, duration_secs, total_count, correct_count, wrong_count, score, details)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
            params![
                r.subject,
                r.started_at,
                r.finished_at,
                r.duration_secs,
                r.total_count,
                r.correct_count,
                r.wrong_count,
                r.score,
                serde_json::to_string(&r.details).unwrap(),
            ],
        )?;
        Ok(conn.last_insert_rowid())
    })
}

pub fn get_all_records(limit: i32) -> Result<Vec<QuizRecord>> {
    with_db(|conn| {
        let mut stmt = conn.prepare(
            "SELECT id, subject, started_at, finished_at, duration_secs, total_count, correct_count, wrong_count, score, details
             FROM quiz_records ORDER BY started_at DESC LIMIT ?1",
        )?;
        let rows = stmt.query_map(params![limit], row_to_record)?;
        rows.collect()
    })
}

pub fn get_records_by_subject(subject: &str) -> Result<Vec<QuizRecord>> {
    with_db(|conn| {
        let mut stmt = conn.prepare(
            "SELECT id, subject, started_at, finished_at, duration_secs, total_count, correct_count, wrong_count, score, details
             FROM quiz_records WHERE subject=?1 ORDER BY started_at DESC",
        )?;
        let rows = stmt.query_map(params![subject], row_to_record)?;
        rows.collect()
    })
}

fn row_to_record(row: &rusqlite::Row) -> rusqlite::Result<QuizRecord> {
    let details_str: String = row.get(9)?;
    Ok(QuizRecord {
        id: row.get(0)?,
        subject: row.get(1)?,
        started_at: row.get(2)?,
        finished_at: row.get(3)?,
        duration_secs: row.get(4)?,
        total_count: row.get(5)?,
        correct_count: row.get(6)?,
        wrong_count: row.get(7)?,
        score: row.get(8)?,
        details: serde_json::from_str(&details_str).unwrap_or_default(),
    })
}

// --- Statistics ---

pub fn get_subject_stats() -> Result<Vec<SubjectStats>> {
    with_db(|conn| {
        let mut stmt = conn.prepare(
            "SELECT subject,
                    COUNT(*) as total_q,
                    COALESCE((SELECT COUNT(*) FROM quiz_records WHERE subject=q.subject), 0) as practice_count,
                    COALESCE((SELECT SUM(correct_count) FROM quiz_records WHERE subject=q.subject), 0) as total_correct,
                    COALESCE((SELECT SUM(wrong_count) FROM quiz_records WHERE subject=q.subject), 0) as total_wrong,
                    COALESCE((SELECT AVG(score) FROM quiz_records WHERE subject=q.subject), 0.0) as avg_score,
                    COALESCE((SELECT SUM(duration_secs) FROM quiz_records WHERE subject=q.subject), 0) as total_time
             FROM questions q
             GROUP BY subject",
        )?;
        let rows = stmt.query_map([], |row| {
            Ok(SubjectStats {
                subject: row.get(0)?,
                total_questions: row.get(1)?,
                total_practice_count: row.get(2)?,
                total_correct: row.get(3)?,
                total_wrong: row.get(4)?,
                avg_score: row.get(5)?,
                total_time_secs: row.get(6)?,
            })
        })?;
        rows.collect()
    })
}

pub fn get_daily_stats(days: i32) -> Result<Vec<DailyStats>> {
    with_db(|conn| {
        let mut stmt = conn.prepare(
            "SELECT DATE(started_at) as day,
                    COUNT(*) as practice_count,
                    SUM(total_count) as total_q,
                    SUM(correct_count) as correct,
                    SUM(duration_secs) as total_time
             FROM quiz_records
             WHERE started_at >= DATE('now', ?1)
             GROUP BY day
             ORDER BY day ASC",
        )?;
        let offset = format!("-{} days", days);
        let rows = stmt.query_map(params![offset], |row| {
            Ok(DailyStats {
                date: row.get(0)?,
                practice_count: row.get(1)?,
                total_questions: row.get(2)?,
                correct_count: row.get(3)?,
                total_time_secs: row.get(4)?,
            })
        })?;
        rows.collect()
    })
}

// --- Settings ---

pub fn get_setting(key: &str) -> Result<Option<String>> {
    with_db(|conn| {
        let mut stmt = conn.prepare("SELECT value FROM app_settings WHERE key=?1")?;
        let mut rows = stmt.query_map(params![key], |row| row.get::<_, String>(0))?;
        Ok(rows.next().transpose()?)
    })
}

pub fn set_setting(key: &str, value: &str) -> Result<()> {
    with_db(|conn| {
        conn.execute(
            "INSERT OR REPLACE INTO app_settings (key, value) VALUES (?1, ?2)",
            params![key, value],
        )?;
        Ok(())
    })
}

pub fn import_questions(questions: &[Question]) -> Result<i32> {
    let mut count = 0;
    for q in questions {
        add_question(q)?;
        count += 1;
    }
    Ok(count)
}

pub fn export_questions(subject: Option<&str>) -> Result<Vec<Question>> {
    get_all_questions(subject)
}
