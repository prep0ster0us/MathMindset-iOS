import SwiftUI
import Firebase

struct Leaderboards: View {
    let screenWidth = UIScreen.main.bounds.width
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    @State private var index = 0
    @State private var isLoading = false // TODO: change for implementation
    @State private var users = [TopUser]()
    @State private var currentUser = TopUser()
    
    var body: some View {
        Group {
            if isLoading {
                ShapeProgressView()
            } else {
                ZStack {
                    LinearGradient(gradient: .init(colors: [Color(.systemTeal), Color(.systemCyan), Color(.systemBlue)])
                                   , startPoint: .top, endPoint: .bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ZStack (alignment: .top) {
                            leaderboardList
                            //.frame(width: screenWidth - 50, height: UIScreen.main.bounds.height - 150)
                            tabSwitch
                                .background(Color(.black).opacity(0.1))
                                .clipShape(Capsule())
                                .offset(y: -12)
                        }.padding(.top, 24)
                        Spacer()
                        // show current user's card
                        if auth.currentUser != nil {
                            UserCard(
                                currentUser.username,
                                currentUser.profileImage,
                                self.index == 0 ? CGFloat(currentUser.score) : CGFloat(currentUser.streak),
                                self.index == 0 ? "primes" : "days",
                                -1
                            ).padding(4)
                                .padding(.vertical, 12)
                        }
                    }
                }
            }
        }.onAppear {
            fetchTopUsers()
            getCurrentUser()
        }
    }
    
    var tabSwitch: some View {
        HStack (spacing: 0) {
            Button(action: {
                withAnimation(Animation.smooth()) {
                    self.index = 0
                }
                self.users.sort { index == 0
                    ? ($0.score > $1.score)
                    : ($0.streak > $1.streak)
                }
            }, label: {
                Text("Score")
                    .foregroundStyle(self.index == 0 ? Color(.textTint) : Color(.textContrast))
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                    .frame(width: (screenWidth-40)/2)
                
            }).background(self.index == 0 ? Color.bgTint : Color.bgContrast)
                .clipShape(Capsule())
//                        .overlay(Capsule().stroke(self.index == 0 ? .black : .clear, lineWidth: 2))
                
            Button(action: {
                withAnimation(Animation.linear(duration: 0.2)) {
                    self.index = 1
                }
                self.users.sort { index == 0
                    ? ($0.score > $1.score)
                    : ($0.streak > $1.streak)
                }
            }, label: {
                Text("Streak")
                    .foregroundStyle(self.index == 1 ? Color(.textTint) : Color(.textContrast).opacity(0.8))
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                    .frame(width: (screenWidth-40)/2)
                
            }).background(self.index == 1 ? Color.bgTint : Color.bgContrast)
                .clipShape(Capsule())
//                        .overlay(Capsule().stroke(self.index == 1 ? .black : .clear, lineWidth: 2))
        }.padding(2)
            .background(Color(.bgContrast))
    }
    
    var leaderboardList: some View {
        ScrollView {
            VStack (spacing: 0) {
                ForEach(self.users, id: \.self) { user in
                    let standing = self.users.firstIndex(of: user)!
                    UserCard(
                        user.username,
                        user.profileImage,
                        index == 0 ? CGFloat(user.score) : CGFloat(user.streak),
                        index == 0 ? "primes" : "days",
                        standing
                    )
                    .padding(4)
                    .padding(.top, standing == 0 ? 36 : 0)
                    .padding(.bottom, standing == self.users.count-1 ? 36 : 0)
                }
                .onAppear {
                    print(users)
                    self.users.sort { index == 0
                        ? ($0.score > $1.score)
                        : ($0.streak > $1.streak)
                    }
                }
            }
        }.background(
            RoundedRectangle(cornerRadius: 16)
                .shadow(radius: 16, x: 8, y: 12)
                .foregroundStyle(.bgTint)
        )
        .padding()
    }
    
