import SwiftUI

struct PlantListView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    @State private var showingAddPlant = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Plant.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Plant.name, ascending: true)]
    ) private var plants: FetchedResults<Plant>
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack {
                    if plants.isEmpty {
                        ContentUnavailableView {
                            Label("暂无绿植", systemImage: "leaf")
                        } description: {
                            Text("点击右上角加号添加您的第一株绿植")
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(plants) { plant in
                                    PlantCard(viewModel: viewModel, plant: plant)
                                        .contextMenu {
                                            Button(action: {
                                                viewModel.deletePlant(plant)
                                            }) {
                                                Label("删除", systemImage: "trash")
                                            }
                                        }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("我的绿植")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPlant = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
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
            .sheet(isPresented: $showingAddPlant) {
                AddPlantView(viewModel: viewModel, isPresented: $showingAddPlant)
            }
        }
    }
}

struct PlantCard: View {
    @ObservedObject var viewModel: PlantCareViewModel
    let plant: Plant
    
    var body: some View {
        NavigationLink(destination: PlantDetailView(viewModel: viewModel, plant: plant)) {
            HStack(spacing: 16) {
                // 健康状态指示器
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    statusColor(for: plant.healthStatus ?? "未知").opacity(0.8),
                                    statusColor(for: plant.healthStatus ?? "未知")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: statusColor(for: plant.healthStatus ?? "未知").opacity(0.4), radius: 3, x: 0, y: 2)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.name ?? "未命名")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(plant.species ?? "未知种类")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(dateFormatter.string(from: plant.addDate ?? Date()))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HealthStatusBadge(status: plant.healthStatus ?? "未知")
                    
                    Spacer()
                    
                    if let lastActivity = getLastActivity(for: plant) {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text(timeAgoSince(lastActivity.date ?? Date()))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private func getLastActivity(for plant: Plant) -> CareActivity? {
        let activities = viewModel.filteredActivities(plant: plant, type: nil)
        return activities.first
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

struct HealthStatusBadge: View {
    let status: String
    
    var color: Color {
        switch status {
        case "良好": return AppColors.primaryGreen
        case "一般": return AppColors.fertilizerYellow
        case "叶黄": return AppColors.pruneOrange
        case "萎蔫": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        Text(status)
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
    PlantListView(viewModel: PlantCareViewModel())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 