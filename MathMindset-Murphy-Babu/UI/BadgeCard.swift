import SwiftUI

struct BadgeCard: View {
    let topic    : String
    let isActive : Bool
    
    var body: some View {
        ZStack {
            VStack {
                Image("\(topic)Badge")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .saturation(isActive ? 1 : 0)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.bgContrast.opacity(isActive ? 1 : 0.3), lineWidth: 2)
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
                .offset(x: 24, y: -24)
                .opacity(isActive ? 1 : 0)
        }
    }
}

#Preview {
    BadgeCard(topic: "Factoring", isActive: true)
}
