import SwiftUI
import Firebase

struct HomeView: View {
    @EnvironmentObject private var app: AppVariables
    
    // For Problem of the day Button
    @State private var potdActive : Bool = true
    // timer afer solving Problem of the Day
    @State private var countDown = TimeInterval()
    @State private var timerRunning = true
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // fetch user-stats
    @State var topicProgress: [String: Any?] = [:]
    @State var userStreak   : Int = 0
    @State var userScore    : Int = 0
    @State var quizScores   : [String: Any?] = [:]
    
    // show loading screenl, while data is being fetched from database
    @State private var isLoading = true
    
    var body: some View {
        Group {
            ZStack {
                LinearGradient(gradient: .init(colors: [Color(.systemTeal), Color(.systemCyan), Color(.systemBlue)])
                               , startPoint: .top, endPoint: .bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)
                
                if(isLoading) {
                    ShapeProgressView()
                } else {
                    content
                }
            }
        }.onAppear {
            Task {
                await fetchUserProgress()
            }
        }
    }
    
    var content: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .center) {
                    Image(userStreak>0 ? "streakActive" : "streakInactive")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("\(userStreak)")
                        .font(.system(size: 20, weight: .heavy))
                    Spacer()
                    Text("\(userScore)")
                        .font(.system(size: 20, weight: .heavy))
                    Image(userScore>0 ? "primes" : "primesEmpty")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                .background(.clear)
                
                ScrollView {
                    ZStack {
                        VStack {
                            HStack (alignment: .top) {
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(.black.opacity(0.5))
                                Spacer()
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(.black.opacity(0.5))
                            }.padding(.horizontal, 70)
                            Spacer().frame(height: 228)
                            HStack (alignment: .top){
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(.black.opacity(0.5))
                                Spacer()
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(.black.opacity(0.5))
                            }.padding(.horizontal, 70)
                        }
                        VStack {
                            Text("Problem of the Day")
                            // TODO: Find our own smallcaps font
                                .font(.title.smallCaps())
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.black))
                                .underline()
                                .padding(.bottom, 12)
                            Image(potdActive ? "potdActive" : "potdInactive")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80)
                            // TODO: can still navigate to potd page; even when timer shows
                            NavigationLink(destination: ProblemOfDay($potdActive).environmentObject(app)
                            ) {
                                Button(action: {}, label: {
                                    Text(potdActive ? "Solve" : formattedTime())     // difference available in seconds, format tthe value in HH:MM:SS
                                        .font(.title)
                                        .onReceive(timer) { _ in
                                            if countDown > 0  && timerRunning {
                                                countDown -= 1
                                            } else {
                                                print("Shouldn't have made it here?")
                                                // by updating a state variable when the timer runs out, we can update the button to be active (so the problem of the day is made available)
                                                timerRunning = false
                                                timer.upstream.connect().cancel()     // relinquish thread process
                                                potdActive = true
                                            }
                                        }
//                                        }.onAppear {
//                                            if (potdRefreshTimestamp().timeIntervalSince(.now) > 0) {
//                                                // made it here too!
//                                                timerRunning = true
//                                                potdActive = false
//                                                countDown = potdRefreshTimestamp().timeIntervalSince(.now)
////                                                timer.upstream.connect() // TODO: Needed?
//                                            }
//                                        }
                                        .font(.title2)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill((potdActive) ? Color(red: 0, green: 0.8, blue: 1) : Color(red: 0.7, green: 0.7, blue: 0.7))
                                                .strokeBorder(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                                                .shadow(radius: 5)
                                                .frame(width: 175, height: 50)
                                        )
                                        .foregroundColor(.black)
                                        .padding(.top, 12)
                                }).disabled(potdActive)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.85, green: 0.95, blue: 1))
                            .shadow(radius: 10, x: 8, y: 8)
                            .frame(width: 285, height: 280)
                    )
                    .offset(y: 8)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                    
                        VStack(alignment: .leading) {
                            ForEach(Array(ProblemSets.keys), id: \.self) { topic in
                                NavigationLink(destination:
                                                ProblemsView(
                                                    topic: topic,
                                                    problemSet: ProblemSets[topic]!,
                                                    problemNum: CGFloat(topicProgress[topic] as! Int)
                                                )
                                ) {
                                    TopicCard(name: topic,
                                              image: topic,
                                              completed: $topicProgress,
                                              quizScores: $quizScores)
                                        .frame(width: $app.screenWidth.wrappedValue)
//                                        .onDisappear {
//                                            isLoading = true
//                                        }
                                }
                            }.padding(.top, 10)
                        }
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                }
                .padding(.bottom, 100)
            }.ignoresSafeArea(.all)
        }.navigationBarBackButtonHidden(true)
    }
    
    func fetchUserProgress() async {
        db.collection("Users")
            .document(Auth.auth().currentUser!.uid)
            .getDocument(as: UserData.self) { result in
                switch result {
                case .success(let document):
                    topicProgress = document.progress as [String: Int]
                    userScore     = document.score
                    userStreak    = document.streak
                    quizScores    = document.quiz_scores
                    
                    // check if problem of the day has been solved already
                    // last POTD solve is less than the POTD refresh timestamp (presently using 9AM everyday)
                    print("Last timestamp: " + potdLastRefresh().description)
                    print("User timestamp: " + document.potd_timestamp.description)
                    print("Comparison: " + String(document.potd_timestamp > potdLastRefresh()))
                    print("New timestamp: " + potdRefreshTimestamp().description)
                    print("Comparison to new: " + String(document.potd_timestamp < potdRefreshTimestamp()))
                    if (document.potd_timestamp > potdLastRefresh() && document.potd_timestamp < Date()) {
                        // User is returning from having solved the POTD less than 24hrs ago
                        // and has not reset yet
                        timerRunning = true
                        potdActive = false
                        countDown = potdRefreshTimestamp().timeIntervalSince(.now)
                        print("countdown 1: " + countDown.debugDescription)
                        var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                    } else if (document.potd_timestamp <= potdLastRefresh()) {
                        // This block of code is only needed if you manually change things in firebase
                        potdActive = true
                        timerRunning = false
                    } else if (potdRefreshTimestamp().timeIntervalSince(.now) > 0) {
                        // User has just finished the problem
                        timerRunning = true
                        potdActive = false
                        countDown = potdRefreshTimestamp().timeIntervalSince(.now)
                        print("countdown2:" + countDown.debugDescription)
                        var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                    } else {
                        potdActive = true
                    }
                    // fetch all problem sets
                    fetchProblemSets()
                    
                case .failure(let error):
                    print("Error fetching document: \(error)")
                }
            }
    }
    
    func fetchProblemSets() {
        // sticking to same order as in firebase
//        // sort topics by alphabetical order
//        let sortedTopics = topicProgress.sorted { ($0.value as! Int) < ($1.value as! Int) }
//        // can't sort dict directly, so convert to sorted array and then put back into the dict
//        for (key, value) in sortedTopics {
//            topicProgress[key] = value
//        }
        var count = 0
        for topic in topicProgress.keys {
            db.collection("Problems")
                .document(topic)
                .getDocument(as: ProblemSetData.self) { result in
                    count+=1
                    switch result {
                    case .success(let document):
                        ProblemSets[topic] = document
                        
                    case .failure(let error):
                        print("Error fetching document: \(error)")
                    }
                    
                    if count == topicProgress.count {
                        // set flag to indicate all necessary data has been loaded in
                        withAnimation(Animation.easeInOut) {
                            isLoading = false
                        }
                    }
                }
        }
    }
    
    func potdLastRefresh() -> Date {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone.current
//        print("Hour component: " + String(calendar.component(.hour, from: .now)))
        // We want to subtract 1 whenever the time of day hasn't passed the notifHour (or notifTime)
        // Line below uses current time zone
        // Crudely add 4 to account for UTC
        let currHour = calendar.component(.hour, from: .now) // THIS USES LOCAL TIMEZONE i.e. "6pm EST" -> 18
        var refreshDay = currHour < (notifHour) ? -1 : 0
        // Have to check minute if we're past that too, specifically for those who
        // immediately solve the POTD
        let currMinute = calendar.component(.minute, from: .now)
        if (refreshDay == 0 && currHour == (notifHour)) {
            refreshDay = currMinute < notifMinute ? -1 : 0
        }
        // Also check seconds for those who solve the POTD really fast
        let currSeconds = calendar.component(.second, from: .now)
        if (refreshDay == 0 && currMinute == notifMinute) {
            // 2-second buffer for UI to catch up.
            // Meaning if the user solves the POTD in under 2 seconds then the
            // timer could bug out
            refreshDay = currSeconds < 2 ? -1 : 0
        }
        var components = DateComponents(year: calendar.component(.year, from: .now),
                                        month: calendar.component(.month, from: .now),
                                        day: calendar.component(.day, from: .now)+refreshDay,  // current day
                                        // Do not subtract for UTC, rolls over to next day if difference
                                        // is larger than 20
                                        hour: notifHour,
                                        minute: notifMinute,
                                        second: 0)
//        print("Date old: " + calendar.date(from: components)!.description)
        return calendar.date(from: components)!
    }
    
    func potdRefreshTimestamp() -> Date {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone.current
//        print("Hour component: " + String(calendar.component(.hour, from: .now)))
        // want 0 when it's the following day
        // Line below uses current time zone
        // Crudely add 4 to account for UTC
        let currHour = calendar.component(.hour, from: .now) // THIS USES LOCAL TIMEZONE i.e. "6pm EST" -> 18
        var refreshDay = currHour < (notifHour) ? 0 : 1
        // Have to check minute if we're past that too, specifically for those who
        // immediately solve the POTD
        let currMinute = calendar.component(.minute, from: .now)
        if (refreshDay == 0 && currHour == (notifHour)) {
            refreshDay = currMinute < notifMinute ? 0 : 1
        }
        // Also check seconds for those who solve the POTD really fast
        let currSeconds = calendar.component(.second, from: .now)
        if (refreshDay == 0 && currMinute == notifMinute) {
            // 2-second buffer for UI to catch up.
            // Meaning if the user solves the POTD in under 2 seconds then the
            // timer could bug out
            refreshDay = currSeconds < 2 ? 0 : 1
        }
        
        let components = DateComponents(year: calendar.component(.year, from: .now),
                                        month: calendar.component(.month, from: .now),
                                        day: calendar.component(.day, from: .now)+refreshDay,  // current day
                                        // Do not subtract for UTC, rolls over to next day if larger than 20
                                        hour: notifHour, // 24 hour format
                                        minute: notifMinute,
                                        second: 0)
//        print("Date new: " + calendar.date(from: components)!.description)
        return calendar.date(from: components)!
    }
    
    func formattedTime() -> String {
        let seconds = Int(countDown)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
    
}

#Preview {
    HomeView()
        .environmentObject(AppVariables())
}
