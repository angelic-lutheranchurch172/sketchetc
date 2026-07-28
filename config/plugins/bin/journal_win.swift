// journal_win <draftPath> <rootDir>
// The journal, as an app: Write tab (markdown editor for today's draft) and
// History tab (locked entries, newest first, read-only). Prints "FINALIZE" and
// exits 0 when the user finalizes; plain exit otherwise (draft saved on Save).
import AppKit

guard CommandLine.arguments.count >= 3 else { print("usage: journal_win draft root"); exit(2) }
let draftPath = CommandLine.arguments[1]
let rootDir = CommandLine.arguments[2]

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let bg = NSColor(calibratedRed: 0.09, green: 0.05, blue: 0.16, alpha: 1)
let panel = NSColor(calibratedRed: 0.14, green: 0.09, blue: 0.25, alpha: 1)
let pink = NSColor(calibratedRed: 1.0, green: 0.43, blue: 0.78, alpha: 1)
let cyan = NSColor(calibratedRed: 0.04, green: 0.83, blue: 0.83, alpha: 1)
let textC = NSColor(calibratedWhite: 0.93, alpha: 1)
let mono = NSFont(name: "JetBrainsMono Nerd Font", size: 14) ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
let monoSmall = NSFont(name: "JetBrainsMono Nerd Font", size: 12) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)

let W: CGFloat = 880, H: CGFloat = 600, PAD: CGFloat = 22

func styledText(_ frame: NSRect, editable: Bool) -> (NSScrollView, NSTextView) {
    let scroll = NSScrollView(frame: frame)
    scroll.hasVerticalScroller = true
    scroll.borderType = .noBorder
    scroll.wantsLayer = true
    scroll.layer?.cornerRadius = 10
    scroll.autoresizingMask = [.width, .height]
    let tv = NSTextView(frame: NSRect(origin: .zero, size: frame.size))
    tv.autoresizingMask = [.width]
    tv.font = mono
    tv.backgroundColor = panel
    tv.textColor = textC
    tv.insertionPointColor = pink
    tv.textContainerInset = NSSize(width: 16, height: 16)
    tv.isRichText = false
    tv.isEditable = editable
    tv.allowsUndo = editable
    scroll.documentView = tv
    return (scroll, tv)
}

// ---- entries for History ----
struct Entry { let path: String; let label: String }
func loadEntries() -> [Entry] {
    let fm = FileManager.default
    guard let en = fm.enumerator(atPath: rootDir) else { return [] }
    var paths: [String] = []
    for case let p as String in en where p.hasSuffix(".md") { paths.append(p) }
    paths.sort(by: >)
    let df = DateFormatter(); df.dateFormat = "yyyy/MM/dd"
    let out = DateFormatter(); out.dateFormat = "EEE dd MMM yyyy"
    return paths.map { p in
        let stem = String(p.dropLast(3))
        let label = df.date(from: stem).map { out.string(from: $0) } ?? p
        return Entry(path: rootDir + "/" + p, label: label)
    }
}

final class Controller: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var entries: [Entry] = []
    var editor: NSTextView!
    var historyText: NSTextView!
    var table: NSTableView!
    var writeView: NSView!
    var historyView: NSView!

    @objc func switchTab(_ seg: NSSegmentedControl) {
        let history = seg.selectedSegment == 1
        writeView.isHidden = history
        historyView.isHidden = !history
        if history {
            entries = loadEntries()
            table.reloadData()
            if !entries.isEmpty {
                table.selectRowIndexes([0], byExtendingSelection: false)
                showEntry(0)
            } else {
                historyText.string = "no locked entries yet"
            }
        }
    }
    func numberOfRows(in t: NSTableView) -> Int { entries.count }
    func tableView(_ t: NSTableView, viewFor c: NSTableColumn?, row r: Int) -> NSView? {
        let l = NSTextField(labelWithString: entries[r].label)
        l.font = monoSmall
        l.textColor = textC
        return l
    }
    func tableViewSelectionDidChange(_ n: Notification) {
        if table.selectedRow >= 0 { showEntry(table.selectedRow) }
    }
    func showEntry(_ i: Int) {
        historyText.string = (try? String(contentsOfFile: entries[i].path, encoding: .utf8)) ?? "(unreadable)"
    }
    @objc func saveDraft() {
        try? editor.string.write(toFile: draftPath, atomically: true, encoding: .utf8)
        NSSound(named: "Pop")?.play()
    }
    @objc func doFinalize() {
        try? editor.string.write(toFile: draftPath, atomically: true, encoding: .utf8)
        print("FINALIZE")
        exit(0)
    }
    @objc func doCancel() { exit(1) }
}
let ctl = Controller()

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

