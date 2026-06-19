import SwiftUI
import Charts

struct MoodChartItem: Identifiable {
    let id: String
    let mood: Mood
    let count: Int
}

struct StatsBarChartView: View {
    let items: [MoodChartItem]

    var body: some View {
        if items.isEmpty {
            Text("No mood data yet")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        } else {
            Chart(items) { item in
                BarMark(
                    x: .value("Count", item.count),
                    y: .value("Mood", item.mood.displayName)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [item.mood.swiftUIColor, AppColors.accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(6)
                .annotation(position: .trailing, spacing: 4) {
                    Text("\(item.count)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.2))
                    AxisValueLabel()
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisValueLabel(horizontalSpacing: 8)
                        .foregroundStyle(AppColors.primaryText)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.padding(.leading, 4)
            }
            .frame(height: CGFloat(max(items.count, 1)) * 44)
            .padding(.trailing, 4)
        }
    }
}
