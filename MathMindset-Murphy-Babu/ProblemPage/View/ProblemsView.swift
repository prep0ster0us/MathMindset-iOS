import SwiftUI
import Firebase

struct ProblemsView: View {
    
    let topic              : String
    var problemSet         : ProblemSetData
    @State var problemNum  : CGFloat
    
    @State private var selections: [CGFloat] = [1,2,3,4].shuffled()
    
    @State private var problem         : ProblemData = ProblemData()
    @State private var question        : String = ""
    @State private var choices         : [String] = []
    @State private var isPressed       : CGFloat = -1
    @State private var setQuestionData : Bool = false
    
    // FOR SUBMIT BUTTON
    @Environment(\.dismiss) var dismiss
    @State private var isCorrect    = false
    @State private var showAlert    = false
    @State private var showConfetti = 0
    // CHECK FOR ALL 10 PROBLEMS SOLVED
    @State private var goToQuiz     = false
    @State private var backToHome   = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var isDarkMode
    
    var body: some View {
        // all problems solved, go to quiz
        if goToQuiz || problemNum >= 10 {
            QuizView(topic: topic).environmentObject(AppVariables())
        }
        // problems remaining, show respective problem page
        else {
            if setQuestionData {        // fetching question data
                content
            } else {
                ShapeProgressView()     // show progress view till problem page data ready
                    .onAppear {
                        reloadProblem()
                        setQuestionData = true
                    }
            }
        }
    }
    
    var content: some View {
        VStack {
            // Problem Number header
            Text("Problem \(Int(problemNum)+1)")
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(.black)
                .underline()
                .padding(.top, 20)
                .padding(.bottom, 24)
            
            // Progress Bar
            ProblemProgressBar2(
                progress: Int(problemNum),
                color1: Color(.systemTeal),
                color2: Color(.systemGreen)
            )
                .animation(.easeIn, value: 0.5)     // TODO: figure out load-in animation for bar
                .padding(.bottom, 16)
            
            // Problem Statement
            let problemStatement = question.split(whereSeparator: \.isNewline)
            
            Text(problemStatement[0])
                .font(.title2)
                .fontWeight(.semibold)
                .shadow(radius: 20)
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .animation(.easeIn, value: 0.8)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(problemStatement[1])
                .font(.title)
                .fontWeight(.bold)
                .shadow(radius: 20)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 20, trailing: 16))
                .animation(.easeIn, value: 0.8)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Layout for choices
            VStack(spacing: 28) {
                ProblemOption(choices, $isPressed, selections[0])
                ProblemOption(choices, $isPressed, selections[1])
                ProblemOption(choices, $isPressed, selections[2])
                ProblemOption(choices, $isPressed, selections[3])
            }.padding(.horizontal, 40)
            
            Spacer()
            
