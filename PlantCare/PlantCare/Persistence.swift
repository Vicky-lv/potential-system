import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "PlantCare")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data 加载失败: \(error)")
            }
        }
    }
    
    // 预览和初始化示例数据
    static var preview: PersistenceController = {
        let controller = PersistenceController()
        let viewContext = controller.container.viewContext
        
        createSampleData(in: viewContext)
        
        return controller
    }()
    
    // 创建示例数据
    static func createSampleData(in context: NSManagedObjectContext) {
        // 植物1: 绿萝
        let plant1 = Plant(context: context)
        plant1.id = UUID()
        plant1.name = "绿萝"
        plant1.species = "常春藤科"
        plant1.addDate = Date().addingTimeInterval(-60 * 86400)  // 60天前
        plant1.healthStatus = "良好"
        
        // 植物2: 多肉植物
        let plant2 = Plant(context: context)
        plant2.id = UUID()
        plant2.name = "多肉"
        plant2.species = "景天科"
        plant2.addDate = Date().addingTimeInterval(-45 * 86400)  // 45天前
        plant2.healthStatus = "一般"
        
        // 植物3: 发财树
        let plant3 = Plant(context: context)
        plant3.id = UUID()
        plant3.name = "发财树"
        plant3.species = "夹竹桃科"
        plant3.addDate = Date().addingTimeInterval(-30 * 86400)  // 30天前
        plant3.healthStatus = "良好"
        
        // 植物4: 芦荟
        let plant4 = Plant(context: context)
        plant4.id = UUID()
        plant4.name = "芦荟"
        plant4.species = "百合科"
        plant4.addDate = Date().addingTimeInterval(-20 * 86400)  // 20天前
        plant4.healthStatus = "叶黄"
        
        // 为绿萝添加养护记录
        addCareActivity(context: context, plant: plant1, type: "浇水", daysAgo: 1, notes: "水量适中")
        addCareActivity(context: context, plant: plant1, type: "浇水", daysAgo: 8, notes: "叶片喷水")
        addCareActivity(context: context, plant: plant1, type: "施肥", daysAgo: 15, notes: "使用有机肥")
        addCareActivity(context: context, plant: plant1, type: "修剪", daysAgo: 22, notes: "剪去枯黄叶")
        
        // 为多肉添加养护记录
        addCareActivity(context: context, plant: plant2, type: "浇水", daysAgo: 3, notes: "少量浇水")
        addCareActivity(context: context, plant: plant2, type: "换盆", daysAgo: 14, notes: "使用透气花盆")
        
        // 为发财树添加养护记录
        addCareActivity(context: context, plant: plant3, type: "浇水", daysAgo: 2, notes: nil)
        addCareActivity(context: context, plant: plant3, type: "施肥", daysAgo: 10, notes: "稀释液体肥")
        
        // 为芦荟添加养护记录
        addCareActivity(context: context, plant: plant4, type: "浇水", daysAgo: 5, notes: "少量浇水")
        addCareActivity(context: context, plant: plant4, type: "清洁", daysAgo: 12, notes: "擦拭叶片")
        
        try? context.save()
    }
    
    // 辅助方法：创建养护活动
    private static func addCareActivity(context: NSManagedObjectContext, plant: Plant, type: String, daysAgo: Int, notes: String?) {
        let activity = CareActivity(context: context)
        activity.id = UUID()
        activity.plant = plant
        activity.type = type
        activity.date = Date().addingTimeInterval(-Double(daysAgo * 86400))
        activity.notes = notes
    }
    
    // 初始化应用时添加示例数据的方法
    func initializeWithSampleData() {
        // 检查是否已经有数据
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        do {
            let count = try container.viewContext.count(for: fetchRequest)
            // 只有当没有植物数据时才添加示例数据
            if count == 0 {
                PersistenceController.createSampleData(in: container.viewContext)
            }
        } catch {
            print("检查数据失败: \(error)")
        }
    }
} 