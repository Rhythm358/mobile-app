import SwiftUI
import AudioToolbox

struct StudyTimerView: View {
    @State private var workTime: TimeInterval = 25 * 60
    @State private var breakTime: TimeInterval = 5 * 60
    @State private var isWorking = true
    @State private var timeRemaining: TimeInterval = 25 * 60
    @State private var isRunning = false
    @State private var showSettings = false
    @State private var completedCycles = 0
    @State private var isPaused = false
    @State private var timer: Timer?
    @State private var showStatistics = false
    // カラーテーマ
    private var primaryColor: Color {
        isWorking ? Color.blue : Color.green
    }
    
    private var secondaryColor: Color {
        isWorking ? Color.purple : Color.mint
    }
    
    private var progress: Double {
        let totalTime = isWorking ? workTime : breakTime
        return totalTime > 0 ? 1 - (timeRemaining / totalTime) : 0
    }

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700 // コンパクト判定
            let timerSize = isCompact ? min(geometry.size.width - 100, 200) : min(geometry.size.width - 60, 280)
            
            VStack(spacing: isCompact ? 15 : 25) {
                // ヘッダー情報（簡略化）
                compactHeaderSection
                
                // メインタイマー表示
                mainTimerSection(size: timerSize)
                
                // 進捗情報とコントロールを横並びに
                HStack(spacing: 20) {
                    // 進捗情報（縦並び、コンパクト）
                    VStack(spacing: 10) {
                        compactProgressInfo
                    }
                    .frame(maxWidth: .infinity)
                    
                    // コントロールボタン（縦並び）
                    VStack(spacing: 15) {
                        compactControlButtons
                    }
                }
                
                // 統計情報（簡略化、条件付き表示）
                if !isCompact {
                    compactStatisticsSection
                }
                
                Spacer(minLength: 10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(backgroundGradient)
        .onAppear {
            setupTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showSettings) {
            TimerSettingsView(
                workTime: $workTime,
                breakTime: $breakTime,
                onSave: {
                    resetTimer()
                    showSettings = false
                }
            )
        }
        .sheet(isPresented: $showStatistics) {
            TimerStatisticsView(
                completedCycles: completedCycles,
                workTime: workTime,
                breakTime: breakTime
            )
        }
        .navigationTitle(NSLocalizedString("集中タイマー", comment: "Focus Timer"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Compact View Components
    
    private var compactHeaderSection: some View {
        HStack {
            Text(isWorking ? NSLocalizedString("集中時間", comment: "Focus Time") : NSLocalizedString("休憩時間", comment: "Break Time"))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(primaryColor)
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .foregroundColor(primaryColor)
                    .font(.subheadline)
                Text("\(completedCycles)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("サイクル")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(primaryColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(primaryColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }

    private var compactProgressInfo: some View {
        VStack(spacing: 10) {
            // 進捗率（大きく表示）
            Text("\(Int(progress * 100))%")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
            
            // 進捗ラベル
            Text("進捗")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Divider()
                .background(primaryColor.opacity(0.3))
            
            // 次のフェーズ
            HStack(spacing: 8) {
                Image(systemName: isWorking ? "leaf.fill" : "brain.head.profile")
                    .foregroundColor(isWorking ? .green : .blue)
                Text("次は\(isWorking ? "休憩" : "集中")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground),
                            primaryColor.opacity(0.06)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    primaryColor.opacity(0.4),
                                    primaryColor.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: primaryColor.opacity(0.2), radius: 15, x: 0, y: 8)
    }

    private var compactControlButtons: some View {
        VStack(spacing: 16) {
            // メイン再生/一時停止ボタン
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isRunning {
                        pauseTimer()
                    } else {
                        startTimer()
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, secondaryColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: isRunning ? 0 : 2)
                }
                .shadow(color: primaryColor.opacity(0.4), radius: 12, x: 0, y: 6)
                .scaleEffect(isRunning ? 1.0 : 1.05)
                .animation(.easeInOut(duration: 0.2), value: isRunning)
            }
            
            // サブボタン（横並び）
            HStack(spacing: 12) {
                // リセットボタン
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        resetTimer()
                    }
                }) {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(.systemGray4),
                                    Color(.systemGray5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                
                // 設定ボタン
                Button(action: {
                    showSettings = true
                }) {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.orange,
                                    Color.orange.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .orange.opacity(0.4), radius: 6, x: 0, y: 3)
                }
                
                // スキップボタン
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        switchMode()
                    }
                }) {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple,
                                    Color.purple.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "forward.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .purple.opacity(0.4), radius: 6, x: 0, y: 3)
                }
            }
        }
    }

    private var compactStatisticsSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text(formatTime(workTime))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text("集中時間")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemBackground),
                                Color.blue.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.blue.opacity(0.1), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text(formatTime(breakTime))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text("休憩時間")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemBackground),
                                Color.green.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.green.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Timer Management
    
