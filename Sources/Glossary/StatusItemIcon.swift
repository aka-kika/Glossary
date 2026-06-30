import AppKit

/// The menu-bar glyph — a monochrome `{ / }` echoing the app icon's code-braces
/// motif. Drawn in code (resolution-independent) as a template image so macOS
/// tints it for light/dark menu bars.
enum StatusItemIcon {
    static func image(size: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            let s = rect.width
            NSColor.black.setStroke()
            brace(x: 5.0, facing: 1, s: s, width: 1.5).stroke()
            slash(s: s, width: 1.6).stroke()
            brace(x: 13.0, facing: -1, s: s, width: 1.5).stroke()
            return true
        }
        image.isTemplate = true
        return image
    }

    /// Point in an 18-unit grid (y-up), scaled to `s`.
    private static func p(_ x: CGFloat, _ y: CGFloat, _ s: CGFloat) -> CGPoint {
        CGPoint(x: x / 18 * s, y: y / 18 * s)
    }

    /// A curly brace. `facing` 1 = "{", -1 = "}".
    private static func brace(x: CGFloat, facing: CGFloat, s: CGFloat, width: CGFloat) -> NSBezierPath {
        let yTop: CGFloat = 12.6, yBot: CGFloat = 5.4, mid: CGFloat = 9
        let arm = 1.05 * facing
        let tip = 1.7 * facing
        let path = NSBezierPath()
        path.move(to: p(x + arm, yTop, s))
        path.curve(to: p(x, mid + 1.25, s), controlPoint1: p(x - arm * 0.15, yTop, s), controlPoint2: p(x, mid + 2.4, s))
        path.curve(to: p(x - tip, mid, s),  controlPoint1: p(x, mid + 0.55, s),        controlPoint2: p(x - tip * 0.7, mid, s))
        path.curve(to: p(x, mid - 1.25, s), controlPoint1: p(x - tip * 0.7, mid, s),   controlPoint2: p(x, mid - 0.55, s))
        path.curve(to: p(x + arm, yBot, s), controlPoint1: p(x, mid - 2.4, s),         controlPoint2: p(x - arm * 0.15, yBot, s))
        path.lineWidth = width / 18 * s
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        return path
    }

    private static func slash(s: CGFloat, width: CGFloat) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: p(7.4, 5.9, s))
        path.line(to: p(10.6, 12.1, s))
        path.lineWidth = width / 18 * s
        path.lineCapStyle = .round
        return path
    }
}
