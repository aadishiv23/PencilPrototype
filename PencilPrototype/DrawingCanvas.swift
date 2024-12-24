//
//  DrawingCanvas.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class DrawingCanvas: UIView {
    private var currentPath: UIBezierPath?
    private var paths: [(path: UIBezierPath, color: UIColor, width: CGFloat)] = []
    var strokeColor: UIColor = .black
    var strokeWidth: CGFloat = 5.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCanvas()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCanvas()
    }

    private func setupCanvas() {
        backgroundColor = .white // Explicitly set background color
        isOpaque = true          // Improves performance and prevents blending issues
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil else { return } // Ignore non-pencil input

        let path = UIBezierPath()
        path.lineWidth = strokeWidth
        path.lineCapStyle = .round
        currentPath = path
        paths.append((path: path, color: strokeColor, width: strokeWidth))
        path.move(to: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil, let path = currentPath else { return } // Ignore non-pencil input
        path.addLine(to: touch.location(in: self))
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil else { return } // Ignore non-pencil input
        currentPath = nil
    }

    override func draw(_ rect: CGRect) {
        for (path, color, width) in paths {
            color.setStroke()
            path.lineWidth = width
            path.stroke()
        }
    }

    func clearCanvas() {
        paths.removeAll()
        setNeedsDisplay()
    }

    func undoLastStroke() {
        _ = paths.popLast()
        setNeedsDisplay()
    }
    
    func save() -> Data? {
        let pathsData = paths.map { (path, color, width) -> [String: Any] in
            return [
                "path": NSKeyedArchiver.archivedData(withRootObject: path).base64EncodedString(), // Encode Data to Base64
                "color": color.toHex() ?? "#000000", // Convert color to hex string
                "width": width
            ]
        }
        return try? JSONSerialization.data(withJSONObject: pathsData, options: [])
    }


    func load(from data: Data) {
        guard let pathsData = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return }
        paths = pathsData.compactMap { dict in
            guard
                let pathBase64 = dict["path"] as? String,
                let pathData = Data(base64Encoded: pathBase64), // Decode Base64 string to Data
                let path = NSKeyedUnarchiver.unarchiveObject(with: pathData) as? UIBezierPath,
                let colorHex = dict["color"] as? String,
                let color = UIColor(hex: colorHex), // Convert hex string to UIColor
                let width = dict["width"] as? CGFloat
            else { return nil }
            return (path, color, width)
        }
        setNeedsDisplay()
    }
}


extension UIColor {
    // Convert UIColor to Hex String
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }

    // Create UIColor from Hex String
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        let length = hexSanitized.count
        guard length == 6 else { return nil }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension DrawingCanvas {
    func snapshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }
}
