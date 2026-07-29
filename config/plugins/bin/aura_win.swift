// aura_win <auraDir> <bgHex> <panelHex> <a1Hex> <a2Hex>
// Aura as a window: today / 7 / 30 / all totals, a 14-day chart, streak, and
// the export buttons that render shareable PNG cards.
import AppKit

guard CommandLine.arguments.count >= 6 else { print("usage: aura_win dir bg panel a1 a2"); exit(2) }
let auraDir = CommandLine.arguments[1]

func color(_ hex: String) -> NSColor {
    var h = hex.replacingOccurrences(of: "0x", with: "")
    if h.count == 8 { h = String(h.dropFirst(2)) }
    let v = UInt32(h, radix: 16) ?? 0x222222
    return NSColor(calibratedRed: CGFloat((v >> 16) & 0xFF) / 255,
                   green: CGFloat((v >> 8) & 0xFF) / 255,
                   blue: CGFloat(v & 0xFF) / 255, alpha: 1)
}
let bg = color(CommandLine.arguments[2])
let panel = color(CommandLine.arguments[3])
let accent1 = color(CommandLine.arguments[4])
let accent2 = color(CommandLine.arguments[5])
let textC = NSColor(calibratedWhite: 0.93, alpha: 1)
let dimC = NSColor(calibratedWhite: 1, alpha: 0.45)
let mono = NSFont(name: "JetBrainsMono Nerd Font", size: 12) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)

// ---- totals from the monthly CSVs (date,points,kind,...) ----
var perDay: [String: Int] = [:]
let fm = FileManager.default
for f in ((try? fm.contentsOfDirectory(atPath: auraDir)) ?? []) where f.hasSuffix(".csv") {
    for line in ((try? String(contentsOfFile: auraDir + "/" + f, encoding: .utf8)) ?? "").components(separatedBy: "\n") {
        let c = line.components(separatedBy: ",")
        if c.count >= 2, let p = Int(c[1]) { perDay[c[0], default: 0] += p }
    }
}
let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
let today = Calendar.current.startOfDay(for: Date())
func key(_ d: Date) -> String { df.string(from: d) }
func day(_ back: Int) -> Int { perDay[key(today.addingTimeInterval(Double(-back) * 86400))] ?? 0 }
let tToday = day(0)
let t7 = (0..<7).reduce(0) { $0 + day($1) }
let t30 = (0..<30).reduce(0) { $0 + day($1) }
let tAll = perDay.values.reduce(0, +)
var streak = 0
while day(streak) > 0 { streak += 1 }

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let W: CGFloat = 620, H: CGFloat = 470, PAD: CGFloat = 22

final class Ctl: NSObject {
    @objc func export(_ b: NSButton) {
        let range = b.identifier?.rawValue ?? "week"
        let p = Process()
        p.launchPath = "/bin/bash"
        p.arguments = ["-c", "CONFIG_DIR=\"$HOME/.config/sketchybar\" \"$HOME/.config/sketchybar/plugins/aura_export.sh\" \(range)"]
        try? p.run()
        b.title = "exporting…"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { b.title = range }
    }
    @objc func close() { exit(0) }
}
let ctl = Ctl()

final class Chart: NSView {
    override func draw(_ r: NSRect) {
        let vals = (0..<14).map { day(13 - $0) }
        let maxV = max(vals.max() ?? 1, 1)
        let bw = bounds.width / CGFloat(vals.count)
        for (i, v) in vals.enumerated() {
            let h = max(3, bounds.height * CGFloat(v) / CGFloat(maxV))
            let rect = NSRect(x: CGFloat(i) * bw + bw * 0.18, y: 0, width: bw * 0.64, height: h)
            let p = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
            (i == vals.count - 1 ? accent1 : accent1.withAlphaComponent(0.4)).setFill()
            p.fill()
        }
    }
}

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

let title = NSTextField(labelWithString: "Aura")
title.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 15) ?? .boldSystemFont(ofSize: 15)
title.textColor = accent1
title.frame = NSRect(x: 96, y: H - 38, width: 120, height: 20)
content.addSubview(title)

let sub = NSTextField(labelWithString: streak > 1 ? "\(streak) day streak · keep it alive" : "every pomodoro counts")
sub.font = mono; sub.textColor = dimC
sub.frame = NSRect(x: 176, y: H - 36, width: 360, height: 16)
content.addSubview(sub)

let stats: [(String, Int)] = [("today", tToday), ("7 days", t7), ("30 days", t30), ("all time", tAll)]
let tw = (W - 2 * PAD - 30) / 4
for (i, s) in stats.enumerated() {
    let card = NSView(frame: NSRect(x: PAD + CGFloat(i) * (tw + 10), y: H - 152, width: tw, height: 92))
    card.wantsLayer = true
    card.layer?.backgroundColor = panel.cgColor
    card.layer?.cornerRadius = 10
    let v = NSTextField(labelWithString: "\(s.1)")
    v.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 25) ?? .boldSystemFont(ofSize: 25)
    v.textColor = i == 0 ? accent1 : textC
    v.alignment = .center
    v.frame = NSRect(x: 0, y: 34, width: tw, height: 32)
    card.addSubview(v)
    let l = NSTextField(labelWithString: s.0)
    l.font = mono; l.textColor = dimC; l.alignment = .center
    l.frame = NSRect(x: 0, y: 14, width: tw, height: 16)
    card.addSubview(l)
    content.addSubview(card)
}

let chartWrap = NSView(frame: NSRect(x: PAD, y: 132, width: W - 2 * PAD, height: 128))
chartWrap.wantsLayer = true
chartWrap.layer?.backgroundColor = panel.cgColor
chartWrap.layer?.cornerRadius = 10
let cl = NSTextField(labelWithString: "last 14 days")
cl.font = mono; cl.textColor = dimC
cl.frame = NSRect(x: 14, y: 102, width: 200, height: 16)
chartWrap.addSubview(cl)
chartWrap.addSubview(Chart(frame: NSRect(x: 14, y: 14, width: chartWrap.frame.width - 28, height: 82)))
content.addSubview(chartWrap)

let el = NSTextField(labelWithString: "export a shareable card")
el.font = mono; el.textColor = accent2
el.frame = NSRect(x: PAD, y: 98, width: 300, height: 16)
content.addSubview(el)

for (i, r) in ["day", "week", "month", "year"].enumerated() {
    let b = NSButton(title: r, target: ctl, action: #selector(Ctl.export(_:)))
    b.identifier = NSUserInterfaceItemIdentifier(r)
    b.bezelStyle = .rounded
    b.font = mono
    b.frame = NSRect(x: PAD + CGFloat(i) * ((W - 2 * PAD) / 4), y: 56, width: (W - 2 * PAD) / 4 - 8, height: 30)
    content.addSubview(b)
}

let hint = NSTextField(labelWithString: "cards land in ~/Downloads")
hint.font = mono; hint.textColor = dimC
hint.frame = NSRect(x: PAD, y: 20, width: 320, height: 16)
content.addSubview(hint)

let done = NSButton(title: "Close", target: ctl, action: #selector(Ctl.close))
done.bezelStyle = .rounded
done.keyEquivalent = "\u{1b}"
done.frame = NSRect(x: W - PAD - 96, y: 14, width: 96, height: 28)
content.addSubview(done)

win.makeKeyAndOrderFront(nil)
NSApp.activate(ignoringOtherApps: true)
app.run()
exit(0)
