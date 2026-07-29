// release_win <RELEASES.md> [sinceVersion] <bgHex> <panelHex> <a1Hex> <a2Hex>
// "What shipped" window: renders release notes, optionally only the versions
// newer than sinceVersion.
import AppKit

guard CommandLine.arguments.count >= 6 else { print("usage: release_win notes since bg panel a1 a2"); exit(2) }
let notesPath = CommandLine.arguments[1]
let since = CommandLine.arguments[2]

func color(_ hex: String) -> NSColor {
    var h = hex.replacingOccurrences(of: "0x", with: "")
    if h.count == 8 { h = String(h.dropFirst(2)) }
    let v = UInt32(h, radix: 16) ?? 0x222222
    return NSColor(calibratedRed: CGFloat((v >> 16) & 0xFF) / 255,
                   green: CGFloat((v >> 8) & 0xFF) / 255,
                   blue: CGFloat(v & 0xFF) / 255, alpha: 1)
}
let bg = color(CommandLine.arguments[3])
let panel = color(CommandLine.arguments[4])
let accent1 = color(CommandLine.arguments[5])
let accent2 = color(CommandLine.arguments[6])
let textC = NSColor(calibratedWhite: 0.93, alpha: 1)
let dimC = NSColor(calibratedWhite: 1, alpha: 0.45)
let mono = NSFont(name: "JetBrainsMono Nerd Font", size: 12) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)

func vNum(_ s: String) -> [Int] { s.split(separator: ".").map { Int($0) ?? 0 } }
func newer(_ a: String, _ b: String) -> Bool {   // a > b ?
    let x = vNum(a), y = vNum(b)
    for i in 0..<max(x.count, y.count) {
        let l = i < x.count ? x[i] : 0, r = i < y.count ? y[i] : 0
        if l != r { return l > r }
    }
    return false
}

// ---- parse the notes into (version, headline, bullets) ----
struct Rel { let version: String; let headline: String; var bullets: [String] }
var rels: [Rel] = []
for raw in ((try? String(contentsOfFile: notesPath, encoding: .utf8)) ?? "").components(separatedBy: "\n") {
    if raw.hasPrefix("## ") {
        let body = String(raw.dropFirst(3))
        let parts = body.components(separatedBy: "—")
        let v = parts[0].trimmingCharacters(in: .whitespaces)
        let head = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : ""
        rels.append(Rel(version: v, headline: head, bullets: []))
    } else if raw.trimmingCharacters(in: .whitespaces).hasPrefix("-"), !rels.isEmpty {
        var b = raw.trimmingCharacters(in: .whitespaces)
        b.removeFirst()
        rels[rels.count - 1].bullets.append(b.trimmingCharacters(in: .whitespaces))
    }
}
if !since.isEmpty { rels = rels.filter { newer($0.version, since) } }
if rels.isEmpty { rels = [Rel(version: "", headline: "You are up to date", bullets: [])] }

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let W: CGFloat = 560, H: CGFloat = 520, PAD: CGFloat = 22

final class Ctl: NSObject { @objc func close() { exit(0) } }
let ctl = Ctl()

let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: W, height: H),
                   styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
win.titleVisibility = .hidden
win.titlebarAppearsTransparent = true
win.isMovableByWindowBackground = true
win.level = .floating
win.center()
win.backgroundColor = bg
win.appearance = NSAppearance(named: .darkAqua)
let content = win.contentView!

let title = NSTextField(labelWithString: "What shipped")
title.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 15) ?? .boldSystemFont(ofSize: 15)
title.textColor = accent1
title.frame = NSRect(x: 96, y: H - 40, width: 300, height: 20)
content.addSubview(title)

let scroll = NSScrollView(frame: NSRect(x: PAD, y: 58, width: W - 2 * PAD, height: H - 118))
scroll.hasVerticalScroller = true
scroll.borderType = .noBorder
scroll.wantsLayer = true
scroll.layer?.cornerRadius = 10
let tv = NSTextView(frame: NSRect(origin: .zero, size: scroll.frame.size))
tv.autoresizingMask = [.width]
tv.backgroundColor = panel
tv.isEditable = false
tv.textContainerInset = NSSize(width: 16, height: 16)

let body = NSMutableAttributedString()
for r in rels {
    let head = NSMutableParagraphStyle(); head.paragraphSpacingBefore = 10; head.paragraphSpacing = 6
    if !r.version.isEmpty {
        body.append(NSAttributedString(string: "v\(r.version)  ", attributes: [
            .font: NSFont(name: "JetBrainsMono Nerd Font Bold", size: 15) ?? .boldSystemFont(ofSize: 15),
            .foregroundColor: accent1, .paragraphStyle: head]))
    }
    body.append(NSAttributedString(string: r.headline + "\n", attributes: [
        .font: NSFont.systemFont(ofSize: 14), .foregroundColor: textC, .paragraphStyle: head]))
    for b in r.bullets {
        let p = NSMutableParagraphStyle(); p.headIndent = 20; p.firstLineHeadIndent = 4; p.paragraphSpacing = 4
        body.append(NSAttributedString(string: "•  ", attributes: [.foregroundColor: accent2, .paragraphStyle: p]))
        // strip markdown bold markers, keep it readable
        let clean = b.replacingOccurrences(of: "**", with: "")
        body.append(NSAttributedString(string: clean + "\n", attributes: [
            .font: NSFont.systemFont(ofSize: 13), .foregroundColor: textC, .paragraphStyle: p]))
    }
}
tv.textStorage?.setAttributedString(body)
scroll.documentView = tv
content.addSubview(scroll)

let hint = NSTextField(labelWithString: "sketchetc · updates arrive as a pill in your bar")
hint.font = mono
hint.textColor = dimC
hint.frame = NSRect(x: PAD, y: 20, width: W - 160, height: 16)
content.addSubview(hint)

let done = NSButton(title: "Nice", target: ctl, action: #selector(Ctl.close))
done.bezelStyle = .rounded
done.keyEquivalent = "\r"
done.frame = NSRect(x: W - PAD - 96, y: 14, width: 96, height: 28)
content.addSubview(done)

win.makeKeyAndOrderFront(nil)
NSApp.activate(ignoringOtherApps: true)
app.run()
exit(0)
