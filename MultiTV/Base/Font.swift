import UIKit

struct Font {
    enum Weight: String {
        case regular = "Hellix-Regular"
        case medium = "Hellix-Medium"
        case semiBold = "Hellix-SemiBold"
        case bold = "Hellix-Bold"
        case extraBold = "Hellix-ExtraBold"
        case black = "Hellix-Black"
        case light = "Hellix-Light"
    }

    static func font(weight: Weight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

extension UIFont {
    static func font(weight: Font.Weight, size: CGFloat) -> UIFont {
        return Font.font(weight: weight, size: size)
    }
}
