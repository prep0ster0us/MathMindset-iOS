import SwiftUI

struct OnboardingView: View {
    
    @State private var activeTab: Int = 0       // for tab view
    @State private var slideTitle: String = "Practice concepts"
    
    private var dotAppearance = UIPageControl.appearance()
    
    var body: some View {
//        if !UserDefaults.standard.bool(forKey: "firstRun") {
            content
//        } else {
//            SignInView()
//        }
    }
    
    var content: some View {
        NavigationStack {
            VStack {
                TabView(selection: $activeTab) {
                    onboarding1
                        .tag(0)
                    onboarding2
                        .tag(1)
                    onboarding3
                        .tag(2)
                }.tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                    .onAppear {
                        dotAppearance.currentPageIndicatorTintColor = .black
                        dotAppearance.pageIndicatorTintColor = .gray
                    }
                    .onChange(of: activeTab) {
                        switch(activeTab) {
                        case 0: slideTitle = "Practice concepts"
                        case 1: slideTitle = "Solve Problems"
                        case 2: slideTitle = "Compete on the Leaderboards"
                        default: slideTitle = "Impact that math-ers"
                        }
                    }
            }
            .background(ignoresSafeAreaEdges: .all)
            .ignoresSafeArea(.all)
        }
    }
    
    var onboarding1: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink (destination: SignInView().navigationBarBackButtonHidden(true)) {
                    Text("Skip")
                        .fontWeight(.heavy)
                        .foregroundStyle(.black)
                        .padding(.trailing, 8)
                }.simultaneousGesture(TapGesture().onEnded {
                    UserDefaults.standard.set(true, forKey: "firstRun")
                })
            }.padding()
                .frame(height: 40)
//                .padding(.bottom, 12)
            // main content
            ZStack (alignment: .top) {
                GIFLoader(gifName: "solveGIF")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .padding(.top, 24)
                    .offset(x: 12, y: 32)
                Text(slideTitle)
                    .font(.system(size: 36, weight: .heavy))
            }.padding(.bottom, 48)
            Image("onboardingSolve")
                .resizable()
                .frame(width: AppVariables().screenWidth-80, height: 350)
                .padding(.bottom, 24)
            Spacer()
        }
        .background(
            .white
        )
    }
    
    var onboarding2: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink (destination: SignInView().navigationBarBackButtonHidden(true)) {
                    Text("Skip")
                        .fontWeight(.heavy)
                        .foregroundStyle(.black)
                        .padding(.trailing, 8)
                }.simultaneousGesture(TapGesture().onEnded {
                    UserDefaults.standard.set(true, forKey: "firstRun")
                })
            }.padding()
                .frame(height: 40)
                .padding(.bottom, 12)
            // main content
            ZStack (alignment: .top) {
                GIFLoader(gifName: "practiceGIF")
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 24)
                    .offset(y: 12)
                Text(slideTitle)
                    .font(.system(size: 36, weight: .heavy))
            }
            Image("onboardingPractice")
                .resizable()
                .frame(width: AppVariables().screenWidth-80)
                .padding(.bottom, 24)
            Spacer()
        }
        .background(
            .white
        )
    }
    
    @State var animEnd: CGFloat = 0.0
    let animDuration: CGFloat = 1.8
    let delay: CGFloat = 0.3
    var onboarding3: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink (destination: SignInView().navigationBarBackButtonHidden(true)) {
                    VStack (spacing: 0) {
                        Text("Get Started")
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .trim(from: 0.0, to: animEnd)
                                .stroke(.iconTint, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                                .frame(width: 120, height: 36)
//                                .opacity(animEnd)
                                .animation(
                                    Animation.easeInOut(duration: animDuration)
                                        .repeatForever(autoreverses: true).delay(delay)
                                    , value: animEnd
                                )
                                .onAppear {
                                    self.animEnd = 1.0
                                }
                            )
                            .padding(.trailing, 10)
                    }
                }.simultaneousGesture(TapGesture().onEnded {
                    UserDefaults.standard.set(true, forKey: "firstRun")
                })
            }.padding()
                .frame(height: 40)
                .padding(.bottom, 12)
                .offset(y: 16)
            // main content
            ZStack (alignment: .top) {
                GIFLoader(gifName: "leaderboardGIF")
                    .frame(height: 285)
                    .scaleEffect(1.6)
                    .clipped()
                    .padding(.top, 38)
                    .offset(y: 32)
                Text(slideTitle)
                    .font(.system(size: 36, weight: .heavy))
                    .offset(y: 16)
            }
            Image("onboardingLeaderboard")
                .resizable()
                .frame(width: AppVariables().screenWidth-80, height: 350)
                .padding(.bottom, 24)
                .offset(y: -12)
            Spacer()
        }
        .background(
            .onboardingLeaderboardbg
        )
    }
}


#Preview {
    OnboardingView()
}

