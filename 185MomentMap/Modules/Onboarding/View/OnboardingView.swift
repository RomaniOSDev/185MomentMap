import SwiftUI

struct OnboardingView: View {
    @ObservedObject var presenter: OnboardingPresenter

    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $presenter.currentPage) {
                ForEach(presenter.pages) { page in
                    OnboardingPageView(page: page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: presenter.currentPage)

            footer
        }
        .appScreenBackground()
    }

    private var header: some View {
        HStack {
            Spacer()
            if !presenter.isLastPage {
                Button("Skip", action: presenter.didTapSkip)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var footer: some View {
        VStack(spacing: 24) {
            pageIndicator

            Button(presenter.isLastPage ? "Get Started" : "Next", action: presenter.didTapNext)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 40)
        .padding(.top, 8)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(presenter.pages) { page in
                Capsule()
                    .fill(
                        page.id == presenter.currentPage
                            ? AnyShapeStyle(AppGradients.primaryButton)
                            : AnyShapeStyle(AppColors.accent.opacity(0.2))
                    )
                    .frame(width: page.id == presenter.currentPage ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: presenter.currentPage)
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.accent.opacity(0.1))
                    .frame(width: 220, height: 220)

                Circle()
                    .fill(AppGradients.iconBadge(page.accent))
                    .frame(width: 160, height: 160)
                    .overlay(Circle().stroke(page.accent.opacity(0.2), lineWidth: 1))

                Image(systemName: page.icon)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(page.accent)
                    .symbolRenderingMode(.hierarchical)
            }
            .accessibilityHidden(true)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}
