import SwiftUI

struct MoodGridItemView: View {
    let mood: Mood
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(mood.rawValue)
                    .font(.title2)
                Text(mood.displayName)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isSelected
                            ? AnyShapeStyle(AppGradients.accent(mood.swiftUIColor))
                            : AnyShapeStyle(Color.gray.opacity(0.05))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? mood.swiftUIColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mood.displayName) mood")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
