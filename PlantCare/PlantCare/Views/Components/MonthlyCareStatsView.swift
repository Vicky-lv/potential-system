import SwiftUI

struct MonthlyCareStatsView: View {
    let plantViewModel: PlantCareViewModel
    let plant: Plant?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("过去30天养护统计")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption)
                    Text("统计")
                        .font(.caption)
                }
                .foregroundColor(AppColors.primaryGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppColors.primaryGreen.opacity(0.1))
                )
            }
            
            // 活动类型卡片网格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                CareStatCard(
                    title: "浇水",
                    count: plantViewModel.monthlyCareCount(type: CareActivityType.watering.rawValue, plant: plant),
                    icon: "drop.fill",
                    type: CareActivityType.watering.rawValue
                )
                
                CareStatCard(
                    title: "施肥",
                    count: plantViewModel.monthlyCareCount(type: CareActivityType.fertilizing.rawValue, plant: plant),
                    icon: "sparkles",
                    type: CareActivityType.fertilizing.rawValue
                )
                
                CareStatCard(
                    title: "修剪",
                    count: plantViewModel.monthlyCareCount(type: CareActivityType.pruning.rawValue, plant: plant),
                    icon: "scissors",
                    type: CareActivityType.pruning.rawValue
                )
                
                CareStatCard(
                    title: "换盆",
                    count: plantViewModel.monthlyCareCount(type: CareActivityType.repotting.rawValue, plant: plant),
                    icon: "arrow.triangle.swap",
                    type: CareActivityType.repotting.rawValue
                )
                
                CareStatCard(
                    title: "清洁",
                    count: plantViewModel.monthlyCareCount(type: CareActivityType.cleaning.rawValue, plant: plant),
                    icon: "sparkles",
                    type: CareActivityType.cleaning.rawValue
                )
                
                // 总次数卡片
                let totalCount = CareActivityType.allCases().reduce(0) { total, type in
                    total + plantViewModel.monthlyCareCount(type: type.rawValue, plant: plant)
                }
                
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.primaryGreen.opacity(0.8),
                                        AppColors.primaryGreen
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 3, x: 0, y: 2)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    Text("总计")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("\(totalCount)次")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primaryGreen, AppColors.primaryGreen.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    Color.white.opacity(0.95)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CareStatCard: View {
    let title: String
    let count: Int
    let icon: String
    let type: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                activityColor(for: type).opacity(0.8),
                                activityColor(for: type)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: activityColor(for: type).opacity(0.3), radius: 3, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
            
            Text("\(count)次")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [activityColor(for: type), activityColor(for: type).opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.white.opacity(0.95)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
        )
    }
    
    private func activityColor(for type: String) -> Color {
        switch type {
        case "浇水": return AppColors.waterBlue
        case "施肥": return AppColors.fertilizerYellow
        case "换盆": return AppColors.soilBrown
        case "修剪": return AppColors.pruneOrange
        case "清洁": return AppColors.cleanPurple
        default: return AppColors.primaryGreen
        }
    }
} 