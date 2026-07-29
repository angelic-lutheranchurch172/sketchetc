// theme_win <themesDir> <activeTheme> <activeIconset> <bgHex> <panelHex> <a1Hex> <a2Hex>
// Theme Studio: browse themes (swatch strips), edit every color with native
// color wells, save custom themes, delete them, and switch iconsets.
import AppKit

guard CommandLine.arguments.count >= 8 else { print("usage: theme_win dir active iconset bg panel a1 a2"); exit(2) }
let themesDir = CommandLine.arguments[1]
var activeTheme = CommandLine.arguments[2]
let activeIconset = CommandLine.arguments[3]

func color(_ hex: String) -> NSColor {
    var h = hex.replacingOccurrences(of: "0x", with: "")
    if h.count == 8 { h = String(h.dropFirst(2)) }
    let v = UInt32(h, radix: 16) ?? 0x222222
    return NSColor(calibratedRed: CGFloat((v >> 16) & 0xFF) / 255,
                   green: CGFloat((v >> 8) & 0xFF) / 255,
                   blue: CGFloat(v & 0xFF) / 255, alpha: 1)
}
func hexRGB(_ c: NSColor) -> String {
    let r = c.usingColorSpace(.deviceRGB) ?? c
    return String(format: "%02x%02x%02x",
                  Int(round(r.redComponent * 255)), Int(round(r.greenComponent * 255)), Int(round(r.blueComponent * 255)))
}

let bg = color(CommandLine.arguments[4])
let panel = color(CommandLine.arguments[5])
let accent1 = color(CommandLine.arguments[6])
let accent2 = color(CommandLine.arguments[7])
let textC = NSColor(calibratedWhite: 0.93, alpha: 1)
let dimC = NSColor(calibratedWhite: 1, alpha: 0.5)
let mono = NSFont(name: "JetBrainsMono Nerd Font", size: 12.5) ?? .monospacedSystemFont(ofSize: 12.5, weight: .regular)

let ROLES: [(key: String, label: String)] = [
    ("BAR_COLOR", "bar background"), ("ITEM_BG_COLOR", "item pill"),
    ("POPUP_BG", "popup background"), ("POPUP_BORDER", "popup border"),
    ("PINK", "accent 1"), ("CYAN", "accent 2"), ("ORANGE", "warning"),
    ("RED", "critical"), ("PURPLE", "glow"), ("WHITE", "text"),
]
let BUILTIN = ["vice-city", "cyberpunk", "matrix", "catppuccin", "miami-sunset"]

struct Theme { var name: String; var colors: [String: String] }   // VAR -> 0xAARRGGBB

func loadThemes() -> [Theme] {
    let fm = FileManager.default
    let names = ((try? fm.contentsOfDirectory(atPath: themesDir)) ?? []).filter { $0.hasSuffix(".sh") }.sorted()
    return names.compactMap { f in
        guard let src = try? String(contentsOfFile: themesDir + "/" + f, encoding: .utf8) else { return nil }
        var colors: [String: String] = [:]
        for line in src.components(separatedBy: "\n") where line.hasPrefix("export ") {
            let kv = line.dropFirst(7).components(separatedBy: "=")
            guard kv.count == 2 else { continue }
            // values carry trailing comments ("0xffff6ec7   # accent 1") — keep the token only
            let val = kv[1].components(separatedBy: "#")[0]
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: " ")[0]
            if !val.isEmpty { colors[kv[0]] = val }
        }
        return Theme(name: String(f.dropLast(3)), colors: colors)
    }
}
var themes = loadThemes()

func shell(_ cmd: String) {
    let p = Process()
    p.launchPath = "/bin/bash"
    p.arguments = ["-c", cmd]
    try? p.run()
}

func writeTheme(_ t: Theme) {
    var out = "#!/bin/bash\n# \(t.name) · made in Theme Studio\n"
    for (k, _) in ROLES { out += "export \(k)=\(t.colors[k] ?? "0xffffffff")\n" }
    try? out.write(toFile: themesDir + "/" + t.name + ".sh", atomically: true, encoding: .utf8)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let W: CGFloat = 780, H: CGFloat = 560, PAD: CGFloat = 20, LIST_W: CGFloat = 240

// theme-colored selection instead of the system accent
final class Row: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        guard isSelected else { return }
        let r = bounds.insetBy(dx: 3, dy: 2)
        let p = NSBezierPath(roundedRect: r, xRadius: 8, yRadius: 8)
        accent1.withAlphaComponent(0.22).setFill(); p.fill()
        accent1.withAlphaComponent(0.9).setStroke(); p.lineWidth = 1.5; p.stroke()
    }
}

