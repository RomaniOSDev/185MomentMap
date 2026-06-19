import SwiftUI

struct TripCellView: View {
    let trip: Trip
    let memoryCount: Int
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.secondaryAccent.opacity(0.2), AppColors.accent.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: "suitcase.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.secondaryAccent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(trip.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColors.primaryText)

                HStack(spacing: 8) {
                    Label("\(memoryCount) memories", systemImage: "photo.on.rectangle")
                    if let start = trip.startDate {
                        Text("•")
                        Text(start.formatted(pattern: "MMM yyyy"))
                    }
                }
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)

                if let note = trip.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.secondaryText.opacity(0.6))
        }
        .appCard(accent: AppColors.secondaryAccent)
    }
}
