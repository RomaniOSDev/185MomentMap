import Foundation
import StoreKit
import UIKit

protocol SettingsRouterInput: AnyObject {
    func dismiss()
    func openLink(_ link: AppLinks)
    func rateApp()
}

final class SettingsRouter: SettingsRouterInput {
    var onDismiss: (() -> Void)?

    func dismiss() {
        onDismiss?()
    }

    func openLink(_ link: AppLinks) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
