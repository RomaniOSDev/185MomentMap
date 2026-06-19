import Foundation

enum AppLinks {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://example.com/privacy-policy"
        case .termsOfUse:
            return "https://example.com/terms-of-use"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
