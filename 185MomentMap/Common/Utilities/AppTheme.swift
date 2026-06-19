import SwiftUI

// MARK: - Tokens

enum AppTheme {
    static let cardRadius: CGFloat = 20
    static let chipRadius: CGFloat = 12
    static let innerRadius: CGFloat = 14

    static let cardBorder = Color.white.opacity(0.65)
    static let cardBorderDark = Color.black.opacity(0.06)
}

enum AppGradients {
    static let screen = LinearGradient(
        colors: [
            AppColors.background,
            AppColors.accent.opacity(0.07),
            AppColors.secondaryAccent.opacity(0.04),
            AppColors.background
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButton = LinearGradient(
        colors: [AppColors.accent, AppColors.secondaryAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardSurface = LinearGradient(
        colors: [Color.white, AppColors.background],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardShine = LinearGradient(
        colors: [Color.white.opacity(0.55), Color.white.opacity(0.0)],
        startPoint: .top,
        endPoint: .center
    )

    static func accent(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.14), color.opacity(0.04)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func iconBadge(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.22), color.opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Depth (single shadow per surface — GPU-friendly)

enum AppElevation {
    case flat
    case card
    case elevated

    var radius: CGFloat {
        switch self {
        case .flat: return 0
        case .card: return 8
        case .elevated: return 14
        }
    }

    var y: CGFloat {
        switch self {
        case .flat: return 0
        case .card: return 4
        case .elevated: return 7
        }
    }

    var opacity: Double {
        switch self {
        case .flat: return 0
        case .card: return 0.09
        case .elevated: return 0.13
        }
    }
}

struct AppSurfaceShape: View {
    var radius: CGFloat = AppTheme.cardRadius
    var accent: Color? = nil
    var gradient: LinearGradient? = nil

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(gradient ?? AppGradients.cardSurface)
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AppGradients.cardShine)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AppTheme.cardBorder, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AppTheme.cardBorderDark, lineWidth: 0.5)
            )
            .overlay(alignment: .leading) {
                if let accent {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [accent, accent.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4)
                        .padding(.vertical, 10)
                        .padding(.leading, 5)
                }
            }
    }
}

struct DepthCardModifier: ViewModifier {
    var padding: CGFloat = 16
    var radius: CGFloat = AppTheme.cardRadius
    var elevation: AppElevation = .card
    var accent: Color? = nil
    var gradient: LinearGradient? = nil

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                AppSurfaceShape(radius: radius, accent: accent, gradient: gradient)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(
                color: .black.opacity(elevation.opacity),
                radius: elevation.radius,
                x: 0,
                y: elevation.y
            )
    }
}

struct DepthListCardModifier: ViewModifier {
    var accent: Color? = nil

    func body(content: Content) -> some View {
        content.modifier(DepthCardModifier(padding: 0, elevation: .card, accent: accent))
    }
}

struct ScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background {
            ZStack {
                AppGradients.screen
                Circle()
                    .fill(AppColors.accent.opacity(0.07))
                    .frame(width: 260, height: 260)
                    .blur(radius: 1)
                    .offset(x: -120, y: -220)
                Circle()
                    .fill(AppColors.secondaryAccent.opacity(0.05))
                    .frame(width: 220, height: 220)
                    .blur(radius: 1)
                    .offset(x: 140, y: 320)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - View extensions

extension View {
    func appCard(
        padding: CGFloat = 16,
        accent: Color? = nil,
        elevation: AppElevation = .card,
        gradient: LinearGradient? = nil
    ) -> some View {
        modifier(DepthCardModifier(padding: padding, elevation: elevation, accent: accent, gradient: gradient))
    }

    func depthListCard(accent: Color? = nil) -> some View {
        modifier(DepthListCardModifier(accent: accent))
    }

    func appScreenBackground() -> some View {
        modifier(ScreenBackgroundModifier())
    }

    func gradientIconBadge(color: Color, size: CGFloat = 40) -> some View {
        ZStack {
            Circle()
                .fill(AppGradients.iconBadge(color))
                .overlay(Circle().stroke(color.opacity(0.18), lineWidth: 1))
            self
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Inputs & Buttons

struct AppTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.innerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.04), Color.gray.opacity(0.09)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.innerRadius, style: .continuous)
                    .stroke(AppColors.accent.opacity(0.18), lineWidth: 1)
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.innerRadius, style: .continuous)
                    .fill(isDisabled ? AnyShapeStyle(AppColors.accent.opacity(0.35)) : AnyShapeStyle(AppGradients.primaryButton))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.innerRadius, style: .continuous)
                            .fill(Color.white.opacity(0.22))
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.innerRadius, style: .continuous))
            .shadow(color: AppColors.accent.opacity(isDisabled ? 0 : 0.28), radius: 10, y: 5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppColors.secondaryAccent)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.innerRadius, style: .continuous)
                    .fill(AppColors.secondaryAccent.opacity(configuration.isPressed ? 0.1 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.innerRadius, style: .continuous)
                    .stroke(AppColors.secondaryAccent.opacity(0.3), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct IconCircleButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .gradientIconBadge(color: color, size: 36)
        }
        .buttonStyle(.plain)
    }
}

struct FABView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppGradients.primaryButton)
                    .overlay(Circle().fill(Color.white.opacity(0.2)))
                    .frame(width: 60, height: 60)
                    .shadow(color: AppColors.accent.opacity(0.38), radius: 12, y: 6)

                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .accessibilityLabel("Add memory")
    }
}
