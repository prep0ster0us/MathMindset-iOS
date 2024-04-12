//
//  Home.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 3/18/24.
//

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
                        Text(($app.probOfDaySolved.wrappedValue) ? "\($app.timeLeft.wrappedValue)" : "Solve" )
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
                                                problemNum: topicProgress[title] as! Int+1,
                                                question: problemSet[topicProgress[title] as! Int].question,
                                                choices: problemSet[topicProgress[title] as! Int].choices,
                                                problemSet: problemSet
                                            )
                            ) {
                                TopicCard(name: title, image: title, completed: topicProgress[title] as! Int)
                                    .frame(width: $app.screenWidth.wrappedValue)
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
                isLoading = true
                let data: [String: Any] = document.data() ?? [:]

                for (probNum, problem ) in data {
                    let problemInfo = problem as! NSDictionary
                    let question = problemInfo["question"]!
                    let choices = problemInfo["choices"]!

                    let problemData = ProblemData(id: probNum,
                                                  question: question as! String,
                                                  choices: choices as! [String])
                    switch(docName) {
                    case "Poly":
                        PolySet.append(problemData!)
                        break
                    case "Trig":
                        TrigSet.append(problemData!)
                        break
                    case "Derivative":
                        DerivativeSet.append(problemData!)
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
                    print(topicProgress)
                    userScore = document.score
                    userStreak = document.streak
                    
                    // set flag to indicate all necessary data has been loaded in
                    isLoading = false

                    case .failure(let error):
                        print("Error fetching document: \(error)")
                }
        }
        
    }

}

#Preview {
    HomeView()
        .environmentObject(AppVariables())
}
