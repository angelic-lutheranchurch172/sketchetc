// aura_card <title> <total> <outpath> <accentHex> <bgHex> <bars: "label:value,label:value,...">
// Renders a classy 1200x630 shareable PNG.
import AppKit

func color(_ hex: String) -> NSColor {
    var h = hex.replacingOccurrences(of: "#", with: ""); if h.count == 8 { h = String(h.dropFirst(2)) }
    let v = UInt32(h, radix: 16) ?? 0xFFFFFF
    return NSColor(calibratedRed: CGFloat((v >> 16) & 0xFF) / 255,
                   green: CGFloat((v >> 8) & 0xFF) / 255,
                   blue: CGFloat(v & 0xFF) / 255, alpha: 1)
}

let args = CommandLine.arguments
guard args.count >= 6 else { print("usage: aura_card title total out accent bg [bars]"); exit(1) }
let title = args[1], total = args[2], out = args[3]
let accent = color(args[4]), bg = color(args[5])
let bars: [(String, Int)] = args.count > 6
    ? args[6].split(separator: ",").compactMap { p in
        let kv = p.split(separator: ":"); guard kv.count == 2, let v = Int(kv[1]) else { return nil }
        return (String(kv[0]), v)
    } : []

let W = 1200.0, H = 630.0
let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()

let grad = NSGradient(colors: [bg, bg.blended(withFraction: 0.35, of: .black) ?? bg])!
grad.draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: -60)

let mono = { (size: CGFloat, weight: NSFont.Weight) -> NSFont in
    NSFont(name: weight == .bold ? "JetBrainsMono Nerd Font Bold" : "JetBrainsMono Nerd Font", size: size)
        ?? NSFont.monospacedSystemFont(ofSize: size, weight: weight)
}
func draw(_ s: String, _ x: CGFloat, _ y: CGFloat, _ font: NSFont, _ c: NSColor) {
    (s as NSString).draw(at: NSPoint(x: x, y: y), withAttributes: [.font: font, .foregroundColor: c])
}

draw("AURA", 80, H - 130, mono(28, .bold), accent.withAlphaComponent(0.9))
draw(title, 80, H - 170, mono(20, .regular), NSColor.white.withAlphaComponent(0.6))
draw(total, 74, H - 380, mono(160, .bold), accent)
draw("aura points", 84, H - 425, mono(22, .regular), NSColor.white.withAlphaComponent(0.5))

if !bars.isEmpty {
    let maxV = max(bars.map { $0.1 }.max() ?? 1, 1)
    let chartX = 640.0, chartW = 480.0, chartY = 180.0, chartH = 280.0
    let bw = chartW / Double(bars.count)
    for (i, b) in bars.enumerated() {
        let h = max(6.0, chartH * Double(b.1) / Double(maxV))
        let r = NSRect(x: chartX + Double(i) * bw + bw * 0.15, y: chartY, width: bw * 0.7, height: h)
        let path = NSBezierPath(roundedRect: r, xRadius: 4, yRadius: 4)
        accent.withAlphaComponent(i == bars.count - 1 ? 1.0 : 0.45).setFill()
        path.fill()
        if bars.count <= 12 {
            draw(b.0, r.minX, chartY - 28, mono(12, .regular), NSColor.white.withAlphaComponent(0.4))
        }
    }
}

draw("generated via github.com/himanshu007-creator/sketchetc", 80, 40, mono(15, .regular),
     NSColor.white.withAlphaComponent(0.35))

img.unlockFocus()
guard let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else { exit(1) }
try? png.write(to: URL(fileURLWithPath: out))
print(out)
