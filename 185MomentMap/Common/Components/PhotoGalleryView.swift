import SwiftUI
import UIKit

struct PhotoGalleryView: View {
    let imagesData: [Data]
    var height: CGFloat = 80

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(imagesData.enumerated()), id: \.offset) { index, data in
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: height, height: height)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
                            )
                            .overlay(alignment: .topTrailing) {
                                Text("\(index + 1)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(Circle().fill(Color.black.opacity(0.45)))
                                    .padding(4)
                            }
                    }
                }
            }
        }
    }
}

struct PhotoHeroGalleryView: View {
    let imagesData: [Data]

    var body: some View {
        TabView {
            if imagesData.isEmpty {
                ZStack {
                    LinearGradient(
                        colors: [AppColors.accent.opacity(0.2), AppColors.secondaryAccent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.accent.opacity(0.6))
                }
            } else {
                ForEach(Array(imagesData.enumerated()), id: \.offset) { _, data in
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: imagesData.count > 1 ? .automatic : .never))
    }
}
