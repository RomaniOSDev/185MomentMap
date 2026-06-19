import SwiftUI

struct TagChipView: View {
    let tag: MemoryTag
    var isSelected: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) { chipContent }
                    .buttonStyle(.plain)
            } else {
                chipContent
            }
        }
    }

    private var chipContent: some View {
        HStack(spacing: 5) {
            Image(systemName: tag.icon)
                .font(.caption2.weight(.semibold))
            Text(tag.displayName)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .foregroundStyle(isSelected ? .white : AppColors.secondaryAccent)
        .background(
            Capsule(style: .continuous)
                .fill(
                    isSelected
                        ? AnyShapeStyle(AppGradients.primaryButton)
                        : AnyShapeStyle(AppColors.accent.opacity(0.08))
                )
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(isSelected ? Color.clear : AppColors.accent.opacity(0.2), lineWidth: 1)
        )
    }
}

struct TagsFlowView: View {
    let tags: [MemoryTag]

    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(tags) { tag in
                TagChipView(tag: tag)
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        var frames: [CGRect] = []
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}
