import SwiftUI

struct OnboardingView: View {
    
    @State private var activeTab: Int = 0       // for tab view
    @State private var slideTitle: String = "Numbers are fun!"
    
    private var dotAppearance = UIPageControl.appearance()
    
    var body: some View {
        if !UserDefaults.standard.bool(forKey: "firstRun") {
            content
        } else {
            SignInView()
        }
        //        SignInView()
    }
    
    var content: some View {
        NavigationStack {
            VStack {
                HStack {
                    if activeTab == 0 {
                        Text("Hello Solvers!")
                            .font(.title)
                            .fontWeight(.medium)
                            .kerning(1.2)       // character spacing
                    }
                    Spacer()
                    NavigationLink (destination: SignInView().navigationBarBackButtonHidden(true)) {
                        Text(activeTab == 2 ? "Get Started" : "Skip")
                            .fontWeight(.bold)
                            .kerning(1.3)
                    }.simultaneousGesture(TapGesture().onEnded {
                        UserDefaults.standard.set(true, forKey: "firstRun")
                    })
                }.padding()
                    .foregroundStyle(Color.black)
                    .frame(height: 40)
                
                Text(slideTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .kerning(1.2)
                    .padding(.top, 36)
                
                TabView(selection: $activeTab) {
                    Image("onboarding1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(0)
                    Image("onboarding2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(1)
                    Image("onboarding3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(2)
                }.tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                    .onAppear {
                        dotAppearance.currentPageIndicatorTintColor = .black
                        dotAppearance.pageIndicatorTintColor = .gray
                    }
                    .onChange(of: activeTab) {
                        switch(activeTab) {
                        case 0: slideTitle = "Numbers are fun!"
                        case 1: slideTitle = "Practice Problems"
                        case 2: slideTitle = "Compete on Leaderboards"
                        default: slideTitle = "Impact that math-ers"
                        }
                    }
            }
        }
    }
}

#Preview {
    OnboardingView()
}

