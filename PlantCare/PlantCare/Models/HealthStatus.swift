import Foundation

enum HealthStatus: String, CaseIterable {
    case excellent = "良好" // 评分: 1.0
    case good = "一般" // 评分: 0.75
    case yellowing = "叶黄" // 评分: 0.5
    case wilting = "萎蔫" // 评分: 0.25
    
    var score: Double {
        switch self {
        case .excellent: return 1.0
        case .good: return 0.75
        case .yellowing: return 0.5
        case .wilting: return 0.25
        }
    }
    
    static func allCases(_ locale: Locale = Locale.current) -> [HealthStatus] {
        return [.excellent, .good, .yellowing, .wilting]
    }
} 