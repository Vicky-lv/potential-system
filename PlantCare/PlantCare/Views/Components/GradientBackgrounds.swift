import SwiftUI

// 绿色系渐变背景
struct GreenGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.8, blue: 0.4),
                Color(red: 0.1, green: 0.6, blue: 0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// 蓝色系渐变背景（用于浇水相关）
struct WaterGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.2, green: 0.6, blue: 0.9),
                Color(red: 0.1, green: 0.4, blue: 0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// 棕色系渐变背景（用于换盆相关）
struct SoilGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.6, green: 0.4, blue: 0.2),
                Color(red: 0.5, green: 0.3, blue: 0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// 黄色系渐变背景（用于施肥相关）
struct FertilizeGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.9, green: 0.8, blue: 0.2),
                Color(red: 0.8, green: 0.7, blue: 0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// 紫色系渐变背景（用于清洁相关）
struct CleanGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.6, green: 0.3, blue: 0.9),
                Color(red: 0.5, green: 0.2, blue: 0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// 橙色系渐变背景（用于修剪相关）
struct PruneGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.9, green: 0.5, blue: 0.2),
                Color(red: 0.8, green: 0.4, blue: 0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// 根据活动类型返回对应的渐变色
struct ActivityGradient: View {
    let type: String
    
    var body: some View {
        switch type {
        case "浇水":
            WaterGradient()
        case "施肥":
            FertilizeGradient()
        case "换盆":
            SoilGradient()
        case "修剪":
            PruneGradient()
        case "清洁":
            CleanGradient()
        default:
            GreenGradient()
        }
    }
} 