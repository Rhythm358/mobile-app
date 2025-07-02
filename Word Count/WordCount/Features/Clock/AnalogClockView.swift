import SwiftUI

struct AnalogClockView: View {
    @StateObject private var viewModel = AnalogClockViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            // 最小辺を基準にサイズを決定
            let clockSize = min(geometry.size.width, geometry.size.height) * 0.8
            let outerCircle = clockSize
            let innerCircle = clockSize * 0.93
            let numeralRadius = clockSize * 0.32
            let majorTickOffset = clockSize * 0.43
            let minorTickOffset = clockSize * 0.43
            
            ZStack {
                // 背景
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                // 時計本体
                ZStack {
                    // 外枠
                    Circle()
                        .stroke(Color.primary.opacity(0.3), lineWidth: clockSize * 0.028)
                        .frame(width: outerCircle, height: outerCircle)
                    
                    // 内側の円
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: innerCircle, height: innerCircle)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.1), lineWidth: clockSize * 0.007)
                        )
                    
                    // ローマ数字（12, 3, 6, 9）
                    ForEach([12, 3, 6, 9], id: \.self) { hour in
                        let romanNumeral = getRomanNumeral(for: hour)
                        let angle = Double(hour - 3) * 30 * .pi / 180
                        Text(romanNumeral)
                            .font(.system(size: clockSize * 0.065, weight: .medium, design: .serif))
                            .foregroundColor(.primary)
                            .position(
                                x: geometry.size.width / 2 + CGFloat(cos(angle)) * numeralRadius,
                                y: geometry.size.height / 2 + CGFloat(sin(angle)) * numeralRadius
                            )
                    }
                    
                    // 主要目盛り（12時間）
                    ForEach(0..<12) { hour in
                        let angle = Double(hour) * 30
                        RoundedRectangle(cornerRadius: clockSize * 0.007)
                            .fill(Color.primary.opacity(0.8))
                            .frame(width: clockSize * 0.014, height: clockSize * 0.071)
                            .offset(y: -majorTickOffset)
                            .rotationEffect(.degrees(angle))
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                    
                    // 副目盛り（分）
                    ForEach(0..<60) { minute in
                        if minute % 5 != 0 {
                            let angle = Double(minute) * 6
                            RoundedRectangle(cornerRadius: clockSize * 0.004)
                                .fill(Color.primary.opacity(0.4))
                                .frame(width: clockSize * 0.004, height: clockSize * 0.028)
                                .offset(y: -minorTickOffset)
                                .rotationEffect(.degrees(angle))
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                    }
                    
                    // 時針
                    RoundedRectangle(cornerRadius: clockSize * 0.014)
                        .fill(Color.primary)
                        .frame(width: clockSize * 0.021, height: clockSize * 0.214)
                        .offset(y: -clockSize * 0.107)
                        .rotationEffect(.degrees(viewModel.hourAngle))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.hourAngle)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    // 分針
                    RoundedRectangle(cornerRadius: clockSize * 0.011)
                        .fill(Color.primary)
                        .frame(width: clockSize * 0.014, height: clockSize * 0.304)
                        .offset(y: -clockSize * 0.152)
                        .rotationEffect(.degrees(viewModel.minuteAngle))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.minuteAngle)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    // 秒針
                    RoundedRectangle(cornerRadius: clockSize * 0.004)
                        .fill(Color.red)
                        .frame(width: clockSize * 0.007, height: clockSize * 0.357)
                        .offset(y: -clockSize * 0.179)
                        .rotationEffect(.degrees(viewModel.secondAngle))
//                        .animation(.easeInOut(duration: 0.1), value: viewModel.secondAngle)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    // 中央ドット
                    Circle()
                        .fill(Color.primary)
                        .frame(width: clockSize * 0.071, height: clockSize * 0.071)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .onAppear { viewModel.startTimer() }
            .onDisappear { viewModel.stopTimer() }
        }
    }
    
    // ローマ数字変換
    private func getRomanNumeral(for hour: Int) -> String {
        switch hour {
        case 12: return "XII"
        case 3: return "III"
        case 6: return "VI"
        case 9: return "IX"
        default: return ""
        }
    }
}

// ViewModel
class AnalogClockViewModel: ObservableObject {
    @Published var hourAngle: Double = 0
    @Published var minuteAngle: Double = 0
    @Published var secondAngle: Double = 0
    private var timer: Timer?
    
    func startTimer() {
        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTime()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    private func updateTime() {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let second = calendar.component(.second, from: now)
        
        // 角度計算（12時を0度として時計回り）
        hourAngle = Double(hour % 12) * 30 + Double(minute) * 0.5
        minuteAngle = Double(minute) * 6 + Double(second) * 0.1
        secondAngle = Double(second) * 6
    }
}

// プレビュー
struct AnalogClockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnalogClockView()
                .previewDevice("iPhone 15 Pro")
            AnalogClockView()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }
}
