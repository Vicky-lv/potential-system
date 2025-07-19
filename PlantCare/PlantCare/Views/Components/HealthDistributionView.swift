import SwiftUI

struct HealthDistributionView: View {
    let distribution: [String: Int]
    
    private var totalCount: Int {
        distribution.values.reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("健康状态分布")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: "chart.pie.fill")
                        .font(.caption)
                    Text("统计")
                        .font(.caption)
                }
                .foregroundColor(AppColors.primaryGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppColors.primaryGreen.opacity(0.1))
                )
            }
            
            if distribution.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "leaf.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.3))
                        .padding(.bottom, 5)
                    
                    Text("暂无数据")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("添加更多绿植后在这里查看统计")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                VStack(spacing: 20) {
                    // 饼图视图
                    HStack(alignment: .center) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGroupedBackground))
                                .frame(width: 130, height:.none)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            HealthPieChart(distribution: distribution)
                                .frame(width: 130, height: 130)
                            
                            VStack(spacing: 0) {
                                Text("\(totalCount)")
                                    .font(.system(size: 22, weight: .bold))
                                
                                Text("总数")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // 图例
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(getSortedData(), id: \.0) { status, count in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(colorForStatus(status))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(status)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text("\(count)株")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if let percentage = calculatePercentage(count, total: totalCount) {
                                        Text("(\(percentage)%)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.vertical, 5)
                    
                    // 健康状态横条图
                    VStack(spacing: 12) {
                        ForEach(getSortedData(), id: \.0) { status, count in
                            HStack {
                                Text(status)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, alignment: .leading)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 8)
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        colorForStatus(status),
                                                        colorForStatus(status).opacity(0.7)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: getBarWidth(count: count, total: totalCount, width: geometry.size.width), height: 8)
                                    }
                                }
                                
                                Text("\(count)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(colorForStatus(status))
                                    .frame(width: 25, alignment: .trailing)
                            }
                            .frame(height: 20)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
    
    private func getSortedData() -> [(String, Int)] {
        return distribution.sorted { (first, second) -> Bool in
            // 按状态优先级排序
            let order: [String] = ["良好", "一般", "叶黄", "萎蔫", "未知"]
            guard let firstIndex = order.firstIndex(of: first.key),
                  let secondIndex = order.firstIndex(of: second.key) else {
                return first.key < second.key
            }
            return firstIndex < secondIndex
        }
    }
    
    private func calculatePercentage(_ count: Int, total: Int) -> Int? {
        guard total > 0 else { return nil }
        return Int(Double(count) / Double(total) * 100)
    }
    
    private func getBarWidth(count: Int, total: Int, width: CGFloat) -> CGFloat {
        guard total > 0 else { return 0 }
        return width * CGFloat(count) / CGFloat(total)
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "良好": return AppColors.primaryGreen
        case "一般": return AppColors.fertilizerYellow
        case "叶黄": return AppColors.pruneOrange
        case "萎蔫": return .red
        default: return .gray
        }
    }
}

struct HealthPieChart: View {
    let distribution: [String: Int]
    
    private var totalCount: Int {
        distribution.values.reduce(0, +)
    }
    
    private var slices: [PieSlice] {
        let sortedItems = distribution.sorted { (first, second) -> Bool in
            let order: [String] = ["良好", "一般", "叶黄", "萎蔫", "未知"]
            guard let firstIndex = order.firstIndex(of: first.key),
                  let secondIndex = order.firstIndex(of: second.key) else {
                return first.key < second.key
            }
            return firstIndex < secondIndex
        }
        
        var slices: [PieSlice] = []
        var startAngle: Double = 0
        
        for (status, count) in sortedItems {
            let fraction = Double(count) / Double(totalCount)
            let angleDegrees = fraction * 360
            
            let slice = PieSlice(
                startAngle: .degrees(startAngle),
                endAngle: .degrees(startAngle + angleDegrees),
                color: colorForStatus(status)
            )
            
            slices.append(slice)
            startAngle += angleDegrees
        }
        
        return slices
    }
    
    var body: some View {
        ZStack {
            ForEach(slices.indices, id: \.self) { index in
                PieSliceShape(startAngle: slices[index].startAngle, endAngle: slices[index].endAngle)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [slices[index].color, slices[index].color.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // 中心白色圆
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 50, height: 50)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .frame(width: 120, height: 120)
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "良好": return AppColors.primaryGreen
        case "一般": return AppColors.fertilizerYellow
        case "叶黄": return AppColors.pruneOrange
        case "萎蔫": return .red
        default: return .gray
        }
    }
}

struct PieSlice: Identifiable {
    var id = UUID()
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
}

struct PieSliceShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        
        return path
    }
} 