    func fetchTopUsers() {
        var standing = 0
        
        let ref = db.collection("Leaderboard")
        ref.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting leaderboard users: \(error.localizedDescription)")
                } else {
                    // fetch all users from Leaderboard
                    // let documentIDs = querySnapshot?.documents.map { $0.documentID } ?? []
                    
                    self.users = querySnapshot?.documents.compactMap { document -> TopUser? in
                        let data = document.data()
//                        print(data)
                        guard let username = data["username"] as? String,
                              let profileImage = data["profileImage"] as? String,
                              let streak = data["streak"] as? Int,
                              let score = data["score"] as? Int else {
                            return nil
                        }
                        standing += 1
                        return TopUser(
                            username    : username,
                            profileImage : profileImage,
                            streak      : streak,
                            score       : score
                        )
                    } ?? []
//                    print(self.users.count)
//                    print(self.users)
                }
            }
    }
    
    func getCurrentUser() {
        
        let user = auth.currentUser!
        let ref = db.collection("Users")
        ref.document(user.uid)
            .getDocument(as: TopUser.self) { result in
                switch result {
                case .success(let user):
                    currentUser = user
                    
                case .failure(let error):
                    print("Error fetching current user: \(error.localizedDescription)")
                }
            }
        //        let user = auth.currentUser!
        //        let ref = db.collection("Users")
        //        ref.document(user.uid)
        //            .getDocument { (document, error) in
        //                if let document = document, document.exists {
        //                    let data: [String: Any] = document.data() ?? [:]
        //                    guard let username = data["username"] as? String,
        //                          let profileImage = data["profileImage"] as? String,
        //                          let streak = data["streak"] as? Int,
        //                          let score = data["score"] as? Int else {
        //                        return
        //                    }
        //                    currentUser = TopUser(
        //                        username: username,
        //                        profileImage: profileImage,
        //                        streak: streak,
        //                        score: score
        //                    )
        //                    print(currentUser)
        //                } else {
        //                    print("User does not exist")
        //                }
        //            }
    }
}

// reference for creating custom shape animation, for use as progress view
// https://blog.stackademic.com/custom-progressview-in-swiftui-c94f51ba598b
struct ShapeProgressView: View {
    
    let width: CGFloat = 45
    let height: CGFloat = 45
    let animDuration: CGFloat = 1.8
    let delay: CGFloat = 0.3
    @State private var animEnd: CGFloat = 0.0
    
    var body: some View {
        VStack {
            HStack (spacing: 25) {
                loadTriangle
                loadRectangle
                loadCircle
            }.padding(.bottom, 25)
            loadUnderline
            // TODO: finalize with Alex
//            HStack (spacing: 0) {
//                ShimmerText("Loading", 32, 3.0)
//                AnimatedLoadingDots()
//                    .padding(.top, 18)
//                    .padding(.leading, -16)
//            }
        }
    }
    
    var loadCircle: some View {
        Circle()
            .trim(from: 0.0, to: animEnd)
            .stroke(.iconTint, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: width, height: height)
            .rotationEffect(.degrees(-90))
            .opacity(animEnd)
            .animation(
                Animation.easeInOut(duration: animDuration)
                    .repeatForever(autoreverses: true).delay(delay)
                , value: animEnd
            )
            .onAppear {
                self.animEnd = 1.0
            }
    }
    
    var loadRectangle: some View {
        Rectangle()
            .trim(from: 0.0, to: animEnd)
            .stroke(.iconTint, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: width, height: height)
            .opacity(animEnd)
            .animation(
                Animation.easeInOut(duration: animDuration)
                    .repeatForever(autoreverses: true).delay(delay)
                , value: animEnd
            )
            .onAppear {
                self.animEnd = 1.0
            }
    }
    
    var loadTriangle: some View {
        Triangle()
            .trim(from: 0.0, to: animEnd)
            .stroke(.iconTint, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: width, height: height)
            .opacity(animEnd)
            .animation(
                Animation.easeInOut(duration: animDuration)
                    .repeatForever(autoreverses: true).delay(delay)
                , value: animEnd
            )
            .onAppear {
                self.animEnd = 1.0
            }
    }
    
