import SwiftUI

struct DetailInfoCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColors.secondaryAccent)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(elevation: .card)
    }
}

struct ActionTile: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .gradientIconBadge(color: color, size: 48)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .appCard(padding: 10, elevation: .card, gradient: AppGradients.accent(color))
        }
        .buttonStyle(.plain)
    }
}

struct PlaceTemplateCell: View {
    let template: PlaceTemplate
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? AppGradients.primaryButton : AppGradients.accent(AppColors.accent))
                        .frame(height: 52)
                    Image(systemName: template.icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : AppColors.secondaryAccent)
                }
                Text(template.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.primaryText)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? AppColors.accent : AppTheme.cardBorderDark, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