final class Ctl: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var table: NSTableView!
    var wells: [String: NSColorWell] = [:]
    var nameField: NSTextField!
    var deleteBtn: NSButton!
    var current: Int = 0

    func numberOfRows(in t: NSTableView) -> Int { themes.count }
    func tableView(_ t: NSTableView, heightOfRow r: Int) -> CGFloat { 34 }
    func tableView(_ t: NSTableView, rowViewForRow r: Int) -> NSTableRowView? { Row() }
    func tableView(_ t: NSTableView, viewFor c: NSTableColumn?, row r: Int) -> NSView? {
        let th = themes[r]
        let cell = NSView(frame: NSRect(x: 0, y: 0, width: LIST_W - 20, height: 34))
        let mark = NSTextField(labelWithString: th.name == activeTheme ? "●" : " ")
        mark.font = mono; mark.textColor = accent1
        mark.frame = NSRect(x: 4, y: 9, width: 14, height: 16)
        cell.addSubview(mark)
        let l = NSTextField(labelWithString: th.name)
        l.font = mono; l.textColor = textC
        l.lineBreakMode = .byTruncatingTail
        l.frame = NSRect(x: 20, y: 9, width: 118, height: 16)
        cell.addSubview(l)
        for (i, key) in ["PINK", "CYAN", "ORANGE", "PURPLE", "BAR_COLOR"].enumerated() {
            let sw = NSView(frame: NSRect(x: 142 + CGFloat(i) * 15, y: 11, width: 11, height: 11))
            sw.wantsLayer = true
            sw.layer?.backgroundColor = color(th.colors[key] ?? "0xff888888").cgColor
            sw.layer?.cornerRadius = 5.5
            cell.addSubview(sw)
        }
        return cell
    }
    func tableViewSelectionDidChange(_ n: Notification) {
        guard table.selectedRow >= 0 else { return }
        current = table.selectedRow
        let th = themes[current]
        nameField.stringValue = th.name
        for (k, _) in ROLES { wells[k]?.color = color(th.colors[k] ?? "0xff888888") }
        deleteBtn.isEnabled = !BUILTIN.contains(th.name)
    }

    func collect(named: String) -> Theme {
        var t = themes[current]
        for (k, _) in ROLES {
            let old = t.colors[k] ?? "0xffffffff"
            let alpha = old.count >= 4 ? String(old.dropFirst(2).prefix(2)) : "ff"
            t.colors[k] = "0x" + alpha + hexRGB(wells[k]!.color)
        }
        t.name = named
        return t
    }
    @objc func apply() {
        var name = themes[current].name
        if BUILTIN.contains(name) {
            // never mutate shipped themes: fork
            let edited = collect(named: name)
            if edited.colors != themes[current].colors { name += "-custom" }
        }
        let t = collect(named: name)
        writeTheme(t)
        shell("echo '\(t.name)' > \"$HOME/.config/sketchybar/.theme\"; sketchybar --reload")
        activeTheme = t.name
        themes = loadThemes()
        table.reloadData()
    }
    @objc func saveAs() {
        var n = nameField.stringValue.trimmingCharacters(in: .whitespaces)
            .lowercased().replacingOccurrences(of: " ", with: "-")
        if n.isEmpty { n = "custom" }
        if BUILTIN.contains(n) { n += "-custom" }
        let t = collect(named: n)
        writeTheme(t)
        themes = loadThemes()
        table.reloadData()
        if let i = themes.firstIndex(where: { $0.name == n }) {
            table.selectRowIndexes([i], byExtendingSelection: false)
        }
    }
    @objc func deleteTheme() {
        let th = themes[current]
        guard !BUILTIN.contains(th.name) else { return }
        try? FileManager.default.removeItem(atPath: themesDir + "/" + th.name + ".sh")
        if activeTheme == th.name {
            shell("echo 'vice-city' > \"$HOME/.config/sketchybar/.theme\"; sketchybar --reload")
            activeTheme = "vice-city"
        }
        themes = loadThemes()
        table.reloadData()
        table.selectRowIndexes([0], byExtendingSelection: false)
    }
    @objc func setIconset(_ b: NSButton) {
        shell("echo '\(b.alternateTitle)' > \"$HOME/.config/sketchybar/.iconset\"; sketchybar --reload")
    }
    @objc func doClose() { exit(0) }
}
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

let title = NSTextField(labelWithString: "Theme Studio")
title.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
title.textColor = accent1
title.frame = NSRect(x: 96, y: H - 42, width: 300, height: 22)
content.addSubview(title)

