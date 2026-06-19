import SwiftUI

enum SettingsModuleBuilder {
    @MainActor
    static func build() -> SettingsView {
        let router = SettingsRouter()
        let presenter = SettingsPresenter(interactor: SettingsInteractor(), router: router)
        return SettingsView(presenter: presenter)
    }
}

struct SettingsView: View {
    @ObservedObject var presenter: SettingsPresenter

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                FormSectionCard(title: "Home Location", icon: "house.fill") {
                    VStack(spacing: 12) {
                        AppTextField(placeholder: "Home name", text: $presenter.form.homeName)
                        AppTextField(placeholder: "Latitude", text: $presenter.form.homeLatitude, keyboardType: .decimalPad)
                        AppTextField(placeholder: "Longitude", text: $presenter.form.homeLongitude, keyboardType: .decimalPad)
                        Text("Used to calculate your farthest memory in Statistics.")
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                FormSectionCard(title: "Map Preferences", icon: "map.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Near Me Radius")
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Text("\(Int(presenter.form.defaultNearMeRadiusKm)) km")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(AppColors.accent)
                        }
                        Slider(value: $presenter.form.defaultNearMeRadiusKm, in: 1...100, step: 1)
                            .tint(AppColors.accent)
                        Text("Your last map position is saved automatically for quick restore.")
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                FormSectionCard(title: "Legal", icon: "doc.text.fill") {
                    VStack(spacing: 0) {
                        SettingsLinkRow(
                            title: "Rate Us",
                            icon: "star.fill",
                            accent: .orange,
                            action: presenter.didTapRateApp
                        )
                        settingsDivider
                        SettingsLinkRow(
                            title: "Privacy Policy",
                            icon: "hand.raised.fill",
                            accent: AppColors.accent,
                            action: presenter.didTapPrivacyPolicy
                        )
                        settingsDivider
                        SettingsLinkRow(
                            title: "Terms of Use",
                            icon: "doc.plaintext.fill",
                            accent: AppColors.secondaryAccent,
                            action: presenter.didTapTermsOfUse
                        )
                    }
                }

                Button("Save Settings") { presenter.didTapSave() }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { presenter.viewDidLoad() }
        .alert("Saved", isPresented: $presenter.savedMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Settings updated successfully.")
        }
    }

    private var settingsDivider: some View {
        Divider()
            .padding(.leading, 52)
    }
}

private struct SettingsLinkRow: View {
    let title: String
    let icon: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
                    .gradientIconBadge(color: accent, size: 36)

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.secondaryText.opacity(0.5))
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
