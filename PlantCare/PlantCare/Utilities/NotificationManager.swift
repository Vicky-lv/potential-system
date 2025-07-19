import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知权限错误: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleNotification(for plant: Plant, activityType: String, interval: TimeInterval, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "\(plant.name ?? "") 需要\(activityType)"
        content.body = "今天是\(plant.name ?? "")的\(activityType)时间！"
        content.sound = .default
        
        // 创建通知日期组件
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        // 创建触发器
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // 创建通知请求
        let identifier = "\(plant.id?.uuidString ?? "")_\(activityType)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // 添加通知请求
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加通知失败: \(error)")
            }
        }
    }
    
    func scheduleRecurringNotification(for plant: Plant, activityType: String, interval: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "\(plant.name ?? "") 需要\(activityType)"
        content.body = "今天是\(plant.name ?? "")的\(activityType)时间！"
        content.sound = .default
        
        // 创建触发器
        let trigger = UNCalendarNotificationTrigger(dateMatching: interval, repeats: true)
        
        // 创建通知请求
        let identifier = "\(plant.id?.uuidString ?? "")_\(activityType)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // 添加通知请求
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加通知失败: \(error)")
            }
        }
    }
    
    func removeNotification(for plant: Plant, activityType: String) {
        let identifier = "\(plant.id?.uuidString ?? "")_\(activityType)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func removeAllNotifications(for plant: Plant) {
        let identifiers = CareActivityType.allCases().map { "\(plant.id?.uuidString ?? "")_\($0.rawValue)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func getAllPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
} 