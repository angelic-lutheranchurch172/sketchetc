// clip_picker <file1> [file2 ...] — centered, autofocused clipboard picker.
// ↑/↓ + Enter selects (prints the chosen path), Esc cancels, click selects,
// clicking anywhere outside dismisses. Images render inline thumbnails.
import AppKit

let files = Array(CommandLine.arguments.dropFirst())
guard !files.isEmpty else { exit(1) }

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let bgColor = NSColor(calibratedRed: 0.09, green: 0.05, blue: 0.16, alpha: 1)
let rowColor = NSColor(calibratedRed: 0.14, green: 0.09, blue: 0.25, alpha: 1)
let selColor = NSColor(calibratedRed: 0.22, green: 0.13, blue: 0.38, alpha: 1)
let pink = NSColor(calibratedRed: 1.0, green: 0.43, blue: 0.78, alpha: 1)
let mono = NSFont(name: "JetBrainsMono Nerd Font", size: 13) ?? .monospacedSystemFont(ofSize: 13, weight: .regular)

let W: CGFloat = 480, ROW_H: CGFloat = 56, GAP: CGFloat = 8, PAD: CGFloat = 16
let H = CGFloat(files.count) * (ROW_H + GAP) + 64

final class RowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {}
    override func drawBackground(in dirtyRect: NSRect) {
        let r = bounds.insetBy(dx: 0, dy: GAP / 2)
        let path = NSBezierPath(roundedRect: r, xRadius: 12, yRadius: 12)
        (isSelected ? selColor : rowColor).setFill()
        path.fill()
        if isSelected {
            pink.setStroke()
            path.lineWidth = 2
            path.stroke()
        }
    }
}

final class Picker: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var files: [String]
    var table: NSTableView!
    init(_ f: [String]) { files = f }

    func numberOfRows(in tableView: NSTableView) -> Int { files.count }
    func tableView(_ t: NSTableView, heightOfRow r: Int) -> CGFloat { ROW_H + GAP }
    func tableView(_ t: NSTableView, rowViewForRow r: Int) -> NSTableRowView? { RowView() }

    func tableView(_ t: NSTableView, viewFor c: NSTableColumn?, row r: Int) -> NSView? {
        let path = files[r]
        let width = W - 2 * PAD
        let cell = NSView(frame: NSRect(x: 0, y: 0, width: width, height: ROW_H + GAP))

        var textX: CGFloat = 16
        if path.hasSuffix(".png"), let img = NSImage(contentsOfFile: path) {
            let iv = NSImageView(frame: NSRect(x: 12, y: GAP / 2 + 6, width: 70, height: ROW_H - 12))
            iv.image = img
            iv.imageScaling = .scaleProportionallyUpOrDown
            iv.wantsLayer = true
            iv.layer?.cornerRadius = 8
            iv.layer?.masksToBounds = true
            cell.addSubview(iv)
            textX = 94
        }

        var preview: String
        if path.hasSuffix(".png") {
            let d = (try? FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date) ?? nil
            let f = DateFormatter(); f.dateFormat = "HH:mm"
            preview = "image · \(d.map { f.string(from: $0) } ?? "")"
        } else {
            preview = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
            preview = preview.replacingOccurrences(of: "\n", with: " ")
                             .trimmingCharacters(in: .whitespaces)
            if preview.count > 44 { preview = String(preview.prefix(44)) + "…" }
        }
        let label = NSTextField(labelWithString: preview)
        label.font = mono
        label.textColor = NSColor(calibratedWhite: 0.93, alpha: 1)
        label.lineBreakMode = .byTruncatingTail
        label.frame = NSRect(x: textX, y: (ROW_H + GAP - 18) / 2, width: width - textX - 16, height: 18)
        label.autoresizingMask = [.width]
        cell.addSubview(label)
        return cell
    }

    @objc func pick() {
        let r = table.selectedRow
        if r >= 0 { print(files[r]); exit(0) }
    }
}

final class KeyTable: NSTableView {
    var onEnter: (() -> Void)?
    override func keyDown(with e: NSEvent) {
        switch e.keyCode {
        case 36, 76: onEnter?()          // return / keypad enter
        case 53: exit(1)                 // esc
        default: super.keyDown(with: e)
        }
    }
}

let picker = Picker(files)

let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: W, height: H),
                   styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false)
win.titleVisibility = .hidden
win.titlebarAppearsTransparent = true
win.level = .floating
win.center()
win.backgroundColor = bgColor
win.appearance = NSAppearance(named: .darkAqua)

let title = NSTextField(labelWithString: "Clipboard")
title.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 15) ?? .boldSystemFont(ofSize: 15)
title.textColor = pink
title.frame = NSRect(x: PAD + 2, y: H - 40, width: W - 2 * PAD, height: 20)
win.contentView!.addSubview(title)

let col = NSTableColumn(identifier: .init("c"))
col.width = W - 2 * PAD
let table = KeyTable(frame: NSRect(x: PAD, y: 12, width: W - 2 * PAD, height: H - 60))
table.headerView = nil
table.backgroundColor = .clear
table.selectionHighlightStyle = .regular
table.intercellSpacing = .zero
table.style = .plain
table.addTableColumn(col)
table.dataSource = picker
table.delegate = picker
table.target = picker
table.action = #selector(Picker.pick)          // single click selects
table.onEnter = { picker.pick() }
picker.table = table

let scroll = NSScrollView(frame: table.frame)
scroll.documentView = table
scroll.drawsBackground = false
scroll.hasVerticalScroller = false
win.contentView!.addSubview(scroll)

table.selectRowIndexes([0], byExtendingSelection: false)

// dismiss when the user clicks anywhere outside (window loses key status)
NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification,
                                       object: win, queue: .main) { _ in exit(1) }

win.makeKeyAndOrderFront(nil)
win.makeFirstResponder(table)
NSApp.activate(ignoringOtherApps: true)
app.run()
exit(1)
