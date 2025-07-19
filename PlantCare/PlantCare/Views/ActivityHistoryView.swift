import SwiftUI

struct ActivityHistoryView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    let plant: Plant?
    @State private var filterType: String?
    @State private var searchText = ""
    
    var body: some View {
        List {
            // 筛选按钮组
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button("全部") { filterType = nil }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(filterType == nil ? Color.green : Color.gray.opacity(0.2))
                        .foregroundColor(filterType == nil ? .white : .primary)
                        .cornerRadius(16)
                    
                    Button("浇水") { filterType = "浇水" }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(filterType == "浇水" ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(filterType == "浇水" ? .white : .primary)
                        .cornerRadius(16)
                    
                    Button("施肥") { filterType = "施肥" }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(filterType == "施肥" ? Color.yellow : Color.gray.opacity(0.2))
                        .foregroundColor(filterType == "施肥" ? .white : .primary)
                        .cornerRadius(16)
                    
                    Button("换盆") { filterType = "换盆" }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(filterType == "换盆" ? Color.brown : Color.gray.opacity(0.2))
                        .foregroundColor(filterType == "换盆" ? .white : .primary)
                        .cornerRadius(16)
                    
                    Button("修剪") { filterType = "修剪" }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(filterType == "修剪" ? Color.orange : Color.gray.opacity(0.2))
                        .foregroundColor(filterType == "修剪" ? .white : .primary)
                        .cornerRadius(16)
                    
                    Button("清洁") { filterType = "清洁" }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(filterType == "清洁" ? Color.purple : Color.gray.opacity(0.2))
                        .foregroundColor(filterType == "清洁" ? .white : .primary)
                        .cornerRadius(16)
                }
                .padding(.vertical, 5)
            }
            .listRowInsets(EdgeInsets())
            .padding(.horizontal)
            
            // 活动列表
            let activities = filteredActivities()
            
            if activities.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Text("暂无符合条件的养护记录")
                            .foregroundColor(.secondary)
                        
                        Button("重置筛选条件") {
                            filterType = nil
                            searchText = ""
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    Spacer()
                }
            } else {
                ForEach(activities) { activity in
                    activityRow(for: activity)
                }
            }
        }
        .navigationTitle(plant?.name ?? "养护历史记录")
        .searchable(text: $searchText, prompt: "搜索备注内容")
    }
    
    @ViewBuilder
    private func activityRow(for activity: CareActivity) -> some View {
        if let plant = activity.plant {
            NavigationLink(destination: PlantDetailView(viewModel: viewModel, plant: plant)) {
                activityRowContent(for: activity)
            }
        } else {
            activityRowContent(for: activity)
        }
    }
    
    private func activityRowContent(for activity: CareActivity) -> some View {
        HStack {
            // 图标
            Circle()
                .fill(activityColor(for: activity.type ?? ""))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: activityIcon(for: activity.type ?? ""))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                // 植物名称
                Text(activity.plant?.name ?? "未命名")
                    .font(.headline)
                
                // 活动类型和日期
                HStack {
                    Text(activity.type ?? "未知活动")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(formatDate(activity.date ?? Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 备注信息
                if let notes = activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // 筛选活动记录
    private func filteredActivities() -> [CareActivity] {
        var activities = viewModel.filteredActivities(plant: plant, type: filterType)
        
        if !searchText.isEmpty {
            activities = activities.filter { activity in
                guard let notes = activity.notes else { return false }
                return notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return activities
    }
    
    // 日期格式化
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 获取活动类型对应的图标
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
    
    // 获取活动类型对应的颜色
    private func activityColor(for type: String) -> Color {
        switch type {
        case "浇水": return .blue
        case "施肥": return .yellow
        case "换盆": return .brown
        case "修剪": return .orange
        case "清洁": return .purple
        default: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        ActivityHistoryView(viewModel: PlantCareViewModel(), plant: nil)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 