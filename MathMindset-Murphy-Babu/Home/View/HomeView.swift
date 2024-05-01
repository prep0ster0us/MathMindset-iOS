import SwiftUI
import Firebase

struct HomeView: View {
    @EnvironmentObject private var app: AppVariables
    var titles: [String] = ["Factoring",
                            "Derivative",
                            "Trig"]
    
    // For Problem of the day Button
    @State private var potdActive : Bool = true
    // timer afer solving Problem of the Day
    @State private var countDown = TimeInterval()
    @State private var timerRunning = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // fetch user-stats
    @State var topicProgress: [String: Any?] = [:]
    @State var userStreak   : Int = 0
    @State var userScore    : Int = 0
    @State var quizScores   : [String: Any?] = [:]
    
    // show loading screenl, while data is being fetched from database
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if(isLoading) {
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
                HStack(alignment: .center) {
                    Image(userStreak>0 ? "streakActive" : "streakInactive")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("\(userStreak)")
                        .font(.system(size: 18, weight: .heavy))
                    Spacer()
                    Text("\(userScore)")
                        .font(.system(size: 18, weight: .heavy))
                    Image(userScore>0 ? "primes" : "primesEmpty")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .padding()
                .padding(.top, 40)
                
                VStack {
                    Text("Problem of the Day")
                    // TODO: Find our own smallcaps font
                        .font(.title.smallCaps())
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.textTint))
                        .underline()
                        .padding(.bottom, 12)
                    Image(potdActive ? "potdActive" : "potdInactive")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)
                    // TODO: can still navigate to potd page; even when timer shows
                    NavigationLink(destination: ProblemOfDay().environmentObject(app)
                    ) {
                        Button(action: {}, label: {
                            Text(potdActive ? "Solve" : formattedTime())     // difference available in seconds, format tthe value in HH:MM:SS
                                .font(.title)
                                .onReceive(timer) { _ in
                                    if countDown > 0  && timerRunning {
                                        countDown -= 1
                                    } else {
                                        // by updating a state variable when the timer runs out, we can update the button to be active (so the problem of the day is made available)
                                        // timerRunning = false
                                        timer.upstream.connect().cancel()     // relinquish thread process
                                        potdActive = true
                                    }
                                }.onAppear {
                                    countDown = potdRefreshTimestamp().timeIntervalSince(.now)
                                }
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
                }.background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.85, green: 0.95, blue: 1))
                        .shadow(radius: 5)
                        .frame(width: 285, height: 265)
                )
                .padding(.top, 24)
                .padding(.bottom, 20)
                
                ScrollView{
                    VStack(alignment: .leading) {
                        ForEach(titles, id: \.self) { title in
                            let problemSet = title == "Factoring" ? PolySet : (title == "Trig" ? TrigSet : DerivativeSet)
                            NavigationLink(destination:
                                            ProblemsView(
                                                topic: title,
                                                problemSet: problemSet,
                                                problemNum: CGFloat(topicProgress[title] as! Int)
                                            )
                            ) {
                                TopicCard(name: title, image: title, completed: topicProgress[title] as! Int, quizScore: quizScores[title] as! Int)
                                    .frame(width: $app.screenWidth.wrappedValue)
                                    .onDisappear {
                                        isLoading = true
                                    }
                            }
                        }.padding(.top, 10)
                    }
                }.padding(.top, 20)
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
                if(PolySet.count == 10 && DerivativeSet.count == 10 && TrigSet.count == 10) {
                    // sort fetched question set (in order Problem1 - Problem10)
                    PolySet.sort { Int($0.id.replacingOccurrences(of: "Problem", with: ""))! < Int($1.id.replacingOccurrences(of: "Problem", with: ""))! }
                    DerivativeSet.sort{ Int($0.id.replacingOccurrences(of: "Problem", with: ""))! < Int($1.id.replacingOccurrences(of: "Problem", with: ""))! }
                    TrigSet.sort { Int($0.id.replacingOccurrences(of: "Problem", with: ""))! < Int($1.id.replacingOccurrences(of: "Problem", with: ""))! }
                }
                
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
                    userScore = document.score
                    userStreak = document.streak
                    quizScores = document.quiz_scores
                    
                    // check if problem of the day has been solved already
                    // last POTD solve is less than the POTD refresh timestamp (presently using 9AM everyday)
                    //                    potdActive = false           // reset before checking
                    if document.potd_timestamp < potdRefreshTimestamp() {
                        potdActive = false        // potd page should be made available
                    }
                    
                    // set flag to indicate all necessary data has been loaded in
                    isLoading = false
                    
                case .failure(let error):
                    print("Error fetching document: \(error)")
                }
            }
    }
    
    func potdRefreshTimestamp() -> Date {
        let calendar = Calendar.current
        let refreshDay = calendar.component(.hour, from: .now) < 9 ? 0 : 1
        let components = DateComponents(year: calendar.component(.year, from: .now),
                                        month: calendar.component(.month, from: .now),
                                        day: calendar.component(.day, from: .now)+refreshDay,  // current day
                                        hour: 9,    // 9AM
                                        minute: 0,
                                        second: 0)
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
