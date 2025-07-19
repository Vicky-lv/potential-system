import SwiftUI

struct AppColors {
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.systemBackground)
    static let primaryGreen = Color(red: 0.1, green: 0.7, blue: 0.3)
    static let secondaryGreen = Color(red: 0.1, green: 0.6, blue: 0.3)
    static let waterBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    static let fertilizerYellow = Color(red: 0.9, green: 0.8, blue: 0.2)
    static let pruneOrange = Color(red: 0.9, green: 0.5, blue: 0.2)
    static let soilBrown = Color(red: 0.6, green: 0.4, blue: 0.2)
    static let cleanPurple = Color(red: 0.6, green: 0.3, blue: 0.9)
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ButtonStyle: ViewModifier {
    var color: Color = AppColors.primaryGreen
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

struct GlassmorphicCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.9))
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                            .blur(radius: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
    
    func customButtonStyle(color: Color = AppColors.primaryGreen) -> some View {
        self.modifier(ButtonStyle(color: color))
    }
    
    func glassmorphic() -> some View {
        self.modifier(GlassmorphicCard())
    }
} 