    private func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimer()
        }
    }
    
    private func updateTimer() {
        DispatchQueue.main.async {
            if isRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining <= 0 && isRunning {
                switchMode()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        isRunning = true
        isPaused = false
        if timer == nil {
            setupTimer()
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        isPaused = true
    }
    
    // MARK: - View Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                primaryColor.opacity(0.1),
                Color(.systemBackground),
                secondaryColor.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isWorking ? NSLocalizedString("集中時間", comment: "Focus Time") : NSLocalizedString("休憩時間", comment: "Break Time"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    
                    Text(NSLocalizedString("ポモドーロテクニック", comment: "Pomodoro Technique"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "target")
                            .foregroundColor(primaryColor)
                        Text("\(completedCycles)")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Text(NSLocalizedString("完了サイクル", comment: "Completed Cycles"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(primaryColor.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(primaryColor.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    private func mainTimerSection(size: CGFloat) -> some View {
        VStack {
            ZStack {
                // 背景円
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(width: size, height: size)
                
                // プログレス円
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [primaryColor, secondaryColor, primaryColor]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: progress)
                
                // 内側の装飾円
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor.opacity(0.3), .clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: size - 40, height: size - 40)
                
                // 中央の時間表示
                VStack(spacing: 12) {
                    Text(timeString(from: timeRemaining))
                        .font(.system(size: min(size / 5, 48), weight: .thin, design: .monospaced))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                    
                    Text(statusText())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(primaryColor)
                    
                    // 小さなプログレスバー
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: primaryColor))
                        .frame(width: size / 3)
                        .scaleEffect(0.8)
                }
            }
            .shadow(color: primaryColor.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    private var progressInfoSection: some View {
        HStack(spacing: 20) {
            InfoCardView(
                title: NSLocalizedString("進捗", comment: "Progress"),
                value: "\(Int(progress * 100))%",
                icon: "chart.pie.fill",
                color: primaryColor
            )
            
            InfoCardView(
                title: NSLocalizedString("残り時間", comment: "Time Left"),
                value: timeString(from: timeRemaining),
                icon: "clock.fill",
                color: .orange
            )
            
            InfoCardView(
                title: NSLocalizedString("次の段階", comment: "Next Phase"),
                value: isWorking ? NSLocalizedString("休憩", comment: "Break") : NSLocalizedString("集中", comment: "Focus"),
                icon: isWorking ? "leaf.fill" : "brain.head.profile",
                color: isWorking ? .green : .blue
            )
        }
    }
    
    private var controlButtonsSection: some View {
        HStack(spacing: 25) {
            // 再生/一時停止ボタン
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isRunning {
                        pauseTimer()
                    } else {
                        startTimer()
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, secondaryColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: isRunning ? 0 : 2)
                }
                .shadow(color: primaryColor.opacity(0.4), radius: 10, x: 0, y: 5)
                .scaleEffect(isRunning ? 1.0 : 1.1)
                .animation(.easeInOut(duration: 0.2), value: isRunning)
            }
            
            // リセットボタン
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    resetTimer()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 55, height: 55)
                    
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            }
            
            // 設定ボタン
            Button(action: {
                showSettings = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 55, height: 55)
                    
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: .orange.opacity(0.4), radius: 5, x: 0, y: 3)
            }
            
            // スキップボタン
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    switchMode()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 55, height: 55)
                    
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: .purple.opacity(0.4), radius: 5, x: 0, y: 3)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text(NSLocalizedString("今日の統計", comment: "Today's Stats"))
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(NSLocalizedString("詳細", comment: "Details")) {
                    showStatistics = true
                }
                .font(.subheadline)
                .foregroundColor(primaryColor)
            }
            
            HStack(spacing: 15) {
                StatisticCardView(
                    title: NSLocalizedString("集中時間", comment: "Focus Time"),
                    value: formatTime(workTime),
                    icon: "brain.head.profile",
                    color: Color.blue
                )
                
                StatisticCardView(
                    title: NSLocalizedString("休憩時間", comment: "Break Time"),
                    value: formatTime(breakTime),
                    icon: "leaf.fill",
                    color: Color.green
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Helper Methods
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        return "\(minutes)分"
    }
    
    private func statusText() -> String {
        if !isRunning && isPaused {
            return NSLocalizedString("一時停止中", comment: "Paused")
        } else if !isRunning {
            return NSLocalizedString("待機中", comment: "Waiting")
        } else {
            return isWorking ? NSLocalizedString("集中中...", comment: "Focusing...") : NSLocalizedString("休憩中...", comment: "On Break...")
        }
    }
    
    private func resetTimer() {
        stopTimer()
        isRunning = false
        isPaused = false
        timeRemaining = isWorking ? workTime : breakTime
        setupTimer()
    }
    
    private func switchMode() {
        if isWorking {
            completedCycles += 1
        }
        isWorking.toggle()
        timeRemaining = isWorking ? workTime : breakTime
        isRunning = false
        isPaused = false
        
        playNotificationSound()
    }
    
    private func playNotificationSound() {
#if os(iOS)
        AudioServicesPlaySystemSound(SystemSoundID(1005))
#endif
    }
}

// MARK: - Supporting Views

struct InfoCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct StatisticCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

