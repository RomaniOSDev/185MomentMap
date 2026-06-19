import SwiftUI

struct EmptyStateView: View {
    let message: String
    var icon: String = "map"
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(AppColors.accent)
                .gradientIconBadge(color: AppColors.accent, size: 88)
                .accessibilityHidden(true)

            Text(message)
                .font(.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 48)
                    .accessibilityLabel(actionTitle)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
