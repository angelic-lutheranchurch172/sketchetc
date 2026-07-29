// help_win <tsv> <bgHex> <panelHex> <accent1Hex> <accent2Hex>
// TSV rows: key \t icon \t active(1/0) \t description
// Widget guide: list left (icon + name + active dot), detail right.
import AppKit

guard CommandLine.arguments.count >= 6 else { print("usage: help_win tsv bg panel a1 a2"); exit(2) }
let tsvPath = CommandLine.arguments[1]

func color(_ hex: String) -> NSColor {
    var h = hex.replacingOccurrences(of: "0x", with: "").replacingOccurrences(of: "#", with: "")
    if h.count == 8 { h = String(h.dropFirst(2)) }
    let v = UInt32(h, radix: 16) ?? 0x222222
    return NSColor(calibratedRed: CGFloat((v >> 16) & 0xFF) / 255,
                   green: CGFloat((v >> 8) & 0xFF) / 255,
                   blue: CGFloat(v & 0xFF) / 255, alpha: 1)
}
let bg = color(CommandLine.arguments[2])
let panel = color(CommandLine.arguments[3])
let accent1 = color(CommandLine.arguments[4])   // pink role
let accent2 = color(CommandLine.arguments[5])   // cyan role
let textC = NSColor(calibratedWhite: 0.93, alpha: 1)
let dimC = NSColor(calibratedWhite: 1, alpha: 0.5)
let mono = NSFont(name: "JetBrainsMono Nerd Font", size: 13) ?? .monospacedSystemFont(ofSize: 13, weight: .regular)
let monoBold = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 13) ?? .monospacedSystemFont(ofSize: 13, weight: .bold)

struct Widget { let key: String; let icon: String; let active: Bool; let desc: String }
var widgets: [Widget] = []
for line in ((try? String(contentsOfFile: tsvPath, encoding: .utf8)) ?? "").components(separatedBy: "\n") {
    let p = line.components(separatedBy: "\t")
    if p.count >= 4 { widgets.append(Widget(key: p[0], icon: p[1], active: p[2] == "1", desc: p[3])) }
}
guard !widgets.isEmpty else { exit(1) }

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let W: CGFloat = 720, H: CGFloat = 480, PAD: CGFloat = 20, LIST_W: CGFloat = 230

final class Ctl: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var table: NSTableView!
    var dIcon: NSTextField!, dName: NSTextField!, dState: NSTextField!, dDesc: NSTextField!
    func numberOfRows(in t: NSTableView) -> Int { widgets.count }
    func tableView(_ t: NSTableView, viewFor c: NSTableColumn?, row r: Int) -> NSView? {
        let w = widgets[r]
        let cell = NSView(frame: NSRect(x: 0, y: 0, width: LIST_W - 20, height: 26))
        let dot = NSTextField(labelWithString: w.active ? "●" : "○")
        dot.font = mono
        dot.textColor = w.active ? accent1 : dimC
        dot.frame = NSRect(x: 6, y: 4, width: 18, height: 18)
        cell.addSubview(dot)
        let l = NSTextField(labelWithString: "\(w.icon)  \(w.key)")
        l.font = mono
        l.textColor = textC
        l.frame = NSRect(x: 28, y: 4, width: LIST_W - 52, height: 18)
        cell.addSubview(l)
        return cell
    }
    func tableViewSelectionDidChange(_ n: Notification) {
        guard table.selectedRow >= 0 else { return }
        let w = widgets[table.selectedRow]
        dIcon.stringValue = w.icon
        dName.stringValue = w.key
        dState.stringValue = w.active ? "● active in your bar" : "○ off · enable it from the widgets menu"
        dState.textColor = w.active ? accent1 : dimC
        dDesc.stringValue = w.desc
    }
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

let title = NSTextField(labelWithString: "What does everything do")
title.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 15) ?? .boldSystemFont(ofSize: 15)
title.textColor = accent1
title.frame = NSRect(x: 96, y: H - 40, width: 400, height: 20)
content.addSubview(title)

let col = NSTableColumn(identifier: .init("w")); col.width = LIST_W - 20
let table = NSTableView()
table.headerView = nil
table.backgroundColor = panel
table.addTableColumn(col)
table.dataSource = ctl
table.delegate = ctl
table.rowHeight = 26
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
let dIcon = NSTextField(labelWithString: "")
dIcon.font = NSFont(name: "JetBrainsMono Nerd Font", size: 34) ?? .systemFont(ofSize: 34)
dIcon.textColor = accent2
dIcon.frame = NSRect(x: 24, y: detail.frame.height - 84, width: 92, height: 50)
detail.addSubview(dIcon)
let dName = NSTextField(labelWithString: "")
dName.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
dName.textColor = textC
dName.frame = NSRect(x: 126, y: detail.frame.height - 62, width: dW - 150, height: 26)
detail.addSubview(dName)
let dState = NSTextField(labelWithString: "")
dState.font = mono
dState.frame = NSRect(x: 128, y: detail.frame.height - 86, width: dW - 150, height: 18)
detail.addSubview(dState)
let dDesc = NSTextField(wrappingLabelWithString: "")
dDesc.font = NSFont.systemFont(ofSize: 14)
dDesc.textColor = textC
dDesc.frame = NSRect(x: 26, y: 20, width: dW - 52, height: detail.frame.height - 130)
dDesc.cell?.wraps = true
detail.addSubview(dDesc)
content.addSubview(detail)

ctl.table = table
ctl.dIcon = dIcon; ctl.dName = dName; ctl.dState = dState; ctl.dDesc = dDesc
table.selectRowIndexes([0], byExtendingSelection: false)
ctl.tableViewSelectionDidChange(Notification(name: NSTableView.selectionDidChangeNotification))

win.makeKeyAndOrderFront(nil)
NSApp.activate(ignoringOtherApps: true)
app.run()
exit(0)
