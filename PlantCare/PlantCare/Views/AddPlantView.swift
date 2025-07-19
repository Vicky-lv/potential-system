import SwiftUI

struct AddPlantView: View {
    @ObservedObject var viewModel: PlantCareViewModel
    @Binding var isPresented: Bool
    
    @State private var name: String = ""
    @State private var species: String = ""
    @State private var healthStatus: String = HealthStatus.excellent.rawValue
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
            .navigationTitle("添加绿植")
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
        
        viewModel.addPlant(name: name, species: species, healthStatus: healthStatus)
        isPresented = false
    }
}

#Preview {
    AddPlantView(viewModel: PlantCareViewModel(), isPresented: .constant(true))
} 