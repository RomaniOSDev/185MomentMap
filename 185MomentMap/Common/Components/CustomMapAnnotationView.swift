import UIKit
import MapKit

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: CGFloat
        switch hex.count {
        case 6:
            r = CGFloat((int >> 16) & 0xFF) / 255
            g = CGFloat((int >> 8) & 0xFF) / 255
            b = CGFloat(int & 0xFF) / 255
        default:
            r = 0
            g = 0
            b = 0
        }
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

final class MemoryAnnotation: NSObject, MKAnnotation {
    let memory: Memory
    var coordinate: CLLocationCoordinate2D
    var title: String?

    init(memory: Memory) {
        self.memory = memory
        self.coordinate = CLLocationCoordinate2D(latitude: memory.latitude, longitude: memory.longitude)
        self.title = memory.title
        super.init()
    }
}

final class CustomMapAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "MemoryAnnotationView"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with memory: Memory) {
        let size: CGFloat = 44
        frame = CGRect(x: 0, y: 0, width: size, height: size)
        centerOffset = CGPoint(x: 0, y: -size / 2)
        clusteringIdentifier = "memory"

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        image = renderer.image { context in
            let rect = CGRect(x: 2, y: 2, width: size - 4, height: size - 4)
            UIColor(hex: memory.mood.colorHex).setFill()
            context.cgContext.fillEllipse(in: rect)
            UIColor.white.setStroke()
            context.cgContext.setLineWidth(2)
            context.cgContext.strokeEllipse(in: rect)

            let emoji = memory.mood.rawValue as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20)
            ]
            let textSize = emoji.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size - textSize.width) / 2,
                y: (size - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            emoji.draw(in: textRect, withAttributes: attributes)
        }
    }
}
