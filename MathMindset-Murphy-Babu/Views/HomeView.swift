import SwiftUI
import Firebase

struct HomeView: View {
    @EnvironmentObject private var app: AppVariables
    
    var titles: [String] = ["Factoring",
                            "Derivative",
                            "Trig"]
    
    // TODO: static question for now, make this dynamic by fetching from db
    let problem = Poly()
    @State var disableBtn: Bool = false
    
    // fetch user-stats
    @State var topicProgress: [String: Any?] = [:]
    @State var userStreak   : Int = 0
    @State var userScore    : Int = 0
    
    @State private var isLoading = true
    
    @State private var countDown = TimeInterval()
    @State private var timerRunning = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if(isLoading) {
//                ProgressView()
                ShapeProgressView()
            } else {
                content
            }
        }.onAppear {
            fetchProblemSet("Factoring")
            fetchProblemSet("Trig")
            fetchProblemSet("Derivative")
            fetchUserProgress()
        }
    }
    
    var content: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(userStreak>0 ? "streakActive" : "streakInactive")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("\(userStreak)")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Image(userScore>0 ? "primes" : "primesEmpty")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("\(userScore)")
                        .font(.system(size: 20, weight: .bold))
                }
                .padding()
                .padding(.top, 50)
                Text("\(String(describing: topicProgress["Trig"]))").font(.title)
                VStack {
                    Text("Problem of the Day")
                    // TODO: Find our own smallcaps font
                        .font(Font.system(.title).smallCaps())
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.textTint))
                        .underline()
                        .padding(.bottom, 12)
                    Image(app.probOfDaySolved ? "potdInactive" : "potdActive")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)
                    NavigationLink(destination: ProblemOfDay().environmentObject(app),
                                        isActive: $disableBtn
                    ) {
                        Text($app.probOfDaySolved.wrappedValue ? formattedTime() : "Solve")     // difference available in seconds, format tthe value in HH:MM:SS
                            .font(.title)
                            .onReceive(timer) { _ in
                                if countDown > 0  && timerRunning {
                                    countDown -= 1
                                } else {
                                    // by updating a state variable when the timer runs out, we can update the button to be active (so the problem of the day is made available)
                                    //                            timerRunning = false
                                    timer.upstream.connect().cancel()     // relinquish thread process
                                }
                            }.onAppear {
                                calculateTimeDifference()
                            }
                            .font(.title2)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(($app.probOfDaySolved.wrappedValue) ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0, green: 0.8, blue: 1))
                                    .strokeBorder(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                                    .shadow(radius: 5)
                                    .frame(width: 175, height: 50)
                            )
                            .foregroundColor(.black)
                            .padding(.top, 24)
                    }
                }.background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.85, green: 0.95, blue: 1))
                        .shadow(radius: 5)
                        .frame(width: 285, height: 275)
                )
                .padding(.top, 36)
                .padding(.bottom, 20)
                
                ScrollView{
                    VStack(alignment: .leading) {
                        ForEach(titles, id: \.self) { title in
                            let problemSet = title == "Factoring" ? PolySet : (title == "Trig" ? TrigSet : DerivativeSet)
                            NavigationLink(destination:
                                            ProblemView(
                                                topic: title,
                                                problemNum: topicProgress[title] as! Int+1,
                                                question: problemSet[topicProgress[title] as! Int].question,
                                                choices: problemSet[topicProgress[title] as! Int].choices,
                                                problemSet: problemSet
                                            )
                            ) {
                                TopicCard(name: title, image: title, completed: topicProgress[title] as! Int)
                                    .frame(width: $app.screenWidth.wrappedValue)
                                    .onAppear {
                                        print("title= \(title) --> \(topicProgress[title] as! Int)")
                                        print("after populating topic card: \(topicProgress)")
                                    }.onDisappear {
                                        isLoading = true
                                    }
                            }
                        }.padding(.top, 10)
                    }
                }.padding(.top, 30)
                

                Spacer()
                
            }.ignoresSafeArea(.all)
        }.navigationBarBackButtonHidden(true)
    }
    
    func fetchProblemSet(_ name: String) {
        let docName = (name == "Factoring") ? "Poly" : name
//        print(docName)
        let problemSet = (docName == "Poly") ? PolySet : ((docName == "Trig") ? TrigSet : DerivativeSet)
        if !problemSet.isEmpty { return }
        
        db.collection("Problems").document(docName).getDocument { (document, error) in
            if let document = document, document.exists {
//                isLoading = true
                let data: [String: Any] = document.data() ?? [:]

                for (probNum, problem ) in data {
                    let problemInfo = problem as! NSDictionary
                    let question = problemInfo["question"]!
                    let choices = problemInfo["choices"]!

                    let problemData = ProblemData(id: probNum,
                                                  question: question as? String ?? "",
                                                  choices: choices as? [String] ?? [])
                    switch(docName) {
                    case "Poly":
                        PolySet.append(problemData)
                        break
                    case "Trig":
                        TrigSet.append(problemData)
                        break
                    case "Derivative":
                        DerivativeSet.append(problemData)
                        break
                    default:
                        break
                    }
                }
//                if(PolySet.count == 10 && DerivativeSet.count == 10 && TrigSet.count == 10) {
//                    isLoading = false
//                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func fetchUserProgress() {
        db.collection("Users")
            .document(Auth.auth().currentUser!.uid)
            .getDocument(as: UserData.self) { result in
                switch result {
                    case .success(let document):
//                    let decodedData = try JSONDecoder().decode(UserData.self, from: document)
                    topicProgress = document.progress as [String: Int]
                    print("fetched progress: \(topicProgress)")
                    userScore = document.score
                    userStreak = document.streak
                    
                    // set flag to indicate all necessary data has been loaded in
                    isLoading = false

                    case .failure(let error):
                        print("Error fetching document: \(error)")
                }
        }
        
    }
    
    func calculateTimeDifference() {
        // today's date-time
        let calendar = Calendar.current
        // create specific date components for specific time
        // This creates for 9AM the next day
        let components = DateComponents(year: calendar.component(.year, from: .now),
                                        month: calendar.component(.month, from: .now),
                                        day: calendar.component(.day, from: .now)+1,  // current day+1 -> next day
                                        hour: 9,    // 9AM
                                        minute: 0,
                                        second: 0)
        print(calendar)
        print(calendar.date(from: components)!)
        // construct date-time from these components
        let problemRefreshDate = calendar.date(from: components)!
        // track difference between current date-time and this constructed date-time (in seconds)
        print(problemRefreshDate)
        countDown = problemRefreshDate.timeIntervalSince(.now)
    }

    func formattedTime() -> String {
        let seconds = Int(countDown)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }

}

//struct TimerView: View {
//    
//    @State private var countDown = TimeInterval()
//    @State private var timerRunning = true
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    
//    var test = true
//    
//    var body: some View {
////        VStack {
////            $app.probOfDaySolved.wrappedValue
//            
//            // if problem of the day is solved, show timer
//            Text(test ? formattedTime() : "Solve")     // difference available in seconds, format tthe value in HH:MM:SS
//                .font(.title)
//                .onReceive(timer) { _ in
//                    if countDown > 0  && timerRunning {
//                        countDown -= 1
//                    } else {
//                        // by updating a state variable when the timer runs out, we can update the button to be active (so the problem of the day is made available)
//                        //                            timerRunning = false
//                        timer.upstream.connect().cancel()     // relinquish thread process
//                    }
//                }
//            //
//            //                if !timerRunning {
//            //                    Text("display text when timer up!")
//            //                        .font(.largeTitle)
//            //                        .padding()
//            //                }
//            .onAppear {
//                calculateTimeDifference()
//            }
//    }
//    
//   
//}

#Preview {
    HomeView()
        .environmentObject(AppVariables())
}
