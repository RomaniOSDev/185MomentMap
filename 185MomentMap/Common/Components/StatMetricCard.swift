import SwiftUI

struct StatMetricCard: View {
    let title: String
    let value: String
    let icon: String
    var accent: Color = AppColors.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(accent)
                .gradientIconBadge(color: accent)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(accent: accent, elevation: .card, gradient: AppGradients.accent(accent))
    }
}

struct StatListRow: View {
    let rank: Int?
    let title: String
    let trailing: String
    var emoji: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let rank {
                Text("\(rank)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle().fill(
                            LinearGradient(
                                colors: [AppColors.secondaryAccent, AppColors.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    )
            }
            if let emoji { Text(emoji) }
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.primaryText)
            Spacer()
            Text(trailing)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.secondaryAccent)
        }
        .padding(.vertical, 8)
    }
}
