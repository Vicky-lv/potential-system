import SwiftUI

struct PlantDetailView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    let plant: Plant
    
    @State private var showingAddActivity = false
    @State private var showingEditPlant = false
    @State private var showingAddReminder = false
    @State private var isHeaderExpanded = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 植物基本信息头部卡片
                VStack {
                    // 健康状态和基本信息卡片
                    ZStack {
                        // 健康状态背景
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        statusColor(for: plant.healthStatus ?? "未知").opacity(0.8),
                                        statusColor(for: plant.healthStatus ?? "未知").opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(
                                color: statusColor(for: plant.healthStatus ?? "未知").opacity(0.3),
                                radius: 10, x: 0, y: 5
                            )
                        
                        VStack(spacing: 15) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(plant.name ?? "植物详情")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 12) {
                                        HStack {
                                            Image(systemName: "leaf.fill")
                                                .foregroundColor(.white.opacity(0.9))
                                            Text(plant.species ?? "未知种类")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                        
                                        HStack {
                                            Image(systemName: "calendar")
                                                .foregroundColor(.white.opacity(0.9))
                                            Text(dateFormatter.string(from: plant.addDate ?? Date()))
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: { showingEditPlant = true }) {
                                    Image(systemName: "pencil")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.3))
                                        )
                                }
                            }
                            
                            if isHeaderExpanded {
                                // 健康状态详情
                                ProgressRing(
                                    progress: viewModel.healthTrend(for: plant),
                                    color: .white
                                )
                                
                                Text(plant.healthStatus ?? "未知")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.25))
                                    )
                            } else {
                                HStack(spacing: 40) {
                                    VStack {
                                        Text("\(Int(viewModel.healthTrend(for: plant) * 100))%")
                                            .font(.system(size: 26, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("健康度")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    VStack {
                                        let activities = viewModel.filteredActivities(plant: plant, type: nil)
                                        Text("\(activities.count)")
                                            .font(.system(size: 26, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("活动记录")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    VStack {
                                        Text(daysSinceAdded)
                                            .font(.system(size: 26, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("养护天数")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                            
                            // 展开/收起按钮
                            Button(action: {
                                withAnimation(.spring(dampingFraction: 0.7)) {
                                    isHeaderExpanded.toggle()
                                }
                            }) {
                                Image(systemName: isHeaderExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
                // 养护活动历史卡片
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("近期养护记录")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showingAddActivity = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("添加")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppColors.primaryGreen,
                                                AppColors.secondaryGreen
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .foregroundColor(.white)
                            .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 3, x: 0, y: 2)
                        }
                    }
                    
                    let activities = viewModel.filteredActivities(plant: plant, type: nil)
                    
                    if activities.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.3))
                                .padding(.bottom, 5)
                            
                            Text("暂无养护记录")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("点击添加按钮记录您的第一次养护活动")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        ForEach(Array(activities.prefix(5).enumerated()), id: \.element.id) { index, activity in
                            EnhancedCareActivityRow(activity: activity)
                                .padding(.vertical, 5)
                            
                            if index < activities.prefix(5).count - 1 {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                        
                        if activities.count > 5 {
                            NavigationLink(destination: ActivityHistoryView(viewModel: viewModel, plant: plant)) {
                                Text("查看全部 \(activities.count) 条记录")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.primaryGreen)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 5)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // 月度统计卡片
                MonthlyCareStatsView(plantViewModel: viewModel, plant: plant)
                    .padding(.horizontal)
                
                // 提醒按钮
                Button(action: { showingAddReminder = true }) {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("设置养护提醒")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.waterBlue, AppColors.waterBlue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: AppColors.waterBlue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddActivity) {
            AddCareActivityView(viewModel: viewModel, plant: plant, isPresented: $showingAddActivity)
        }
        .sheet(isPresented: $showingEditPlant) {
            EditPlantView(viewModel: viewModel, plant: plant, isPresented: $showingEditPlant)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(viewModel: viewModel, plant: plant, isPresented: $showingAddReminder)
        }
    }
    
    private var daysSinceAdded: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: plant.addDate ?? Date(), to: Date())
        if let days = components.day {
            return "\(days)"
        }
        return "0"
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "良好": return AppColors.primaryGreen
        case "一般": return AppColors.fertilizerYellow
        case "叶黄": return AppColors.pruneOrange
        case "萎蔫": return .red
        default: return .gray
        }
    }
}

struct EnhancedCareActivityRow: View {
    let activity: CareActivity
    
    var body: some View {
        HStack(spacing: 15) {
            // 活动图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                activityColor(for: activity.type ?? "").opacity(0.8),
                                activityColor(for: activity.type ?? "")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: activityColor(for: activity.type ?? "").opacity(0.3), radius: 3, x: 0, y: 2)
                
                activityIcon(for: activity.type ?? "")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(activity.type ?? "未知活动")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(timeAgoSince(activity.date ?? Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(dateFormatter.string(from: activity.date ?? Date()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let notes = activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                        .lineLimit(2)
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func timeAgoSince(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day)天前"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)小时前"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)分钟前"
        } else {
            return "刚刚"
        }
    }
    
    private func activityIcon(for type: String) -> Image {
        let iconName: String
        
        switch type {
        case "浇水":
            iconName = "drop.fill"
        case "施肥":
            iconName = "sparkles"
        case "换盆":
            iconName = "arrow.triangle.swap"
        case "修剪":
            iconName = "scissors"
        case "清洁":
            iconName = "bolt.shield"
        default:
            iconName = "questionmark.circle"
        }
        
        return Image(systemName: iconName)
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

#Preview {
    NavigationStack {
        PlantDetailView(
            viewModel: PlantCareViewModel(),
            plant: Plant()
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 