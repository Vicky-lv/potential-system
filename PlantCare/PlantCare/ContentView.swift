//
//  ContentView.swift
//  PlantCare
//
//  Created by Lv Jiaxin on 2025/4/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PlantCareViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            PlantListView(viewModel: viewModel)
                .tabItem {
                    Label("绿植", systemImage: "leaf.fill")
                }
            
            HistoryAndStatsView(viewModel: viewModel)
                .tabItem {
                    Label("历史与统计", systemImage: "chart.bar")
                }
            
            RemindersView(viewModel: viewModel)
                .tabItem {
                    Label("提醒", systemImage: "bell.fill")
                }
        }
        .accentColor(.green)
        .onAppear {
            // 请求通知权限
            NotificationManager.shared.requestAuthorization { _ in }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