let col = NSTableColumn(identifier: .init("t")); col.width = LIST_W - 20
let table = NSTableView()
table.headerView = nil
table.backgroundColor = panel
table.addTableColumn(col)
table.dataSource = ctl
table.delegate = ctl
let scroll = NSScrollView(frame: NSRect(x: PAD, y: PAD, width: LIST_W, height: H - 60 - PAD))
scroll.documentView = table
scroll.hasVerticalScroller = true
scroll.wantsLayer = true
scroll.layer?.cornerRadius = 10
scroll.drawsBackground = true
scroll.backgroundColor = panel
content.addSubview(scroll)

let dX = PAD + LIST_W + 18, dW = W - dX - PAD
let detail = NSView(frame: NSRect(x: dX, y: PAD, width: dW, height: H - 60 - PAD))
detail.wantsLayer = true
detail.layer?.backgroundColor = panel.cgColor
detail.layer?.cornerRadius = 10
content.addSubview(detail)

let nameField = NSTextField(frame: NSRect(x: 20, y: detail.frame.height - 46, width: dW - 40, height: 24))
nameField.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 15) ?? .boldSystemFont(ofSize: 15)
nameField.textColor = textC
nameField.backgroundColor = .clear
nameField.isBordered = false
nameField.focusRingType = .none
nameField.placeholderString = "theme name"
detail.addSubview(nameField)

var wells: [String: NSColorWell] = [:]
let colW = (dW - 60) / 2
for (i, role) in ROLES.enumerated() {
    let cx: CGFloat = i < 5 ? 20 : 40 + colW
    let cy = detail.frame.height - 92 - CGFloat(i % 5) * 44
    let well = NSColorWell(frame: NSRect(x: cx, y: cy, width: 44, height: 28))
    if #available(macOS 13.0, *) { well.colorWellStyle = .minimal }
    detail.addSubview(well)
    let l = NSTextField(labelWithString: role.label)
    l.font = mono; l.textColor = dimC
    l.frame = NSRect(x: cx + 54, y: cy + 6, width: colW - 60, height: 16)
    detail.addSubview(l)
    wells[role.key] = well
}

// iconset strip
let stripY: CGFloat = 66
let stripLabel = NSTextField(labelWithString: "iconset")
stripLabel.font = mono; stripLabel.textColor = dimC
stripLabel.frame = NSRect(x: 20, y: stripY + 30, width: 100, height: 16)
detail.addSubview(stripLabel)
let SAMPLES = ["nerd": "󰥔 󰍛 󰖩 󰔛 󱠇 󱓧", "minimal": "󰅐 󰘚 󰤨 󱦟 󰫢 󰧮", "emoji": "🕐 🧠 📶 🍅 ✨ 📓"]
for (i, set) in ["nerd", "minimal", "emoji"].enumerated() {
    let b = NSButton(title: "\(set)  \(SAMPLES[set] ?? "")", target: ctl, action: #selector(Ctl.setIconset(_:)))
    b.alternateTitle = set
    b.bezelStyle = .rounded
    b.font = mono
    b.frame = NSRect(x: 20 + CGFloat(i) * ((dW - 40) / 3), y: stripY, width: (dW - 48) / 3, height: 30)
    if set == activeIconset { b.contentTintColor = accent1 }
    detail.addSubview(b)
}

func btn(_ t: String, _ x: CGFloat, _ w: CGFloat, _ a: Selector) -> NSButton {
    let b = NSButton(title: t, target: ctl, action: a)
    b.bezelStyle = .rounded
    b.frame = NSRect(x: x, y: 16, width: w, height: 30)
    return b
}
detail.addSubview(btn("Apply", dW - 110, 90, #selector(Ctl.apply)))
detail.addSubview(btn("Save as new", dW - 240, 120, #selector(Ctl.saveAs)))
let deleteBtn = btn("Delete", 20, 90, #selector(Ctl.deleteTheme))
detail.addSubview(deleteBtn)

ctl.table = table
ctl.wells = wells
ctl.nameField = nameField
ctl.deleteBtn = deleteBtn

if let i = themes.firstIndex(where: { $0.name == activeTheme }) {
    table.selectRowIndexes([i], byExtendingSelection: false)
} else {
    table.selectRowIndexes([0], byExtendingSelection: false)
}
ctl.tableViewSelectionDidChange(Notification(name: NSTableView.selectionDidChangeNotification))

win.makeKeyAndOrderFront(nil)
NSApp.activate(ignoringOtherApps: true)
app.run()
exit(0)
