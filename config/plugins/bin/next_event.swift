// Prints "epoch|title|meetlink" for the next non-all-day calendar event within
// 12h, or NONE / NOACCESS. Calendar permission is requested on first run
// (granted to sketchybar, the responsible process).
import EventKit
import Foundation

let store = EKEventStore()
let sem = DispatchSemaphore(value: 0)
var ok = false
if #available(macOS 14.0, *) {
    store.requestFullAccessToEvents { granted, _ in ok = granted; sem.signal() }
} else {
    store.requestAccess(to: .event) { granted, _ in ok = granted; sem.signal() }
}
_ = sem.wait(timeout: .now() + 10)
guard ok else { print("NOACCESS"); exit(0) }

let now = Date()
let pred = store.predicateForEvents(withStart: now, end: now.addingTimeInterval(12 * 3600), calendars: nil)
let events = store.events(matching: pred)
    .filter { !$0.isAllDay }
    .sorted { $0.startDate < $1.startDate }
guard let e = events.first else { print("NONE"); exit(0) }

let haystack = [(e.notes ?? ""), (e.location ?? ""), (e.url?.absoluteString ?? "")].joined(separator: " ")
var link = ""
if let r = haystack.range(of: #"https://[^\s<>"]*(zoom\.us|meet\.google\.com|teams\.microsoft\.com|webex\.com)[^\s<>"]*"#,
                          options: .regularExpression) {
    link = String(haystack[r])
}
let title = (e.title ?? "Meeting").replacingOccurrences(of: "|", with: "-")
print("\(Int(e.startDate.timeIntervalSince1970))|\(title)|\(link)")
