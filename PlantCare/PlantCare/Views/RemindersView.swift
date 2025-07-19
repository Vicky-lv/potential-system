import SwiftUI
import UserNotifications
import CoreData

struct RemindersView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    @State private var reminders: [UNNotificationRequest] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("加载提醒中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if reminders.isEmpty {
                    ContentUnavailableView {
                        Label("暂无提醒", systemImage: "bell.slash")
                    } description: {
                        Text("您尚未为任何绿植设置养护提醒")
                    }
                } else {
                    List {
                        ForEach(reminders, id: \.identifier) { request in
                            ReminderRow(viewModel: viewModel, request: request)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        loadReminders()
                    }
                }
            }
            .navigationTitle("养护提醒")
            .onAppear {
                loadReminders()
            }
        }
    }
    
    private func loadReminders() {
        isLoading = true
        NotificationManager.shared.getAllPendingNotifications { requests in
            reminders = requests
            isLoading = false
        }
    }
}

struct ReminderRow: View {
    @ObservedObject var viewModel: PlantCareViewModel
    let request: UNNotificationRequest
    @State private var showingDeleteAlert = false
    
    // 从identifier解析植物ID和活动类型
    private var reminderInfo: (plantId: UUID?, activityType: String?) {
        let components = request.identifier.components(separatedBy: "_")
        guard components.count >= 2 else { return (nil, nil) }
        
        let plantIdString = components[0]
        let activityType = components[1]
        
        return (UUID(uuidString: plantIdString), activityType)
    }
    
    // 根据plantId查找植物
    private var plant: Plant? {
        guard let plantId = reminderInfo.plantId else { return nil }
        
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", plantId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        let context = PersistenceController.shared.container.viewContext
        let plants = try? context.fetch(fetchRequest)
        return plants?.first
    }
    
    private var triggerDescription: String {
        if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
           let nextTriggerDate = calendarTrigger.nextTriggerDate() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return "下次提醒: \(formatter.string(from: nextTriggerDate))"
        }
        return "未知提醒时间"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let plant = plant {
                    NavigationLink(destination: PlantDetailView(viewModel: viewModel, plant: plant)) {
                        Text(plant.name ?? "未命名")
                            .font(.headline)
                    }
                } else {
                    Text("未知绿植")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let activityType = reminderInfo.activityType {
                    HistoryBadge(type: activityType)
                }
            }
            
            Text(triggerDescription)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: { showingDeleteAlert = true }) {
                Label("删除提醒", systemImage: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
        .alert("删除提醒", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                removeReminder()
            }
        } message: {
            Text("确定要删除这个养护提醒吗？")
        }
    }
    
    private func removeReminder() {
        if let activityType = reminderInfo.activityType,
           let plant = plant {
            viewModel.removeCareNotification(for: plant, type: activityType)
        } else {
            // 如果无法从提醒中找到植物，直接使用通知中心删除
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
        }
    }
}

#Preview {
    RemindersView(viewModel: PlantCareViewModel())
} 