import SwiftUI

struct AudioNotePlayerView: View {
    let audioData: Data
    @StateObject private var player = AudioPlayerService()
    @State private var isPlaying = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isPlaying ? "waveform" : "mic.fill")
                .foregroundStyle(AppColors.accent)
                .symbolEffect(.variableColor, isActive: isPlaying)
                .gradientIconBadge(color: AppColors.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("Voice Note")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.primaryText)
                Text(isPlaying ? "Playing..." : "Tap to listen")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            Button(isPlaying ? "Stop" : "Play") {
                if isPlaying {
                    player.stop()
                    isPlaying = false
                } else {
                    try? player.play(data: audioData)
                    isPlaying = true
                }
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(AppGradients.primaryButton))
        }
        .appCard(padding: 14, accent: AppColors.accent, elevation: .flat, gradient: AppGradients.accent(AppColors.accent))
        .accessibilityLabel("Voice note player")
    }
}
