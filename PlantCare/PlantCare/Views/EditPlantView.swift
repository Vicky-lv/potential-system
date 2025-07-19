import SwiftUI

struct EditPlantView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    let plant: Plant
    @Binding var isPresented: Bool
    
    @State private var name: String
    @State private var species: String
    @State private var healthStatus: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(viewModel: PlantCareViewModel, plant: Plant, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self.plant = plant
        self._isPresented = isPresented
        
        // 初始化状态变量
        _name = State(initialValue: plant.name ?? "")
        _species = State(initialValue: plant.species ?? "")
        _healthStatus = State(initialValue: plant.healthStatus ?? HealthStatus.excellent.rawValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("绿植名称", text: $name)
                    TextField("品种", text: $species)
                }
                
                Section(header: Text("健康状态")) {
                    Picker("当前状态", selection: $healthStatus) {
                        ForEach(HealthStatus.allCases(), id: \.self) { status in
                            Text(status.rawValue).tag(status.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("编辑绿植")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        savePlant()
                    }
                    .disabled(name.isEmpty || species.isEmpty)
                }
            }
            .alert("错误", isPresented: $showAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func savePlant() {
        guard !name.isEmpty, !species.isEmpty else {
            alertMessage = "请填写绿植名称和品种"
            showAlert = true
            return
        }
        
        viewModel.updatePlant(plant: plant, name: name, species: species, healthStatus: healthStatus)
        isPresented = false
    }
}

#Preview {
    NavigationStack {
        EditPlantView(
            viewModel: PlantCareViewModel(),
            plant: Plant(),
            isPresented: .constant(true)
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 