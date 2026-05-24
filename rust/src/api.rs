use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use serde_json;
use libc;

use crate::database;
use crate::models::*;
use crate::quiz::QuizSession;

static mut QUIZ_SESSION: Option<QuizSession> = None;

fn get_session() -> &'static mut QuizSession {
    unsafe {
        QUIZ_SESSION.get_or_insert_with(|| QuizSession::new());
        QUIZ_SESSION.as_mut().unwrap()
    }
}

fn c_str_to_string(ptr: *const c_char) -> String {
    if ptr.is_null() {
        return String::new();
    }
    unsafe { CStr::from_ptr(ptr).to_string_lossy().into_owned() }
}

fn string_to_c_str(s: String) -> *mut c_char {
    CString::new(s).unwrap_or_default().into_raw()
}

fn to_json<T: serde::Serialize>(val: &T) -> *mut c_char {
    string_to_c_str(serde_json::to_string(val).unwrap_or_else(|_| "null".to_string()))
}

fn from_json<T: serde::de::DeserializeOwned>(ptr: *const c_char) -> Option<T> {
    let s = c_str_to_string(ptr);
    serde_json::from_str(&s).ok()
}

// Memory management
#[no_mangle]
pub extern "C" fn free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe { let _ = CString::from_raw(s); }
    }
}

// Database
#[no_mangle]
pub extern "C" fn init_database(path: *const c_char) -> i32 {
    match database::init_database(&c_str_to_string(path)) {
        Ok(_) => 0,
        Err(e) => {
            eprintln!("DB init error: {}", e);
            -1
        }
    }
}

// Question CRUD
#[no_mangle]
pub extern "C" fn add_question(json: *const c_char) -> i64 {
    if let Some(q) = from_json::<Question>(json) {
        database::add_question(&q).unwrap_or(-1)
    } else {
        -1
    }
}

#[no_mangle]
pub extern "C" fn update_question(json: *const c_char) -> i32 {
    if let Some(q) = from_json::<Question>(json) {
        match database::update_question(&q) {
            Ok(_) => 0,
            Err(_) => -1,
        }
    } else {
        -1
    }
}

#[no_mangle]
pub extern "C" fn delete_question(id: i64) -> i32 {
    match database::delete_question(id) {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

#[no_mangle]
pub extern "C" fn get_question(id: i64) -> *mut c_char {
    match database::get_question(id) {
        Ok(Some(q)) => to_json(&q),
        _ => std::ptr::null_mut(),
    }
}

#[no_mangle]
pub extern "C" fn get_all_questions(subject: *const c_char) -> *mut c_char {
    let s = c_str_to_string(subject);
    let subject_opt = if s.is_empty() { None } else { Some(s.as_str()) };
    match database::get_all_questions(subject_opt) {
        Ok(questions) => to_json(&questions),
        Err(_) => string_to_c_str("[]".to_string()),
    }
}

#[no_mangle]
pub extern "C" fn get_subjects() -> *mut c_char {
    match database::get_subjects() {
        Ok(subjects) => to_json(&subjects),
        Err(_) => string_to_c_str("[]".to_string()),
    }
}

// Quiz
#[no_mangle]
pub extern "C" fn start_quiz(subject: *const c_char) -> i32 {
    let s = c_str_to_string(subject);
    let subject_opt = if s.is_empty() { None } else { Some(s.as_str()) };
    match get_session().start(subject_opt, None) {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

#[no_mangle]
pub extern "C" fn get_current_question() -> *mut c_char {
    match get_session().current_question() {
        Some(q) => to_json(q),
        None => std::ptr::null_mut(),
    }
}

#[no_mangle]
pub extern "C" fn answer_question(answer_json: *const c_char, time_spent: i64) -> i32 {
    let answers: Vec<String> = serde_json::from_str(&c_str_to_string(answer_json)).unwrap_or_default();
    match get_session().answer_current(answers, time_spent) {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

#[no_mangle]
pub extern "C" fn get_quiz_progress() -> *mut c_char {
    let (current, total) = get_session().progress();
    to_json(&serde_json::json!({"current": current, "total": total}))
}

#[no_mangle]
pub extern "C" fn finish_quiz() -> *mut c_char {
    match get_session().finish() {
        Ok(record) => {
            let rec_id = database::add_record(&record).unwrap_or(-1);
            let mut r = record;
            r.id = rec_id;
            to_json(&r)
        }
        Err(_) => std::ptr::null_mut(),
    }
}

#[no_mangle]
pub extern "C" fn is_quiz_active() -> i32 {
    if get_session().is_active() { 1 } else { 0 }
}

// Records & Stats
#[no_mangle]
pub extern "C" fn get_records(limit: i32) -> *mut c_char {
    match database::get_all_records(limit) {
        Ok(records) => to_json(&records),
        Err(_) => string_to_c_str("[]".to_string()),
    }
}

#[no_mangle]
pub extern "C" fn get_subject_stats() -> *mut c_char {
    match database::get_subject_stats() {
       Ok(stats) => to_json(&stats),
        Err(_) => string_to_c_str("[]".to_string()),
    }
}

#[no_mangle]
pub extern "C" fn get_daily_stats(days: i32) -> *mut c_char {
    match database::get_daily_stats(days) {
        Ok(stats) => to_json(&stats),
        Err(_) => string_to_c_str("[]".to_string()),
    }
}

// Settings
#[no_mangle]
pub extern "C" fn get_setting(key: *const c_char) -> *mut c_char {
    match database::get_setting(&c_str_to_string(key)) {
        Ok(Some(val)) => string_to_c_str(val),
        _ => std::ptr::null_mut(),
    }
}

#[no_mangle]
pub extern "C" fn set_setting(key: *const c_char, value: *const c_char) -> i32 {
    match database::set_setting(&c_str_to_string(key), &c_str_to_string(value)) {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

// Import/Export
#[no_mangle]
pub extern "C" fn import_questions(json: *const c_char) -> i32 {
    let data: ImportExportData = match serde_json::from_str(&c_str_to_string(json)) {
        Ok(d) => d,
        Err(_) => return -1,
    };
    match database::import_questions(&data.questions) {
        Ok(count) => count,
        Err(_) => -1,
    }
}

#[no_mangle]
pub extern "C" fn export_questions(subject: *const c_char) -> *mut c_char {
    let s = c_str_to_string(subject);
    let subject_opt = if s.is_empty() { None } else { Some(s.as_str()) };
    match database::export_questions(subject_opt) {
        Ok(questions) => {
            let data = ImportExportData {
                version: "1.0".to_string(),
                exported_at: chrono::Utc::now().format("%Y-%m-%dT%H:%M:%S%.3fZ").to_string(),
                questions,
            };
            to_json(&data)
        }
        Err(_) => std::ptr::null_mut(),
    }
}
