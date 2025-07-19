import Foundation
import CoreData
import SwiftUI
import Combine

class PlantCareViewModel: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var selectedPlant: Plant?
    @Published var selectedActivityType: String?
    @Published var refreshID = UUID() // 用于触发视图刷新
    
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    // MARK: - 绿植管理
    
    func addPlant(name: String, species: String, healthStatus: String) {
        let plant = Plant(context: viewContext)
        plant.id = UUID()
        plant.name = name
        plant.species = species
        plant.addDate = Date()
        plant.healthStatus = healthStatus
        
        saveContext()
    }
    
    func updatePlant(plant: Plant, name: String, species: String, healthStatus: String) {
        plant.name = name
        plant.species = species
        plant.healthStatus = healthStatus
        
        saveContext()
    }
    
    func deletePlant(_ plant: Plant) {
        // 删除相关通知
        NotificationManager.shared.removeAllNotifications(for: plant)
        
        // 删除绿植
        viewContext.delete(plant)
        saveContext()
    }
    
    // MARK: - 养护活动管理
    
    func addCareActivity(plant: Plant, type: String, date: Date, notes: String?) {
        let activity = CareActivity(context: viewContext)
        activity.id = UUID()
        activity.plant = plant
        activity.type = type
        activity.date = date
        activity.notes = notes
        
        saveContext()
    }
    
    func updateCareActivity(activity: CareActivity, type: String, date: Date, notes: String?) {
        activity.type = type
        activity.date = date
        activity.notes = notes
        
        saveContext()
    }
    
    func deleteCareActivity(_ activity: CareActivity) {
        viewContext.delete(activity)
        saveContext()
    }
    
    // MARK: - 通知管理
    
    func scheduleCareNotifications(for plant: Plant, type: String, interval: DateComponents) {
        NotificationManager.shared.scheduleRecurringNotification(for: plant, activityType: type, interval: interval)
    }
    
    func removeCareNotification(for plant: Plant, type: String) {
        NotificationManager.shared.removeNotification(for: plant, activityType: type)
    }
    
    // MARK: - 数据分析
    
    func healthTrend(for plant: Plant) -> Double {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        // 获取过去一个月的养护活动
        let fetchRequest: NSFetchRequest<CareActivity> = CareActivity.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "plant == %@", plant),
            NSPredicate(format: "date >= %@", monthAgo as NSDate)
        ])
        
        do {
            let recentActivities = try viewContext.fetch(fetchRequest)
            
            // 如果没有最近活动，则使用当前健康状态
            if recentActivities.isEmpty {
                return HealthStatus(rawValue: plant.healthStatus ?? "良好")?.score ?? 1.0
            }
            
            // 计算最近健康状态的平均分
            var totalScore = 0.0
            let plantActivities = recentActivities.filter { $0.plant == plant }
            
            for _ in plantActivities {
                if let status = HealthStatus(rawValue: plant.healthStatus ?? "良好") {
                    totalScore += status.score
                }
            }
            
            return plantActivities.isEmpty ? 0 : totalScore / Double(plantActivities.count)
        } catch {
            print("获取活动记录失败: \(error)")
            return 0
        }
    }
    
    func filteredActivities(plant: Plant?, type: String?) -> [CareActivity] {
        var predicates: [NSPredicate] = []
        
        if let plant = plant {
            predicates.append(NSPredicate(format: "plant == %@", plant))
        }
        
        if let type = type {
            predicates.append(NSPredicate(format: "type == %@", type))
        }
        
        let fetchRequest: NSFetchRequest<CareActivity> = CareActivity.fetchRequest()
        
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CareActivity.date, ascending: false)]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("获取养护活动失败: \(error)")
            return []
        }
    }
    
    func monthlyCareCount(type: String, plant: Plant? = nil) -> Int {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        var predicates = [
            NSPredicate(format: "type == %@", type),
            NSPredicate(format: "date >= %@", monthAgo as NSDate)
        ]
        
        if let plant = plant {
            predicates.append(NSPredicate(format: "plant == %@", plant))
        }
        
        let fetchRequest: NSFetchRequest<CareActivity> = CareActivity.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            return try viewContext.fetch(fetchRequest).count
        } catch {
            print("获取养护次数失败: \(error)")
            return 0
        }
    }
    
    func healthStatusDistribution() -> [String: Int] {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        
        do {
            let plants = try viewContext.fetch(fetchRequest)
            let grouped = Dictionary(grouping: plants, by: { $0.healthStatus ?? "未知" })
            return grouped.mapValues { $0.count }
        } catch {
            print("获取健康状态分布失败: \(error)")
            return [:]
        }
    }
    
    // MARK: - 工具方法
    
    private func saveContext() {
        do {
            try viewContext.save()
            refreshID = UUID() // 触发视图刷新
        } catch {
            let nsError = error as NSError
            print("保存失败: \(nsError), \(nsError.userInfo)")
        }
    }
} 