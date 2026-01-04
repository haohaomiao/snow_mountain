extends Node

enum Subject {
    NPC,
}

var progress: Dictionary = {}

func get_next_act_index(day: int, subject: Subject) -> int:
    if not progress.has(day):
        progress[day] = {}

    var day_progress: Dictionary = progress[day]
    if not day_progress.has(subject):
        day_progress[subject] = 0

    return day_progress[subject] as int

func advance(day: int, subject: Subject) -> int:
    if not progress.has(day):
        progress[day] = {}

    var day_progress: Dictionary = progress[day]
    var next_index := (day_progress.get(subject, 0) as int) + 1
    day_progress[subject] = next_index
    return next_index

func get_subject_name(subject: Subject) -> String:
    var subject_name = Subject.find_key(subject)
    if subject_name is String:
        return subject_name
    return ""
