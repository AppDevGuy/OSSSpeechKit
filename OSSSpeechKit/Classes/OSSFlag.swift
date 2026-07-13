import Foundation
import UIKit

private enum OSSFlagRenderer {
    // NSCache is thread-safe, but Foundation does not declare it Sendable.
    nonisolated(unsafe) static let cache = NSCache<NSString, UIImage>()

    static func emoji(for regionCode: String?) -> String {
        guard let regionCode, regionCode.count == 2 else {
            return "🌐"
        }
        let scalars = regionCode.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(127397 + $0.value)
        }
        guard scalars.count == 2 else { return "🌐" }
        return String(String.UnicodeScalarView(scalars))
    }

    static func image(emoji: String, pointSize: CGFloat, scale: CGFloat) -> UIImage {
        let key = "\(emoji)-\(pointSize)-\(scale)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let font = UIFont.systemFont(ofSize: pointSize)
        let attributed = NSAttributedString(string: emoji, attributes: [.font: font])
        let measured = attributed.size()
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: measured, format: format)
        let image = renderer.image { _ in
            attributed.draw(at: .zero)
        }
        cache.setObject(image, forKey: key)
        return image
    }
}

public extension OSSLanguage {
    /// A Unicode flag suitable for labels, SwiftUI `Text`, and accessibility.
    var flagEmoji: String {
        OSSFlagRenderer.emoji(
            for: regionCode ?? locale.language.region?.identifier
        )
    }

    /// Renders ``flagEmoji`` to an image for UIKit clients that require one.
    func renderedFlagImage(
        pointSize: CGFloat = 24,
        scale: CGFloat = 1
    ) -> UIImage {
        OSSFlagRenderer.image(
            emoji: flagEmoji,
            pointSize: max(1, pointSize),
            scale: max(1, scale)
        )
    }
}

@available(*, deprecated, message: "Use OSSLanguage flag APIs.")
public extension OSSVoiceEnum {
    /// The canonical locale used by the modern API.
    var canonicalLocaleIdentifier: String {
        switch self {
        case .Chinese:
            return "zh-CN"
        case .ChineseHongKong:
            return "yue-HK"
        case .Norwegian:
            return "nb-NO"
        default:
            return Locale.canonicalIdentifier(from: rawValue)
        }
    }

    /// Modern metadata corresponding to this legacy case.
    var languageMetadata: OSSLanguage {
        if let match = OSSLanguage.catalog.first(where: {
            $0.localeIdentifier == canonicalLocaleIdentifier
        }) {
            return match
        }
        return OSSLanguage(
            id: rawValue,
            name: title,
            localeIdentifier: canonicalLocaleIdentifier
        )
    }

    /// Preferred Unicode replacement for the legacy image property.
    var flagEmoji: String {
        languageMetadata.flagEmoji
    }

    /// Renders ``flagEmoji`` for UIKit clients.
    func renderedFlagImage(
        pointSize: CGFloat = 24,
        scale: CGFloat = 1
    ) -> UIImage {
        languageMetadata.renderedFlagImage(pointSize: pointSize, scale: scale)
    }
}
