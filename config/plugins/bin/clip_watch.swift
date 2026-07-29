// clip_watch — polls NSPasteboard changeCount, triggers clip_captured on change.
// Zero-latency clipboard detection without polling sketchybar's routine event.
import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

var lastCount = NSPasteboard.general.changeCount

signal(SIGTERM) { _ in exit(0) }
signal(SIGINT) { _ in exit(0) }

Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
    let current = NSPasteboard.general.changeCount
    if current != lastCount {
        lastCount = current
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = ["sketchybar", "--trigger", "clip_captured"]
        try? task.run()
    }
}

app.run()
