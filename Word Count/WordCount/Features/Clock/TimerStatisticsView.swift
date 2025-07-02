import SwiftUI

struct TimerStatisticsView: View {
    let completedCycles: Int
    let workTime: TimeInterval
    let breakTime: TimeInterval
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(NSLocalizedString("今日の実績", comment: "Today's Achievement")) {
                    StatRow(
                        title: NSLocalizedString("完了サイクル", comment: "Completed Cycles"),
                        value: "\(completedCycles)",
                        icon: "target",
                        color: .blue
                    )
                    StatRow(
                        title: NSLocalizedString("総集中時間", comment: "Total Focus Time"),
                        value: formatTotalTime(workTime * Double(completedCycles)),
                        icon: "brain.head.profile",
                        color: .blue
                    )
                    StatRow(
                        title: NSLocalizedString("総休憩時間", comment: "Total Break Time"),
                        value: formatTotalTime(breakTime * Double(completedCycles)),
                        icon: "leaf.fill",
                        color: .green
                    )
                }
                
                Section(NSLocalizedString("効率性", comment: "Efficiency")) {
                    StatRow(
                        title: NSLocalizedString("平均集中時間", comment: "Average Focus Time"),
                        value: formatTime(workTime),
                        icon: "clock.fill",
                        color: .orange
                    )
                    StatRow(
                        title: NSLocalizedString("集中/休憩比率", comment: "Focus/Break Ratio"),
                        value: formatCycleComposition(),
                        icon: "chart.bar.fill",
                        color: .purple
                    )
                    
                }
                
                Section(NSLocalizedString("目標達成", comment: "Goal Achievement")) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.green)
                            Text(NSLocalizedString("1日の目標進捗", comment: "Daily Goal Progress"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(completedCycles)/8")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: Double(completedCycles), total: 8.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        
                        Text(NSLocalizedString("1日の推奨サイクル: 8回", comment: "Recommended daily cycles: 8"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle(NSLocalizedString("詳細統計", comment: "Detailed Statistics"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("完了", comment: "Done")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        return "\(minutes)" + NSLocalizedString("分", comment: "minutes")
    }
    
    private func formatTotalTime(_ timeInterval: TimeInterval) -> String {
        let totalMinutes = Int(timeInterval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)" + NSLocalizedString("時間", comment: "hours") + " \(minutes)" + NSLocalizedString("分", comment: "minutes")
        } else {
            return "\(minutes)" + NSLocalizedString("分", comment: "minutes")
        }
    }
    
    private func formatCycleComposition() -> String {
        let workMinutes = Int(workTime) / 60
        let breakMinutes = Int(breakTime) / 60
        let minuteText = NSLocalizedString("分", comment: "minutes")
        return "\(workMinutes)\(minuteText) : \(breakMinutes)\(minuteText)"
    }
    
}


// MARK: - Supporting Views
struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview
struct TimerStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        TimerStatisticsView(
            completedCycles: 5,
            workTime: 25 * 60,
            breakTime: 5 * 60
        )
    }
}
