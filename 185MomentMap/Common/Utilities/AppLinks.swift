import Foundation

enum AppLinks {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://www.termsfeed.com/live/f48d523d-0c00-48d0-ac6e-3a9f1566b882"
        case .termsOfUse:
            return "https://www.termsfeed.com/live/016a3bf9-08e5-4d66-bae9-6968272294b9"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
