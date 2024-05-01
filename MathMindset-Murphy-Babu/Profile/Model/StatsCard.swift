import SwiftUI

struct StatsCard: View {
    let icon : String
    let stat : String
    let description : String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .frame(width: 20, height: 20)
                .padding(.leading, 12)
                .padding(.trailing, 8)
            
            VStack (alignment: .leading, spacing: 0) {
                Text(stat)
                        .font(.system(size: 20, weight: .heavy))
                    .fontWeight(.heavy)
                    .foregroundStyle(.textTint)
                Text(description)
                        .font(.system(size: 14, weight: .medium))
                    .fontWeight(.light)
                    .foregroundStyle(.textTint).opacity(colorScheme == .dark ? 0.9 : 0.4)
            }.padding(.vertical, 12)
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.borderTint, lineWidth: 1.5)
        )
    }
}

#Preview {
    StatsCard(icon: "streakActive", stat: "5", description: "days streak")
}
