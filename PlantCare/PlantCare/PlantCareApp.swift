//
//  PlantCareApp.swift
//  PlantCare
//
//  Created by 今安在 on 2025/4/21.
//

import SwiftUI

@main
struct PlantCareApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // 初始化应用时添加示例数据
        persistenceController.initializeWithSampleData()
        
        // 配置全局UI样式
        configureAppAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    private func configureAppAppearance() {
        // 设置导航栏标题样式
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.green),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        // 设置导航栏按钮样式
        UINavigationBar.appearance().tintColor = UIColor(Color.green)
        
        // 设置标签栏样式
        UITabBar.appearance().tintColor = UIColor(Color.green)
    }
}
