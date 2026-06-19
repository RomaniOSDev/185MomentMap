import SwiftUI
import UIKit

struct FormSectionCard<Content: View>: View {
    let title: String
    var icon: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.accent)
                }
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColors.secondaryAccent)
            }

            content
        }
        .appCard()
    }
}

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .modifier(AppTextFieldStyle())
    }
}

struct AppTextEditor: View {
    @Binding var text: String
    var minHeight: CGFloat = 100

    var body: some View {
        TextEditor(text: $text)
            .frame(minHeight: minHeight)
            .scrollContentBackground(.hidden)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.innerRadius, style: .continuous)
                    .fill(Color.gray.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.innerRadius, style: .continuous)
                    .stroke(AppColors.accent.opacity(0.15), lineWidth: 1)
            )
    }
}
