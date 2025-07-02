import SwiftUI

struct TimerSettingsView: View {
    @Binding var workTime: TimeInterval
    @Binding var breakTime: TimeInterval
    let onSave: () -> Void
    
    @State private var workMinutes: Double
    @State private var breakMinutes: Double
    @State private var selectedPreset: Int? = nil
    
    init(workTime: Binding<TimeInterval>, breakTime: Binding<TimeInterval>, onSave: @escaping () -> Void) {
        self._workTime = workTime
        self._breakTime = breakTime
        self.onSave = onSave
        self._workMinutes = State(initialValue: workTime.wrappedValue / 60)
        self._breakMinutes = State(initialValue: breakTime.wrappedValue / 60)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // ヘッダー情報
                    headerSection
                    
                    // プリセット選択
                    presetSection
                    
                    // カスタム設定
                    customSettingsSection
                    
                    // プレビューセクション
                    previewSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(NSLocalizedString("タイマー設定", comment: "Timer Settings"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("キャンセル", comment: "Cancel")) {
                        onSave()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("保存", comment: "Save")) {
                        workTime = workMinutes * 60
                        breakTime = breakMinutes * 60
                        onSave()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "timer")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text(NSLocalizedString("タイマー設定", comment: "Timer Settings"))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("集中と休憩の時間を設定して、効率的な学習リズムを作りましょう", comment: "Set focus and break times to create an efficient study rhythm"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
        .padding(.vertical, 20)
    }
    
    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(NSLocalizedString("プリセット", comment: "Presets"))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if selectedPreset != nil {
                    Button(NSLocalizedString("クリア", comment: "Clear")) {
                        selectedPreset = nil
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 1), spacing: 12) {
                PresetCardView(
                    title: NSLocalizedString("ポモドーロ", comment: "Pomodoro"),
                    subtitle: NSLocalizedString("25分集中 / 5分休憩", comment: "25min Focus / 5min Break"),
                    description: NSLocalizedString("最も一般的な時間設定", comment: "Most common time setting"),
                    workTime: 25,
                    breakTime: 5,
                    icon: "target",
                    color: .red,
                    isSelected: selectedPreset == 0
                ) {
                    selectPreset(work: 25, break: 5, index: 0)
                }
                
                PresetCardView(
                    title: NSLocalizedString("短時間集中", comment: "Short Focus"),
                    subtitle: NSLocalizedString("15分集中 / 3分休憩", comment: "15min Focus / 3min Break"),
                    description: NSLocalizedString("集中力が続きにくい方におすすめ", comment: "Recommended for shorter attention spans"),
                    workTime: 15,
                    breakTime: 3,
                    icon: "bolt.circle",
                    color: .orange,
                    isSelected: selectedPreset == 1
                ) {
                    selectPreset(work: 15, break: 3, index: 1)
                }
                
                PresetCardView(
                    title: NSLocalizedString("長時間集中", comment: "Long Focus"),
                    subtitle: NSLocalizedString("45分集中 / 10分休憩", comment: "45min Focus / 10min Break"),
                    description: NSLocalizedString("深い作業に集中したい方向け", comment: "For deep work sessions"),
                    workTime: 45,
                    breakTime: 10,
                    icon: "brain.head.profile",
                    color: .purple,
                    isSelected: selectedPreset == 2
                ) {
                    selectPreset(work: 45, break: 10, index: 2)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var customSettingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(NSLocalizedString("カスタム設定", comment: "Custom Settings"))
                .font(.headline)
                .fontWeight(.semibold)
            
            // 集中時間設定
            TimeSliderView(
                title: NSLocalizedString("集中時間", comment: "Focus Time"),
                value: $workMinutes,
                range: 5...90,
                step: 5,
                icon: "brain.head.profile",
                color: .blue,
                unit: NSLocalizedString("Min", comment: "Min")
            ) {
                selectedPreset = nil
            }
            
            // 休憩時間設定
            TimeSliderView(
                title: NSLocalizedString("休憩時間", comment: "Break Time"),
                value: $breakMinutes,
                range: 1...30,
                step: 1,
                icon: "leaf.fill",
                color: .green,
                unit: NSLocalizedString("Min", comment: "Min")
            ) {
                selectedPreset = nil
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(NSLocalizedString("プレビュー", comment: "Preview"))
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                PreviewTimeView(
                    title: NSLocalizedString("集中時間", comment: "Focus Time"),
                    time: Int(workMinutes),
                    icon: "brain.head.profile",
                    color: .blue
                )
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                
                PreviewTimeView(
                    title: NSLocalizedString("休憩時間", comment: "Break Time"),
                    time: Int(breakMinutes),
                    icon: "leaf.fill",
                    color: .green
                )
            }
            
            Text(String(format: NSLocalizedString("1サイクル: %d分", comment: "1 Cycle: %d min"), Int(workMinutes + breakMinutes)))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.8))
        )
    }
    
    // MARK: - Helper Methods
    
    private func selectPreset(work: Double, break: Double, index: Int) {
        workMinutes = work
        breakMinutes = `break`
        selectedPreset = index
    }
}

// MARK: - Supporting Views

struct PresetCardView: View {
    let title: String
    let subtitle: String
    let description: String
    let workTime: Int
    let breakTime: Int
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 4, height: 4)
                }
                .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TimeSliderView: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let icon: String
    let color: Color
    let unit: String
    let onChange: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(value))\(unit)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                    .monospacedDigit()
            }
            
            Slider(value: $value, in: range, step: step)
                .accentColor(color)
                .onChange(of: value) { _ in
                    onChange()
                }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.8))
        )
    }
}

struct PreviewTimeView: View {
    let title: String
    let time: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text("\(time)分")
                .font(.title3)
                .fontWeight(.bold)
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}
