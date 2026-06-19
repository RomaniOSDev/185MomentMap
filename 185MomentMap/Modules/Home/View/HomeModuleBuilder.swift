import SwiftUI

enum HomeModuleBuilder {
    @MainActor
    static func build() -> HomeView {
        let router = HomeRouter()
        let interactor = HomeInteractor()
        let presenter = HomePresenter(interactor: interactor, router: router)
        router.presenter = presenter
        return HomeView(presenter: presenter)
    }
}
