import Foundation

enum CareActivityType: String, CaseIterable {
    case watering = "浇水"
    case fertilizing = "施肥"
    case repotting = "换盆"
    case pruning = "修剪"
    case cleaning = "清洁"
    
    static func allCases(_ locale: Locale = Locale.current) -> [CareActivityType] {
        return [.watering, .fertilizing, .repotting, .pruning, .cleaning]
    }
} 