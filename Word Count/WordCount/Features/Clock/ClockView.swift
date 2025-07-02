import SwiftUI

struct ClockView: View {
    @State private var currentTime = Date()
    @State private var selectedMode = 0 // 0: アナログ, 1: デジタル, 2: タイマー
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 25) {
            // ヘッダー情報
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("現在時刻", comment: "Current time label"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(getCurrentTimeString())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // クイック時刻表示
                VStack(alignment: .trailing, spacing: 2) {
                    Text(getQuickTimeString())
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text(getCurrentTimeZoneAbbreviation())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6).opacity(0.8))
                )
            }
            .padding(.horizontal)
            
            // モード選択セグメントコントロール
            Picker(NSLocalizedString("時計モード", comment: "Clock mode"), selection: $selectedMode) {
                Label(NSLocalizedString("アナログ", comment: "Analog"), systemImage: "clock").tag(0)
                Label(NSLocalizedString("デジタル", comment: "Digital"), systemImage: "deskclock").tag(1)
                Label(NSLocalizedString("タイマー", comment: "Timer"), systemImage: "timer").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6).opacity(0.3))
                    .padding(.horizontal, -5)
                    .padding(.vertical, -5)
            )
            
            // 選択されたモードに応じて表示を切り替え
            Group {
                switch selectedMode {
                case 0:
                    AnalogClockView()
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                case 1:
                    DigitalClockView()
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                case 2:
                    StudyTimerView()
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                default:
                    AnalogClockView()
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedMode)
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            // 画面が表示されたときにスリープを無効化
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            // 画面が非表示になったときにスリープを有効化
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onReceive(timer) { time in
            currentTime = time
        }
        .navigationTitle("時計・タイマー")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getCurrentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: currentTime)
    }
    
    private func getQuickTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: currentTime)
    }
    
    private func getCurrentTimeZoneAbbreviation() -> String {
        let timeZone = TimeZone.current
        return timeZone.abbreviation() ?? timeZone.identifier
    }
}
