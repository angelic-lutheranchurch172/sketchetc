// Prints: mouseX mouseYFromTop leftClickCount screenHeight
// Reading mouse state needs no Accessibility permission (only posting does).
import AppKit
import CoreGraphics

let loc = NSEvent.mouseLocation
let screenH = NSScreen.screens.map { $0.frame.maxY }.max() ?? 0
let clicks = CGEventSource.counterForEventType(.combinedSessionState, eventType: .leftMouseDown)
// Cocoa origin is bottom-left; report Y as distance from the TOP of the screen
print("\(Int(loc.x)) \(Int(screenH - loc.y)) \(clicks) \(Int(screenH))")
