import Cocoa
if CommandLine.arguments[1] == "--pack" {
    let directory = URL(fileURLWithPath: CommandLine.arguments[2])
    var chunks = Data()
    func length(_ value: Int) -> Data {
        var big = UInt32(value).bigEndian
        return withUnsafeBytes(of: &big) { Data($0) }
    }
    for (type, name) in [("icp4", "icon_16x16.png"), ("icp5", "icon_32x32.png"), ("icp6", "icon_32x32@2x.png"), ("ic07", "icon_128x128.png"), ("ic08", "icon_256x256.png"), ("ic09", "icon_512x512.png"), ("ic10", "icon_512x512@2x.png")] {
        let png = try Data(contentsOf: directory.appendingPathComponent(name))
        chunks.append(Data(type.utf8)); chunks.append(length(png.count + 8)); chunks.append(png)
    }
    var output = Data("icns".utf8)
    output.append(length(chunks.count + 8)); output.append(chunks)
    try output.write(to: URL(fileURLWithPath: CommandLine.arguments[3]))
    exit(0)
}
let image = NSImage(size: NSSize(width: 1024, height: 1024))
image.lockFocus()
let background = NSBezierPath(roundedRect: NSRect(x: 32, y: 32, width: 960, height: 960), xRadius: 215, yRadius: 215)
NSGradient(starting: NSColor(calibratedRed: 0.35, green: 0.19, blue: 0.75, alpha: 1), ending: NSColor(calibratedRed: 0.88, green: 0.20, blue: 0.48, alpha: 1))!.draw(in: background, angle: -65)
NSColor.white.setStroke()
let camera = NSBezierPath(roundedRect: NSRect(x: 252, y: 252, width: 520, height: 520), xRadius: 150, yRadius: 150)
camera.lineWidth = 44
camera.stroke()
let lens = NSBezierPath(ovalIn: NSRect(x: 392, y: 392, width: 240, height: 240))
lens.lineWidth = 42
lens.stroke()
NSColor.white.setFill()
NSBezierPath(ovalIn: NSRect(x: 655, y: 655, width: 62, height: 62)).fill()
image.unlockFocus()
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
