import SwiftUI
import Combine

class PointManager: ObservableObject {
    @Published var currentPoints: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let pointsKey = "user_points"
    
    init() {
        loadPoints()
    }
    
    // ポイントを追加（広告視聴時）
    func addPoints(_ points: Int) {
        currentPoints += points
        savePoints()
    }
    
    // ポイントを消費（AI機能利用時）
    func consumePoints(_ points: Int) -> Bool {
        if currentPoints >= points {
            currentPoints -= points
            savePoints()
            return true
        }
        return false
    }
    
    // ポイントが足りるかチェック
    func hasEnoughPoints(_ requiredPoints: Int) -> Bool {
        return currentPoints >= requiredPoints
    }
    
    private func savePoints() {
        userDefaults.set(currentPoints, forKey: pointsKey)
    }
    
    private func loadPoints() {
        currentPoints = userDefaults.integer(forKey: pointsKey)
    }
}
