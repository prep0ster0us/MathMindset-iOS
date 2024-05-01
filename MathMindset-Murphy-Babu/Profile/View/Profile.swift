import SwiftUI
import Firebase

struct Profile: View {

    @State private var username = "Guest User"
    @State private var joinDate = ""
    @State private var userStats : [String: Any] = [:]
    @State private var badges : [String: Any] = [:]
    @State private var profileData: [String: Any] = [:]
    //
    let screenWidth = UIScreen.main.bounds.width
    
    @State private var isLoading = true
    @State private var isSignedOut = false
    @State private var isShowingLogoutConfirmation = false
    @State private var hasTimeElapsed = false
    
    
    @StateObject var googleAuthManager = GoogleSignInModel()
    @StateObject var firebaseManager = FirebaseManager()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // TODO: consult with Alex if it looks better with background
//            LinearGradient(gradient: .init(colors: [Color(.systemTeal), Color(.systemCyan), Color(.systemBlue)])
//                           , startPoint: .top, endPoint: .bottom)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ShapeProgressView()
            } else {
                content
            }
        }
//        if Auth.auth().currentUser == nil {
//            SignInView()
//        } else {
//            content
//        }
            .onAppear {
                fetchUserProfile()
            }
    }
    
    var content: some View {
        VStack {
            ZStack (alignment: .top) {
                HStack {
                    NavigationLink(destination: EditProfileView(profileData: profileData)) { Image("EditProfile")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .padding(.leading, 16)
                    }
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image("Settings")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .padding(.trailing, 16)
                    }
                }
                
                // User's Profile Image
                AsyncImage(url: URL(string: profileData["pfpImageUrl"] as! String)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: screenWidth-250, height: screenWidth-250)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .overlay(
                    Circle()
                        .stroke(.iconTint, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                )
                .padding(.top, 12)
            }
            
            
            // Profile Section
           
            Text(username)
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(.textTint)
            
            HStack (spacing: 12) {
                Image(systemName: "clock.fill")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(.textTint).opacity(colorScheme == .dark ? 0.8 : 0.4)
                    .padding(.trailing, -4)
                Text(joinDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.textTint).opacity(colorScheme == .dark ? 0.8 : 0.4)
                    .opacity(joinDate.isEmpty ? 0 : 1)
            }
            .padding(.top, -12)
            
            // Statistics Section
            VStack (alignment: .leading) {
                Text("Statistics")
                    .font(.title)
                    .foregroundStyle(.textTint)
                    .fontWeight(.heavy)
                    .padding(.leading, 16)
                VStack {
                    HStack (spacing: 12) {
                        StatsCard(icon: "streakActive",
                                  stat: "\(userStats["streak"] ?? "-")",
                                  description: "days streak")
                        StatsCard(icon: "primes",
                                  stat: "\(userStats["score"] ?? "-")",
                                  description: "primes earned")
                    }.padding(.horizontal, 16)
                    HStack (spacing: 12) {
                        StatsCard(icon: "potdSolved",
                                  stat: "\(userStats["potdCount"] ?? "-")",
                                  description: "daily solves")
                        StatsCard(icon: "problemSolved",
                                  stat: "\(userStats["problemCount"] ?? "-")",
                                  description: "problems solved")
                    }.padding(.horizontal, 16)
                }
            }.padding(.top, 12)
            
            // Badges Section
            VStack (alignment: .leading) {
                HStack {
                    Text("Badges")
                        .font(.title)
                        .foregroundStyle(.textTint)
                        .fontWeight(.heavy)
                        .padding(.leading, 16)
                    Spacer()
                }
                HStack (spacing: 12) {
                    ForEach(Array(badges.keys), id: \.self) { badge in
                        BadgeCard(topic: badge,
                                  isActive: (badges[badge] as!Int == 10) ? true : false
                        )
                    }
                }.padding(.leading, 16)
            }.padding(.top, 16)
            
            Spacer()
            NavigationLink(destination: SignInView(), isActive: $isSignedOut) {
                Button(action: {
                    isShowingLogoutConfirmation.toggle()
                }, label: {
                    HStack {
                        Image("logoutIcon")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 20)
                        Spacer()
                        Text("Log Out")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.red)
                            .offset(x: -10)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                            .fill(.bgTint)
                    )
                }).overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.bgContrast, lineWidth: 3)
                        .shadow(color: .bgContrast, radius: 16, x: 6, y: 4)
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .sheet(isPresented: $isShowingLogoutConfirmation) {
                logoutConfirmation
                    .presentationDetents([.fraction(0.2), .medium]) // handles the size of the bottom sheet
            }
        }
    }
    
    var logoutConfirmation: some View {
        VStack {
            Text("Are you sure you want to sign out?")
                .font(.headline)
                .fontWeight(.heavy)
                .padding(.top, 16)
            HStack {
                Button("Cancel") {
                    isShowingLogoutConfirmation.toggle()
                }.buttonStyle(BorderedButtonStyle())
                Spacer()
                Button("Logout") {
//                    Task { delayLogout() }
                    isShowingLogoutConfirmation.toggle()
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                    googleAuthManager.isSignedIn = false
                    firebaseManager.isSignedIn = false
                    isSignedOut.toggle()
                }.buttonStyle(BorderedProminentButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }
    
    private func delayLogout() async {
        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        hasTimeElapsed = true
    }
    
    func fetchUserProfile() {
        let currentUser = Auth.auth().currentUser!
        let db = Firestore.firestore()
        let ref = db.collection("Users").document(currentUser.uid)
        
        ref.getDocument(as: UserData.self) { result in
            switch result {
            case .success(let document):
                let dateJoined = document.account_creation_date as Date
                joinDate = "Joined \(dateFormatter(dateJoined))"
                username = document.username
                userStats = [
                    "streak"    : document.streak,
                    "score"     : document.score,
                    "potdCount" : document.POTD_count
                ]
                badges = document.progress
                var problemCount = 0
                for count in badges.values {
                    problemCount += count as! Int
                }
                userStats["problemCount"] = problemCount
                
                profileData = [
                    "pfpImageUrl" : document.profileImage,
                    "username"    : document.username,
                    "email"       : document.email,
                    "dateOfBirth" : document.dateOfBirth
                ]
                
                isLoading = false
                
            case .failure(let error):
                print("Error fetching document: \(error)")
            }
        }
    }
    
    func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
        
    }
}

#Preview {
    Profile()
}
