import SwiftUI

struct AddReminderView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    let plant: Plant
    @Binding var isPresented: Bool
    
    @State private var activityType: String = CareActivityType.watering.rawValue
    @State private var reminderDate = Date()
    @State private var reminderInterval = 3 // 天数
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isNotificationAuthorized = false
    
    // 提醒周期选项
    let intervalOptions = [1, 2, 3, 5, 7, 10, 14, 21, 30, 60, 90]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("提醒内容")) {
                    Picker("养护类型", selection: $activityType) {
                        ForEach(CareActivityType.allCases(), id: \.self) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("提醒频率")) {
                    Picker("重复周期", selection: $reminderInterval) {
                        ForEach(intervalOptions, id: \.self) { days in
                            Text("\(days) 天").tag(days)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("开始日期")) {
                    DatePicker("首次提醒", selection: $reminderDate, displayedComponents: .date)
                }
                
                if !isNotificationAuthorized {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("需要授权通知权限才能接收提醒")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("设置养护提醒")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveReminder()
                    }
                }
            }
            .alert("提示", isPresented: $showAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                checkNotificationPermission()
            }
        }
    }
    
    private func checkNotificationPermission() {
        NotificationManager.shared.requestAuthorization { granted in
            isNotificationAuthorized = granted
        }
    }
    
    private func saveReminder() {
        if !isNotificationAuthorized {
            // 如果未授权，再次请求授权
            NotificationManager.shared.requestAuthorization { granted in
                isNotificationAuthorized = granted
                if granted {
                    scheduleNotification()
                } else {
                    alertMessage = "请在设置中启用通知功能以接收提醒"
                    showAlert = true
                }
            }
        } else {
            scheduleNotification()
        }
    }
    
    private func scheduleNotification() {
        // 创建日期组件
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponents.hour = 9 // 默认早上9点提醒
        
        // 设置重复的日期组件
        var intervalDateComponents = DateComponents()
        intervalDateComponents.day = reminderInterval
        
        // 安排通知
        viewModel.scheduleCareNotifications(for: plant, type: activityType, interval: intervalDateComponents)
        
        alertMessage = "提醒已设置，将每\(reminderInterval)天提醒一次"
        showAlert = true
        
        // 关闭视图
        isPresented = false
    }
}

#Preview {
    NavigationStack {
        AddReminderView(
            viewModel: PlantCareViewModel(),
            plant: Plant(),
            isPresented: .constant(true)
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 