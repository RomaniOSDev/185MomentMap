import SwiftUI

struct NearbyMemoryCell: View {
    let memory: Memory
    let distanceKm: Double
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(memory.mood.swiftUIColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Text(memory.mood.rawValue).font(.title3)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(memory.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                    Text(String(format: "%.1f km away", distanceKm))
                        .font(.caption)
                        .foregroundStyle(AppColors.accent)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.secondaryText.opacity(0.5))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppGradients.accent(memory.mood.swiftUIColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(memory.mood.swiftUIColor.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct NearbyMemoriesSheet: View {
    let items: [(memory: Memory, distanceKm: Double)]
    let onSelect: (Memory) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Nearby Memories", systemImage: "location.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.secondaryAccent)
                Spacer()
                Text("\(items.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(AppColors.accent))
            }
            .padding(.horizontal, 16)

            if items.isEmpty {
                Text("No memories nearby")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .padding(.horizontal, 16)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(items, id: \.memory.id) { item in
                            NearbyMemoryCell(
                                memory: item.memory,
                                distanceKm: item.distanceKm
                            ) {
                                onSelect(item.memory)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.vertical, 14)
        .background(
            AppSurfaceShape(radius: 22)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 16, y: -4)
    }
}
