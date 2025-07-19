# PlantCare 绿植养殖记录 iOS App

## 项目简介

**PlantCare** 是一款基于 Swift 和 SwiftUI 开发的 iOS 应用，帮助用户记录和管理家中绿植的养护信息，包括浇水、施肥、健康状态、养护提醒和统计分析。应用完全离线运行，数据本地存储，适合绿植爱好者和 iOS 开发学习者。

## 主要功能

- **绿植信息管理**：添加、编辑、删除绿植，记录名称、种类、健康状态等。
- **养护活动记录**：记录每株绿植的浇水、施肥、换盆等养护活动及时间。
- **养护历史与统计**：按绿植或活动类型查看历史记录，统计每月/每周养护频率，展示健康状态分布。
- **养护提醒**：为每株绿植设置周期性提醒（如浇水、施肥），通过本地通知提醒用户。
- **健康状态跟踪**：记录和展示绿植健康趋势。
- **多语言与暗黑模式**：支持中英文界面和暗黑/浅色模式切换。

## 技术架构

- **架构模式**：MVVM（Model-View-ViewModel）
- **主要技术**：
  - Swift 5.9+
  - SwiftUI（声明式 UI）
  - Core Data（本地数据持久化）
  - UserNotifications（本地通知）
- **目录结构**：
  - `PlantCare/PlantCare/Models/`：数据模型
  - `PlantCare/PlantCare/ViewModels/`：业务逻辑与数据管理
  - `PlantCare/PlantCare/Views/`：界面与交互
  - `PlantCare/PlantCare/Utilities/`：工具类
  - `PlantCare/PlantCare/Extensions/`：扩展
  - `PlantCare/PlantCare/Assets.xcassets/`：资源文件

## 快速开始

### 环境要求

- Xcode 16 或更高版本
- iOS 17.0 及以上设备或模拟器

### 安装与运行

1. 克隆本仓库到本地：
   ```bash
   git clone <your-repo-url>
   ```
2. 用 Xcode 打开 `PlantCare/PlantCare.xcodeproj`。
3. 选择目标设备或模拟器，点击运行（Run）。

### 主要界面

- **绿植列表**：浏览和管理所有绿植。
- **历史与统计**：查看养护历史、健康趋势和统计分析。
- **提醒**：管理所有养护提醒。

## 代码示例

应用入口（`PlantCareApp.swift`）：

```swift
@main
struct PlantCareApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
```

主界面（`ContentView.swift`）采用 TabView：

```swift
TabView {
    PlantListView(viewModel: viewModel).tabItem { Label("绿植", systemImage: "leaf.fill") }
    HistoryAndStatsView(viewModel: viewModel).tabItem { Label("历史与统计", systemImage: "chart.bar") }
    RemindersView(viewModel: viewModel).tabItem { Label("提醒", systemImage: "bell.fill") }
}
```

## 本地化与无障碍

- 支持中英文界面（`Localizable.strings`）。
- 主要控件均添加无障碍标签，适配 VoiceOver。

## 贡献指南

欢迎提交 Issue 或 Pull Request 改进本项目。建议遵循 Swift 代码规范和 MVVM 架构模式。

## License

本项目仅供学习和个人使用，禁止商业用途。如需商用请联系作者。 
