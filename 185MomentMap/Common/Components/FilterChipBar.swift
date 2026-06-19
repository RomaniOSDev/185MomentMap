import SwiftUI

struct FilterChip: Identifiable {
    let id: String
    let title: String
    let icon: String?
    let isActive: Bool
    let action: () -> Void
}

struct FilterChipBar: View {
    let chips: [FilterChip]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips) { chip in
                    Button(action: chip.action) {
                        HStack(spacing: 6) {
                            if let icon = chip.icon {
                                Image(systemName: icon)
                                    .font(.caption.weight(.semibold))
                            }
                            Text(chip.title)
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(chip.isActive ? .white : AppColors.secondaryAccent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(
                                    chip.isActive
                                        ? AnyShapeStyle(AppGradients.primaryButton)
                                        : AnyShapeStyle(AppColors.accent.opacity(0.08))
                                )
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(chip.isActive ? Color.clear : AppColors.accent.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
}
