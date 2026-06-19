import SwiftUI
import UIKit

struct ShareButtonView: View {
    let text: String
    var imageData: Data?

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                ShareLink(item: text, preview: SharePreview("Memory", image: Image(uiImage: uiImage))) {
                    shareIcon
                }
            } else {
                ShareLink(item: text) { shareIcon }
            }
        }
        .accessibilityLabel("Share memory")
    }

    private var shareIcon: some View {
        Image(systemName: "square.and.arrow.up")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppColors.secondaryAccent)
            .frame(width: 36, height: 36)
            .background(Circle().fill(AppColors.secondaryAccent.opacity(0.12)))
    }
}
