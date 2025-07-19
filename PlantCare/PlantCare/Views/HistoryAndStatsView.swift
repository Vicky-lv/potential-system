import SwiftUI

struct HistoryAndStatsView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    @State private var showingHistoryOnly = false
    @State private var animate = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 头部统计区域
                        VStack(spacing: 0) {
                            ZStack {
                                // 背景渐变
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppColors.primaryGreen.opacity(0.9),
                                                AppColors.primaryGreen.opacity(0.7)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(
                                        color: AppColors.primaryGreen.opacity(0.3),
                                        radius: 10, x: 0, y: 5
                                    )
                                
                                // 内容
                                VStack(spacing: 15) {
                                    // 标题和图标
                                    HStack {
                                        Text("养护概览")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "leaf.fill")
                                            .font(.title2)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    // 统计小卡片
                                    HStack(spacing: 10) {
                                        let plants = try? viewModel.viewContext.fetch(Plant.fetchRequest())
                                        let activities = viewModel.filteredActivities(plant: nil, type: nil)
                                        let wateringCount = viewModel.monthlyCareCount(type: CareActivityType.watering.rawValue)
                                        
                                        StatisticCard(
                                            title: "我的绿植",
                                            value: "\(plants?.count ?? 0)",
                                            icon: "leaf.circle.fill",
                                            color: .white
                                        )
                                        
                                        StatisticCard(
                                            title: "活动记录",
                                            value: "\(activities.count)",
                                            icon: "list.clipboard.fill",
                                            color: .white
                                        )
                                        
                                        StatisticCard(
                                            title: "浇水次数",
                                            value: "\(wateringCount)",
                                            icon: "drop.fill",
                                            color: .white
                                        )
                                    }
                                }
                                .padding()
                            }
                            .frame(height: 160)
                        }
                        .padding(.horizontal)
                        
                        // 历史记录部分
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("最近养护记录")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                NavigationLink(destination: ActivityHistoryView(viewModel: viewModel, plant: nil)) {
                                    HStack(spacing: 4) {
                                        Text("查看全部")
                                            .font(.caption)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                    }
                                    .foregroundColor(AppColors.primaryGreen)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .stroke(AppColors.primaryGreen, lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            let activities = viewModel.filteredActivities(plant: nil, type: nil)
                            
                            if activities.isEmpty {
                                ContentUnavailableView {
                                    Label("暂无养护记录", systemImage: "leaf.arrow.circlepath")
                                } description: {
                                    Text("您尚未记录任何养护活动")
                                }
                                .frame(height: 200)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(Array(activities.prefix(10))) { activity in
                                            ActivityCard(activity: activity, viewModel: viewModel)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.vertical)
                        
                        // 统计部分
                        if !showingHistoryOnly {
                            VStack(spacing: 20) {
                                // 健康状态分布
                                HealthDistributionView(distribution: viewModel.healthStatusDistribution())
                                    .padding(.horizontal)
                                
                                // 月度养护统计
                                MonthlyCareStatsView(plantViewModel: viewModel, plant: nil)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("历史与统计")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        withAnimation(.spring(dampingFraction: 0.7)) {
                            showingHistoryOnly.toggle()
                        }
                    }) {
                        Image(systemName: showingHistoryOnly ? "chart.bar" : "list.bullet")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppColors.primaryGreen,
                                                AppColors.secondaryGreen
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: AppColors.primaryGreen.opacity(0.5), radius: 3, x: 0, y: 2)
                            )
                    }
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .opacity(animate ? 1 : 0.5)
                .scaleEffect(animate ? 1.1 : 1)
                .padding(.bottom, 2)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(color.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

struct ActivityCard: View {
    let activity: CareActivity
    let viewModel: PlantCareViewModel
    
    var body: some View {
        if let plant = activity.plant {
            NavigationLink(destination: PlantDetailView(viewModel: viewModel, plant: plant)) {
                VStack(alignment: .leading, spacing: 8) {
                    // 头部：图标和日期
                    HStack {
                        ZStack {
                            Circle()
                                .fill(activityColor(for: activity.type ?? ""))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: activityIcon(for: activity.type ?? ""))
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text(dateFormatter.string(from: activity.date ?? Date()))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 绿植名称和活动类型
                    Text(plant.name ?? "未命名")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(activity.type ?? "未知活动")
                        .font(.subheadline)
                        .foregroundColor(activityColor(for: activity.type ?? ""))
                        .lineLimit(1)
                    
                    if let notes = activity.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .frame(width: 160, height: 150)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
    
    private func activityIcon(for type: String) -> String {
        switch type {
        case "浇水": return "drop.fill"
        case "施肥": return "sparkles"
        case "换盆": return "arrow.triangle.swap"
        case "修剪": return "scissors"
        case "清洁": return "bolt.shield"
        default: return "questionmark.circle"
        }
    }
    
    private func activityColor(for type: String) -> Color {
        switch type {
        case "浇水": return AppColors.waterBlue
        case "施肥": return AppColors.fertilizerYellow
        case "换盆": return AppColors.soilBrown
        case "修剪": return AppColors.pruneOrange
        case "清洁": return AppColors.cleanPurple
        default: return .gray
        }
    }
}

struct HistoryBadge: View {
    let type: String
    
    var color: Color {
        switch type {
        case "浇水": return AppColors.waterBlue
        case "施肥": return AppColors.fertilizerYellow
        case "换盆": return AppColors.soilBrown
        case "修剪": return AppColors.pruneOrange
        case "清洁": return AppColors.cleanPurple
        default: return .gray
        }
    }
    
    var body: some View {
        Text(type)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.15), color.opacity(0.25)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .foregroundColor(color)
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
    }
}

#Preview {
    HistoryAndStatsView(viewModel: PlantCareViewModel())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 