    var loadUnderline: some View {
        HStack (spacing: 2) {
            Rectangle()
                .trim(from: 0.0, to: animEnd)
                .stroke(.iconTint, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .frame(width: width*2.2, height: 0.5)
                .opacity(animEnd)
                .animation(
                    Animation.easeInOut(duration: animDuration)
                        .repeatForever(autoreverses: true).delay(delay)
                    , value: animEnd
                )
                .onAppear {
                    self.animEnd = 1.0
                }
            Rectangle()
                .trim(from: 0.0, to: animEnd)
                .stroke(.iconTint, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .frame(width: width*2.2, height: 0.5)
                .opacity(animEnd)
                .rotationEffect(.degrees(180))
                .animation(
                    Animation.easeInOut(duration: animDuration)
                        .repeatForever(autoreverses: true).delay(delay)
                    , value: animEnd
                )
                .onAppear {
                    self.animEnd = 1.0
                }
        }
    }

}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Tutorial reference for shimmer effect on text view
// https://www.youtube.com/watch?v=KYokxl1inRs
struct ShimmerText: View {
    
    let displayText: String
    let fontSize: CGFloat
    let animDuration: CGFloat
    init(
        _ displayText: String = "",
        _ fontSize: CGFloat = 14,
        _ animDuration: CGFloat = 2.0
    ){
        self.displayText = displayText
        self.fontSize = fontSize
        self.animDuration = animDuration
    }
    
    @State private var animate: Bool = false
    
    var body: some View {
        ZStack {
            Text(displayText)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundStyle(Color.textTint)
            
            HStack(spacing: 0) {
                ForEach(0..<displayText.count, id: \.self) { index in
                    Text(String(displayText[displayText.index(displayText.startIndex, offsetBy: index)]))
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundStyle(.teal)
                }
            }.mask(
                Rectangle()
                    .rotationEffect(.degrees(75))
                    .offset(x: -100)
                    .offset(x: animate ? 300 : 0)
                    .onAppear(perform: {
                        withAnimation(Animation.linear(duration: animDuration)
                            .repeatForever(autoreverses: false)) {
                                self.animate.toggle()
                            }
                    })
            )
        }
    }
}

struct DotView: View {
//    @State var delay: Double
//    @State var scale: CGFloat = 0.5
    @State var dots = "."
    
    var body: some View {
        // bounce scaling dots /* test */
//        Text(".")
//            .frame(width: 24, height: 24)
//            .scaleEffect(scale)
//            .onAppear {
//                withAnimation(Animation.easeInOut(duration: 0.6).repeatForever().delay(delay)) {
//                    self.scale = 1
//                }
//            }.padding(-16)
//            .padding(.top, 16)
        Text(dots)
            .frame(width: 24, height: 24)
            .onAppear {
                withAnimation(Animation.linear(duration: 0.1).delay(1.0).repeatForever()) {
                    dots = String(repeating: ".", count: (dots.count+1)%5)
                }
            }
    }
}

struct AnimatedLoadingDots: View {
    @State var animRight = false
    @State var animLeft = false
    @State var animDuration = 0.8
    @State var width: CGFloat = 6
    @State var height: CGFloat = 16
    @State var offset: CGFloat = 20
    
    var body: some View {
        
        ZStack {
            
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 4){
                    Circle()
                        .fill(Color.textTint)
                        .scaleEffect( animLeft ? 1: 0.8)
                        .offset(x: offset)
                        .onAppear() {
                            withAnimation(Animation.linear(duration: animDuration)
                                .repeatForever()
                                .delay(1.0)) {
                                    self.animLeft.toggle()
                                }
                        }
                    Circle()
                        .fill(Color.textTint)
                        .scaleEffect( animLeft ? 1: 0.8)
                        .offset(x: offset)
                        .onAppear {
                            withAnimation(Animation.linear(duration: animDuration)
                                .repeatForever()
                                .delay(0.0)) {
                                    self.animRight.toggle()
                                }
                        }

                    Circle()
                        .fill(Color.textTint)
                        .scaleEffect( animRight ? 1: 0.8)
                        .offset(x: offset)
                        .onAppear {
                            withAnimation(Animation.linear(duration: animDuration).repeatForever()
                                .delay(0.5)) {
                                    self.animRight.toggle()
                                }
                        }
                }.frame(height: height)
            }.frame(width: width*5, height: height)
        }
    }
}

#Preview {
    Leaderboards()
//    idktest()
//    ShapeProgressView()
}
