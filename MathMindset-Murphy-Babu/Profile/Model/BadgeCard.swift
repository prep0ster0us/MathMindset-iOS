import SwiftUI

struct BadgeCard: View {
    let topic    : String
    let isActive : Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack {
                Image("\(topic)Badge")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .saturation(isActive ? 1 : 0)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark
                                    ? (isActive ? .bgContrast : .borderTint.opacity(0.7))
                                    : .bgContrast.opacity(isActive ? 1 : 0.3)
                                    , lineWidth: 2)
                    )
            }
            .shadow(radius: 16, x: 12, y: 12)
            .contextMenu(menuItems: {
                Text("\(topic) 101 Badge")
                    .fontWeight(.bold)
                    .foregroundStyle(.textTint)
                
            })
                
            Image("badgeSparkle")
                .resizable()
                .frame(width: 20, height: 20)
                .offset(x: 17, y: -25)
                .opacity(isActive ? 1 : 0)
        }
    }
}

#Preview {
    BadgeCard(topic: "Factoring", isActive: true)
}
