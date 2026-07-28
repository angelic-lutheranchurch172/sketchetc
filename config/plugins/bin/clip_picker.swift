// clip_picker <file1> [file2 ...] — centered, autofocused clipboard picker.
// ↑/↓ + Enter selects (prints the chosen path), Esc cancels, click selects.
// Image entries render inline thumbnails; text entries show a monospace preview.
import AppKit

let files = Array(CommandLine.arguments.dropFirst())
guard !files.isEmpty else { exit(1) }

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let bgColor = NSColor(calibratedRed: 0.09, green: 0.05, blue: 0.16, alpha: 1)
let rowColor = NSColor(calibratedRed: 0.14, green: 0.09, blue: 0.25, alpha: 1)
let pink = NSColor(calibratedRed: 1.0, green: 0.43, blue: 0.78, alpha: 1)
let mono = NSFont(name: "JetBrainsMono Nerd Font", size: 13) ?? .monospacedSystemFont(ofSize: 13, weight: .regular)

let ROW_H: CGFloat = 52, W: CGFloat = 560
let H = CGFloat(files.count) * (ROW_H + 6) + 74

final class Picker: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var files: [String]
    var table: NSTableView!
    init(_ f: [String]) { files = f }

    func numberOfRows(in tableView: NSTableView) -> Int { files.count }
    func tableView(_ t: NSTableView, heightOfRow r: Int) -> CGFloat { ROW_H + 6 }

    func tableView(_ t: NSTableView, viewFor c: NSTableColumn?, row r: Int) -> NSView? {
        let path = files[r]
        let cell = NSView(frame: NSRect(x: 0, y: 0, width: W - 32, height: ROW_H))
        cell.wantsLayer = true
        cell.layer?.backgroundColor = rowColor.cgColor
        cell.layer?.cornerRadius = 10

        var textX: CGFloat = 14
        if path.hasSuffix(".png"), let img = NSImage(contentsOfFile: path) {
            let iv = NSImageView(frame: NSRect(x: 10, y: 4, width: 64, height: ROW_H - 8))
            iv.image = img
            iv.imageScaling = .scaleProportionallyUpOrDown
            iv.wantsLayer = true
            iv.layer?.cornerRadius = 6
            iv.layer?.masksToBounds = true
            cell.addSubview(iv)
            textX = 86
        }

        var preview: String
        if path.hasSuffix(".png") {
            let d = (try? FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date) ?? nil
            let f = DateFormatter(); f.dateFormat = "HH:mm"
            preview = "image · \(d.map { f.string(from: $0) } ?? "")"
        } else {
            preview = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
            preview = preview.replacingOccurrences(of: "\n", with: " ")
            if preview.count > 52 { preview = String(preview.prefix(52)) + "…" }
        }
        let label = NSTextField(labelWithString: preview)
        label.font = mono
        label.textColor = NSColor(calibratedWhite: 0.93, alpha: 1)
        label.lineBreakMode = .byTruncatingTail
        label.frame = NSRect(x: textX, y: (ROW_H - 18) / 2, width: W - 32 - textX - 12, height: 18)
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
title.frame = NSRect(x: 18, y: H - 40, width: W - 36, height: 20)
win.contentView!.addSubview(title)

let table = KeyTable(frame: NSRect(x: 16, y: 14, width: W - 32, height: H - 62))
table.headerView = nil
table.backgroundColor = .clear
table.selectionHighlightStyle = .regular
table.intercellSpacing = NSSize(width: 0, height: 6)
table.addTableColumn(NSTableColumn(identifier: .init("c")))
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

win.makeKeyAndOrderFront(nil)
win.makeFirstResponder(table)
NSApp.activate(ignoringOtherApps: true)
app.run()
exit(1)
