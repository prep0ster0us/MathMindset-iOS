import SwiftUI

// followed youtube tutorial by Indently
// https://www.youtube.com/watch?v=0ytO3wCRKZU
// SplashScreen for iOS in SwiftUI Tutorial 2022 (Xcode)

struct SplashScreenView: View {
    
    @State private var isActive = false
    @State private var opacity = 0.5
    @State private var size = 0.8
    
    var body: some View {
        if isActive {
            OnboardingView()
        } else {
            content
        }
    }
    
    var content: some View {
        VStack {
            VStack {
                // Logo Image
                Image("appLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 125, height: 125)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 4))
                    .shadow(radius: 25, x: 24, y: 24)
                    .padding(.bottom, 24)
                // Header
                StrokeText(text: "MathMindset", width: 0.5, color: Color(.textTint))
            }.background(Color.bgTint)
            .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(Animation.easeOut(duration: 0.8)) {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
