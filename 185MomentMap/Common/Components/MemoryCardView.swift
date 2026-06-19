import SwiftUI
import UIKit

enum MemoryCardStyle {
    case standard
    case compact
    case featured
}

struct MemoryCardView: View {
    let memory: Memory
    let style: MemoryCardStyle
    let onTap: () -> Void
    let onFavorite: () -> Void
    var onPin: (() -> Void)?
    let onShare: () -> Void

    init(
        memory: Memory,
        style: MemoryCardStyle = .standard,
        onTap: @escaping () -> Void,
        onFavorite: @escaping () -> Void,
        onPin: (() -> Void)? = nil,
        onShare: @escaping () -> Void
    ) {
        self.memory = memory
        self.style = style
        self.onTap = onTap
        self.onFavorite = onFavorite
        self.onPin = onPin
        self.onShare = onShare
    }

    private var elevation: AppElevation {
        switch style {
        case .compact: return .flat
        case .standard: return .card
        case .featured: return .elevated
        }
    }

    var body: some View {
        Button(action: onTap) {
            Group {
                switch style {
                case .standard, .featured: standardCard
                case .compact: compactCard
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(memory.title), \(memory.date.formatted(pattern: "dd MMM yyyy"))")
    }

    private var standardCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                imageHeader
                badgesOverlay
            }
            cardContent.padding(14)
        }
        .cardChrome(radius: AppTheme.cardRadius, accent: memory.mood.swiftUIColor, elevation: elevation)
    }

    private var compactCard: some View {
        HStack(spacing: 12) {
            thumbnail(size: 64, corner: 14)
            VStack(alignment: .leading, spacing: 4) {
                Text(memory.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                Text(memory.date.formatted(pattern: "dd MMM"))
                    .font(.caption2)
                    .foregroundStyle(AppColors.secondaryText)
            }
            Spacer()
            Text(memory.mood.rawValue)
        }
        .padding(12)
        .cardChrome(radius: 16, accent: memory.mood.swiftUIColor, elevation: .flat)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)
                    Label(memory.date.formatted(pattern: "dd MMM yyyy"), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
                Spacer()
                moodBadge
            }
            if let address = memory.address, !address.isEmpty {
                Label(address, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }
            if !memory.tags.isEmpty { TagsFlowView(tags: memory.tags) }
            HStack(spacing: 8) {
                if memory.audioData != nil { metaPill(icon: "waveform", text: "Voice") }
                if memory.isFavorite { metaPill(icon: "heart.fill", text: "Favorite") }
                Spacer()
                actionRow
            }
        }
    }

    @ViewBuilder
    private func thumbnail(size: CGFloat, corner: CGFloat) -> some View {
        Group {
            if let data = memory.primaryImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage).resizable().scaledToFill()
            } else {
                ZStack {
                    AppGradients.accent(memory.mood.swiftUIColor)
                    Text(memory.mood.rawValue).font(.title2)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }

    @ViewBuilder
    private var imageHeader: some View {
        Group {
            if let data = memory.primaryImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage).resizable().scaledToFill()
            } else {
                ZStack {
                    AppGradients.accent(memory.mood.swiftUIColor)
                    Text(memory.mood.rawValue).font(.system(size: 44))
                }
            }
        }
        .frame(height: style == .featured ? 160 : 130)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(
            LinearGradient(colors: [.clear, .black.opacity(0.12)], startPoint: .center, endPoint: .bottom)
        )
    }

    private var badgesOverlay: some View {
        HStack(spacing: 6) {
            if memory.isPinned { badge(icon: "pin.fill", text: "Pinned", color: AppColors.accent) }
            if memory.isDraft { badge(icon: "doc.text", text: "Draft", color: .orange) }
        }
        .padding(10)
    }

    private var moodBadge: some View {
        HStack(spacing: 6) {
            Text(memory.mood.rawValue)
            Text(memory.mood.displayName).font(.caption.weight(.semibold))
        }
        .foregroundStyle(memory.mood.swiftUIColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(memory.mood.swiftUIColor.opacity(0.15)))
    }

    private var actionRow: some View {
        HStack(spacing: 6) {
            if let onPin {
                IconCircleButton(icon: memory.isPinned ? "pin.fill" : "pin", color: AppColors.secondaryAccent, action: onPin)
            }
            IconCircleButton(icon: memory.isFavorite ? "heart.fill" : "heart", color: AppColors.accent, action: onFavorite)
            ShareButtonView(text: memory.shareText, imageData: memory.primaryImageData)
        }
    }

    private func badge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(text).font(.caption2.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(color))
    }

    private func metaPill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(text).font(.caption2.weight(.medium))
        }
        .foregroundStyle(AppColors.accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(AppColors.accent.opacity(0.1)))
    }
}

private extension View {
    func cardChrome(radius: CGFloat, accent: Color, elevation: AppElevation) -> some View {
        self
            .background(AppSurfaceShape(radius: radius, accent: accent))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(accent.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(elevation.opacity), radius: elevation.radius, y: elevation.y)
    }
}
