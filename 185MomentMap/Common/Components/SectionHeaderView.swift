import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var icon: String? = nil
    var subtitle: String? = nil
    var style: Style = .standard

    enum Style {
        case standard
        case featured
        case draft
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(iconForeground)
                    .gradientIconBadge(color: iconForeground, size: 36)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(titleColor)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }

    private var iconForeground: Color {
        switch style {
        case .standard: return AppColors.accent
        case .featured: return AppColors.secondaryAccent
        case .draft: return .orange
        }
    }

    private var titleColor: Color {
        switch style {
        case .standard, .featured: return AppColors.secondaryAccent
        case .draft: return AppColors.primaryText
        }
    }
}
