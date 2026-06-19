import SwiftUI

struct ContentView: View {
    @State private var showOnboarding: Bool

    init() {
        MomentMapApp.configureAppearance()
        _showOnboarding = State(initialValue: OnboardingModuleBuilder.shouldShowOnboarding())
    }

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingModuleBuilder.build {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            } else {
                HomeModuleBuilder.build()
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    ContentView()
}
