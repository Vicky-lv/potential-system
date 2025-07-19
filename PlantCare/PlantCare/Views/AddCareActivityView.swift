import SwiftUI

struct AddCareActivityView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    let plant: Plant
    @Binding var isPresented: Bool
    
    @State private var activityType: String = CareActivityType.watering.rawValue
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("活动类型")) {
                    Picker("类型", selection: $activityType) {
                        ForEach(CareActivityType.allCases(), id: \.self) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("日期和时间")) {
                    DatePicker("日期", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("备注")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("添加养护记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveCareActivity()
                    }
                }
            }
            .alert("错误", isPresented: $showAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveCareActivity() {
        viewModel.addCareActivity(
            plant: plant,
            type: activityType,
            date: date,
            notes: notes.isEmpty ? nil : notes
        )
        
        isPresented = false
    }
}

#Preview {
    NavigationStack {
        AddCareActivityView(
            viewModel: PlantCareViewModel(),
            plant: Plant(),
            isPresented: .constant(true)
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 