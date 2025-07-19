import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var color: Color = .green
    var lineWidth: CGFloat = 14
    var size: CGFloat = 120
    
    @State private var animateProgress = false
    
    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // 进度圆环
            Circle()
                .trim(from: 0, to: animateProgress ? max(0, min(1, progress)) : 0)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.8), color]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.5), radius: 3, x: 0, y: 1)
            
            // 中心文字
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("健康度")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 光影效果
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 1)
                .scaleEffect(1.1)
                .blur(radius: 8)
                .opacity(progress > 0.3 ? progress : 0)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animateProgress = true
            }
        }
        .accessibilityLabel("健康状态进度")
        .accessibilityValue("\(Int(progress * 100))%")
    }
} 