let title = NSTextField(labelWithString: "Journal")
title.font = NSFont(name: "JetBrainsMono Nerd Font Bold", size: 17) ?? .boldSystemFont(ofSize: 17)
title.textColor = pink
title.frame = NSRect(x: PAD, y: H - 46, width: 200, height: 24)
content.addSubview(title)

let tabs = NSSegmentedControl(labels: ["Write", "History"], trackingMode: .selectOne,
                              target: ctl, action: #selector(Controller.switchTab(_:)))
tabs.selectedSegment = 0
tabs.frame = NSRect(x: W - PAD - 180, y: H - 44, width: 180, height: 24)
content.addSubview(tabs)

// ---- Write tab ----
let writeView = NSView(frame: NSRect(x: 0, y: 0, width: W, height: H - 56))
let (editScroll, editor) = styledText(NSRect(x: PAD, y: 64, width: W - 2 * PAD, height: H - 56 - 78), editable: true)
editor.string = (try? String(contentsOfFile: draftPath, encoding: .utf8)) ?? "- "
writeView.addSubview(editScroll)

func button(_ label: String, x: CGFloat, action: Selector, key: String = "") -> NSButton {
    let b = NSButton(title: label, target: ctl, action: action)
    b.bezelStyle = .rounded
    b.keyEquivalent = key
    b.frame = NSRect(x: x, y: 18, width: 150, height: 32)
    return b
}
writeView.addSubview(button("Finalize & lock", x: W - PAD - 150, action: #selector(Controller.doFinalize)))
writeView.addSubview(button("Save draft", x: W - PAD - 310, action: #selector(Controller.saveDraft), key: "s"))
let cancelB = button("Close", x: PAD, action: #selector(Controller.doCancel), key: "\u{1b}")
cancelB.frame = NSRect(x: PAD, y: 18, width: 100, height: 32)
writeView.addSubview(cancelB)

let hint = NSTextField(labelWithString: "markdown · saved drafts stay editable until finalized")
hint.font = monoSmall
hint.textColor = NSColor(calibratedWhite: 1, alpha: 0.35)
hint.frame = NSRect(x: PAD + 110, y: 24, width: 400, height: 18)
writeView.addSubview(hint)
content.addSubview(writeView)

// ---- History tab ----
let historyView = NSView(frame: NSRect(x: 0, y: 0, width: W, height: H - 56))
historyView.isHidden = true
let listW: CGFloat = 220
let col = NSTableColumn(identifier: .init("d")); col.width = listW - 20
let table = NSTableView(frame: NSRect(x: 0, y: 0, width: listW - 20, height: 100))
table.headerView = nil
table.backgroundColor = panel
table.addTableColumn(col)
table.dataSource = ctl
table.delegate = ctl
table.rowHeight = 26
let listScroll = NSScrollView(frame: NSRect(x: PAD, y: 20, width: listW, height: H - 56 - 34))
listScroll.documentView = table
listScroll.hasVerticalScroller = true
listScroll.wantsLayer = true
listScroll.layer?.cornerRadius = 10
listScroll.drawsBackground = true
listScroll.backgroundColor = panel
historyView.addSubview(listScroll)

let (histScroll, histText) = styledText(NSRect(x: PAD + listW + 14, y: 20, width: W - 2 * PAD - listW - 14, height: H - 56 - 34), editable: false)
historyView.addSubview(histScroll)
content.addSubview(historyView)

ctl.editor = editor
ctl.historyText = histText
ctl.table = table
ctl.writeView = writeView
ctl.historyView = historyView

win.makeKeyAndOrderFront(nil)
win.makeFirstResponder(editor)
NSApp.activate(ignoringOtherApps: true)
app.run()
exit(1)