            // Submit button
            Button(action: {
                // check if selected option is correct
                if isPressed == 1 {
                    if problemNum >= 9 { backToHome.toggle() }
                    isCorrect = true
                    showConfetti += 1        // trigger confetti animation
                    Task {
                        await updateProgress(topic, Int(problemNum))
                    }
                } else {
                    isCorrect = false
                }
                // show alert for submission
                showAlert = true
            }, label: {
                SubmitText()
                    .buttonStyle(SubmitButtonStyle())
                    .confettiCannon(counter: $showConfetti, num: 150, confettiSize: 10, rainHeight: 400)
                // TODO: add red hue to the background if answer is incorrect
                    .alert(isPresented: $showAlert) {
                        if backToHome {
                            Alert(title: Text("All problems solved!"),
                                  message: Text("You can now take the quiz"),
                                  dismissButton: .default(Text("Back to Home")) {
                                self.presentationMode.wrappedValue.dismiss()
                            })
                        } else {
                            Alert(title: Text("Problem Submission"),
                                  message: Text(isCorrect ? "Correct Answer!" : "Try Again!"),
                                  dismissButton: .default(Text(isCorrect ? "Next Problem" : "Ok")) {
                                if isCorrect {
                                    resetToNext()
                                }
                                
                            })
                        }
                    }
            })
        }.background(
            LinearGradient(colors: [Color(.systemTeal),Color(.systemBlue)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height)
//                .foregroundStyle(.ultraThinMaterial)
                .ignoresSafeArea()                  // to cover the entire screen
                .opacity(isDarkMode == .dark ? 0.9 : 0.3)
        )
        // TODO: figure out navigation to page (instead of changing view content) - low priority
//        .navigationDestination(isPresented: $goToQuiz) {
////            QuizView(topic: topic)
//            ShapeProgressView()
//        }
    }
    
    func updateProgress(
        _ topic: String,
        _ problemNum: Int
    ) async {
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users").document(userID)
        
        // perform a transaction for running updates on database in batch
        do {
            let _ = try await db.runTransaction({ (transaction, errorPointer) -> Any? in
                // 1. fetch doc
                let document: DocumentSnapshot
                do {
                    try document = transaction.getDocument(ref)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                print("got doc")
                
                // 2. get existing data
//                let lastLogin = document.data()?["last_login"] as? Date ?? Date.now+100
                let lastStreakUpdate = document.data()?["streak_update_timestamp"] as? Timestamp
                let currStreak = document.data()?["streak"] as? Int ?? -1
                let currScore = document.data()?["score"] as? Int ?? -1
                print("got data")
                
                // 3. update data (based on criteria)
                
                // Compare the values and update if the condition is met
                if (lastStreakUpdate?.dateValue())! < dayStart() {      // if last streak update was before 12AM today (start of new day); update streak & timestamp
                    print("updating streak, timestamp and progress --> \(currStreak) , \(lastStreakUpdate?.dateValue() ?? Date())")
                    transaction.updateData([
                        "streak": currStreak + 1,
                        "streak_update_timestamp" : Date(),
                        "progress.\(topic)": problemNum+1,
                        "score" : currScore+5
                    ], forDocument: ref)
                } else {
                    print("only streak updated")
                    transaction.updateData([
                        "progress.\(topic)": problemNum+1,
                        "score" : currScore+5
                    ], forDocument: ref)
                }
                print("updated data")
                return nil
            })
            print("Transaction successful!")
        } catch {
            print("Transaction failed! \(error)")
        }
    }

    func dateYesterday() -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(
            year: Calendar.current.component(.year, from: Date.now),
            month: Calendar.current.component(.month, from: Date.now),
            day: Calendar.current.component(.day, from: Date.now)-1))!
    }
    
    func dayStart() -> Date {
        let calendar = Calendar.current
        return Calendar(identifier: .gregorian).date(from: DateComponents(
            year   : calendar.component(.year, from: Date.now),
            month  : calendar.component(.month, from: Date.now),
            day    : calendar.component(.day, from: Date.now),
            hour   : 0,
            minute : 0,
            second : 0)
        )!
    }
    
    // FOR RESETTING THE PAGE TO SHOW NEXT QUESTION
    // reset all variables used; and update the view to display the 'next' question
    func resetToNext() {
        isCorrect = false
        showAlert = false
//        showConfetti = 0
        isPressed = -1
        selections = selections.shuffled()
        
        if problemNum == 9 {        // 9 because coming from 0-indexed 'problemSet'
            // proceed to Quiz
            withAnimation(Animation.smooth) {
                goToQuiz = true
            }
        } else {
            // populate the next questions
            withAnimation(Animation.smooth(duration: 1.2)) {
                problemNum += 1
            }
            reloadProblem()
        }
    }
    
    func reloadProblem() {
        problem = {
            switch(problemNum) {
            case 1  : return problemSet.Problem1
            case 2  : return problemSet.Problem2
            case 3  : return problemSet.Problem3
            case 4  : return problemSet.Problem4
            case 5  : return problemSet.Problem5
            case 6  : return problemSet.Problem6
            case 7  : return problemSet.Problem7
            case 8  : return problemSet.Problem8
            case 9  : return problemSet.Problem9
            case 10 : return problemSet.Problem10
            default : return problemSet.Problem1
            }
        }()
        question = problem.question
        choices = problem.choices
    }
}

struct SubmitText: View {
    var width: CGFloat = UIScreen.main.bounds.width-60
    var height: CGFloat = 58
    var radius: CGFloat = 24
    var offset: CGFloat = 6
    
    var color1: Color = Color(.systemTeal).opacity(0.6)
    var color2: Color = Color(.systemTeal)
    var color3: Color = Color(.systemBlue).opacity(0.5)
    var color4: Color = Color(.green).opacity(0.5)
    
    var body: some View {
        Text("Check")
            .font(.system(size: 24))
            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            .foregroundStyle(Color(.textContrast))
            .frame(width: width, height: height)
            .background(
                ZStack {
                    LinearGradient(colors: [color1, color2, color3, color4], startPoint: .topLeading, endPoint: .bottomTrailing)
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                    //                            .stroke(Color(.black), lineWidth: 3)
                        .fill(color1)
                        .blur(radius: 4)
                        .offset(x: -4, y: -4)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                    //                            .stroke(Color(.black), lineWidth: 3)
                        .fill(LinearGradient(colors: [color2.opacity(0.1), color2], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .padding(2)
                        .blur(radius: 2)
                }
            ).clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: Color(.bgContrast).opacity(0.15), radius: 6, x: offset, y: offset)
            .shadow(color: color1.opacity(0.1), radius: 12, x: -offset, y: -offset)
    }
}

#Preview {
    ProblemsView(
        topic: "Trig",
        problemSet: ProblemSets["Factoring"]!,
        problemNum: 0
    )
}

