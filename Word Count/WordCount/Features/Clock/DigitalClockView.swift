import SwiftUI

struct DigitalClockView: View {
    @State private var currentTime = Date()
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }
    
    private var timeComponents: (hours: String, minutes: String, seconds: String) {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: currentTime)
        return (
            String(format: "%02d", components.hour ?? 0),
            String(format: "%02d", components.minute ?? 0),
            String(format: "%02d", components.second ?? 0)
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)
            let dateFontSize = minSide * 0.07
            let mainDigitFontSize = minSide * 0.18
            let colonFontSize = minSide * 0.13
            let labelFontSize = minSide * 0.03
            let vStackSpacing = minSide * 0.06
            let hStackSpacing = minSide * 0.03
            let paddingValue = minSide * 0.09
            let greetingFontSize = minSide * 0.045
            
            VStack(spacing: vStackSpacing) {
                // 日付表示（多言語対応）
                VStack(spacing: vStackSpacing * 0.5) {
                    Text(dateFormatter.string(from: currentTime))
                        .font(.system(size: dateFontSize, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    // 時間帯アイコンと挨拶
                    HStack(spacing: hStackSpacing) {
                        Image(systemName: getTimeIcon())
                            .font(.system(size: greetingFontSize))
                            .foregroundColor(getTimeColor())
                        Text(getTimeOfDay())
                            .font(.system(size: greetingFontSize))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, paddingValue * 0.5)
                    .padding(.vertical, paddingValue * 0.2)
                    .background(
                        Capsule()
                            .fill(getTimeColor().opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(getTimeColor().opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // メイン時刻表示
                VStack(spacing: vStackSpacing * 0.5) {
                    HStack(spacing: hStackSpacing) {
                        // 時
                        TimeDigitView(
                            digit: timeComponents.hours,
                            label: NSLocalizedString("hour_label", comment: ""),
                            fontSize: mainDigitFontSize,
                            labelFontSize: labelFontSize
                        )
                        Text(":")
                            .font(.system(size: colonFontSize, weight: .ultraLight, design: .monospaced))
                            .foregroundColor(.primary)
                            .opacity(currentTime.timeIntervalSince1970.truncatingRemainder(dividingBy: 2) < 1 ? 1 : 0.3)
                            .animation(.easeInOut(duration: 0.5), value: currentTime)
                        // 分
                        TimeDigitView(
                            digit: timeComponents.minutes,
                            label: NSLocalizedString("minute_label", comment: ""),
                            fontSize: mainDigitFontSize,
                            labelFontSize: labelFontSize
                        )
                        Text(":")
                            .font(.system(size: colonFontSize, weight: .ultraLight, design: .monospaced))
                            .foregroundColor(.primary)
                            .opacity(currentTime.timeIntervalSince1970.truncatingRemainder(dividingBy: 2) < 1 ? 1 : 0.3)
                            .animation(.easeInOut(duration: 0.5), value: currentTime)
                        // 秒
                        TimeDigitView(
                            digit: timeComponents.seconds,
                            label: NSLocalizedString("second_label", comment: ""),
                            fontSize: mainDigitFontSize * 0.9,
                            labelFontSize: labelFontSize * 0.9,
                            isSeconds: true
                        )
                    }
                    .padding(paddingValue)
                    .background(
                        RoundedRectangle(cornerRadius: minSide * 0.12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: minSide * 0.04, x: 0, y: minSide * 0.013)
                            .overlay(
                                RoundedRectangle(cornerRadius: minSide * 0.12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.primary.opacity(0.1), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .frame(maxWidth: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .onReceive(timer) { time in
                currentTime = time
            }
        }
    }
    
    private func getTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 5..<12:
            return NSLocalizedString("good_morning", comment: "")
        case 12..<17:
            return NSLocalizedString("good_afternoon", comment: "")
        case 17..<21:
            return NSLocalizedString("good_evening", comment: "")
        default:
            return NSLocalizedString("good_night", comment: "")
        }
    }
    
    private func getTimeIcon() -> String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 5..<12:
            return "sun.max.fill"
        case 12..<17:
            return "sun.max"
        case 17..<21:
            return "sunset.fill"
        default:
            return "moon.stars.fill"
        }
    }
    
    private func getTimeColor() -> Color {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 5..<12:
            return .orange
        case 12..<17:
            return .blue
        case 17..<21:
            return .purple
        default:
            return .indigo
        }
    }
}

// 時刻の各桁を表示するコンポーネント
struct TimeDigitView: View {
    let digit: String
    let label: String
    var fontSize: CGFloat = 55
    var labelFontSize: CGFloat = 16
    var isSeconds: Bool = false
    
    var body: some View {
        VStack(spacing: fontSize * 0.09) {
            Text(digit)
                .font(.system(size: fontSize, weight: .thin, design: .monospaced))
                .foregroundColor(.primary)
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(label)
                .font(.system(size: labelFontSize))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .opacity(isSeconds ? 0.7 : 1.0)
        }
        .padding(.horizontal, fontSize * 0.13)
        .background(
            RoundedRectangle(cornerRadius: fontSize * 0.22)
                .fill(Color(.systemGray6).opacity(0.6))
        )
    }
}

// プレビュー
struct DigitalClockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DigitalClockView()
                .previewDevice("iPhone 15 Pro")
            DigitalClockView()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }
}
