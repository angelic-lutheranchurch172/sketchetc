// entry_box <title> [placeholder] — centered dark editor window (720x520),
// monospace text view with padding. Prints entered text on OK, exits 1 on cancel.
import AppKit

let title = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Entry"
let placeholder = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : ""

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let W: CGFloat = 720, H: CGFloat = 520, PAD: CGFloat = 24

let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: W, height: H),
                   styleMask: [.titled, .fullSizeContentView],
                   backing: .buffered, defer: false)
win.titleVisibility = .hidden
win.titlebarAppearsTransparent = true
win.isMovableByWindowBackground = true
win.level = .floating
win.center()
win.backgroundColor = NSColor(calibratedRed: 0.09, green: 0.05, blue: 0.16, alpha: 1)
win.appearance = NSAppearance(named: .darkAqua)

let content = win.contentView!

let titleLabel = NSTextField(labelWithString: title)
titleLabel.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
titleLabel.textColor = NSColor(calibratedRed: 1.0, green: 0.43, blue: 0.78, alpha: 1)
titleLabel.frame = NSRect(x: PAD, y: H - 52, width: W - 2 * PAD, height: 24)
content.addSubview(titleLabel)

let scroll = NSScrollView(frame: NSRect(x: PAD, y: 76, width: W - 2 * PAD, height: H - 148))
scroll.hasVerticalScroller = true
scroll.borderType = .noBorder
scroll.wantsLayer = true
scroll.layer?.cornerRadius = 10
let tv = NSTextView(frame: scroll.bounds)
tv.autoresizingMask = [.width]
tv.font = NSFont(name: "JetBrainsMono Nerd Font", size: 14) ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
tv.backgroundColor = NSColor(calibratedRed: 0.14, green: 0.09, blue: 0.25, alpha: 1)
tv.textColor = NSColor(calibratedWhite: 0.93, alpha: 1)
tv.insertionPointColor = NSColor(calibratedRed: 1.0, green: 0.43, blue: 0.78, alpha: 1)
tv.textContainerInset = NSSize(width: 14, height: 14)
tv.isRichText = false
tv.string = placeholder
scroll.documentView = tv
content.addSubview(scroll)

var result: String? = nil

let ok = NSButton(title: "Add", target: nil, action: nil)
let cancel = NSButton(title: "Cancel", target: nil, action: nil)
ok.bezelStyle = .rounded; cancel.bezelStyle = .rounded
ok.keyEquivalent = "\r"
cancel.keyEquivalent = "\u{1b}"
ok.frame = NSRect(x: W - PAD - 90, y: PAD, width: 90, height: 32)
cancel.frame = NSRect(x: W - PAD - 190, y: PAD, width: 90, height: 32)

class Handler: NSObject {
    var tv: NSTextView
    var done: (String?) -> Void
    init(tv: NSTextView, done: @escaping (String?) -> Void) { self.tv = tv; self.done = done }
    @objc func ok() { done(tv.string) }
    @objc func cancel() { done(nil) }
}
let handler = Handler(tv: tv) { text in
    result = text
    app.stop(nil)
}
ok.target = handler; ok.action = #selector(Handler.ok)
cancel.target = handler; cancel.action = #selector(Handler.cancel)
content.addSubview(ok); content.addSubview(cancel)

win.makeKeyAndOrderFront(nil)
win.makeFirstResponder(tv)
NSApp.activate(ignoringOtherApps: true)
app.run()

if let r = result { print(r); exit(0) } else { exit(1) }
