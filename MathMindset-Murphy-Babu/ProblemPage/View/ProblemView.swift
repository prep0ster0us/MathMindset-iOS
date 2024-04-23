import SwiftUI
import Firebase

struct ProblemView: View {
    
    let topic       : String
    let problemNum  : Int
    let question    : String
    let choices     : [String]
    let problemSet  : [ProblemData]
    
    @State private var isPressed: CGFloat = -1
    
    @State private var selections: [CGFloat] = [1,2,3,4].shuffled()
    
    var body: some View {
        VStack {
            // Problem Number header
            Text("Problem \(problemNum)")
                .font(.system(size: 32))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .underline()
                .padding(.top, 20)
                .padding(.bottom, 24)
            
            // Progress Bar
            ProblemProgressBar2(progress: problemNum, color1: Color(.systemTeal), color2: Color(.systemGreen))
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
            
            // Vertical Layout Problem Choices
            //            VStack(spacing: 30) {
            //                HStack {
            //                    ProblemOption(choice: choices[0])
            //                    Spacer()
            //                    ProblemOption(choice: choices[1])
            //                }.padding(.horizontal, 40)
            //                HStack {
            //                    ProblemOption(choice: choices[2])
            //                    Spacer()
            //                    ProblemOption(choice: choices[3])
            //                }.padding(.horizontal, 40)
            //            }
            
            // Horizontal Layout for choices
            VStack(spacing: 28) {
                ProblemOption(choices, $isPressed, selections[0])
                ProblemOption(choices, $isPressed, selections[1])
                ProblemOption(choices, $isPressed, selections[2])
                ProblemOption(choices, $isPressed, selections[3])
            }.padding(.horizontal, 40)
            
            Spacer()
            
            // Submit answer
            SubmitProblem(isPressed, problemNum, problemSet, topic, selections)
                .padding()
        }.background(
            LinearGradient(colors: [Color(.systemTeal).opacity(0.4), Color(.systemBlue).opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundStyle(.ultraThinMaterial)
                .ignoresSafeArea()                  // to cover the entire screen
        ).onAppear {
            print("on problem page of \(question)")
        }
    }
}

struct SubmitProblem: View {
    
    var isPressed: CGFloat
    var problemNum: Int
    var problemSet: [ProblemData]
    var topic     : String
    var selections: [CGFloat]
    init(
        _ isPressed: CGFloat,
        _ problemNum: Int,
        _ problemSet: [ProblemData],
        _ topic     : String,
        _ selections: [CGFloat]
    ) {
        self.isPressed = isPressed
        self.problemNum = problemNum
        self.problemSet = problemSet
        self.topic      = topic
        self.selections = selections
    }
    
    @EnvironmentObject private var app: AppVariables
    
    @Environment(\.dismiss) var dismiss
    @State private var isCorrect = false
    @State private var showAlert = false
    @State private var showConfetti = 0
    @State private var navigateToNext = false
    
    var width: CGFloat = UIScreen.main.bounds.width-60
    var height: CGFloat = 58
    var radius: CGFloat = 24
    var offset: CGFloat = 6
    
    var color1: Color = Color(.systemTeal).opacity(0.6)
    var color2: Color = Color(.systemTeal)
    var color3: Color = Color(.systemBlue).opacity(0.5)
    var color4: Color = Color(.green).opacity(0.5)
    
    var body: some View {
        // Shadow Rectangle Button
        NavigationStack {
            VStack {
                NavigationLink(destination:
                                ProblemView(
                                    topic: topic,
                                    problemNum: problemNum+1,
                                    question: problemSet[problemNum+1].question,
                                    choices: problemSet[problemNum+1].choices,
                                    problemSet: problemSet
                                ),
                               isActive: $navigateToNext
                ){
                    Button(action: {
                        if isPressed == 1 {
                            isCorrect = true
                            showConfetti = 1
                        } else {
                            isCorrect = false
                        }
                        showAlert = true
                    }, label: {
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
                    }).buttonStyle(SubmitButtonStyle())
                        .confettiCannon(counter: $showConfetti, num: 150, confettiSize: 10, rainHeight: 400)
                    // TODO: add red hue to the background if answer is incorrect
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Problem Submission"),
                                  message: Text(isCorrect ? "Correct Answer!" : "Try Again!"),
                                  dismissButton: .default(Text(isCorrect ? "Next Problem" : "Ok")) {
                                if isCorrect {
                                    Task {
                                        await updateProgress(topic, problemNum)
                                    }
                                }
                                
                            })
                        }
                }
            }
        }
    }
    
    func updateProgress(_ topic: String, _ problemNum: Int) async {
        let userID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        let ref = db.collection("Users").document(userID)
//        ref.updateData([
////            "streak": last_login < Date.now() ? FieldValue.increment(1.0) : FieldValue.increment(0.0)
//            "score" : FieldValue.increment(5.0),
//            "progress.\(topic)": problemNum
//        ]) { err in
//            if let err = err {
//                print("Error updating progresss to \(topic): \(err.localizedDescription)")
//                return
//            }
//                
//            print("Progress updated for \(topic) of user: \(userID)")
//            navigateToNext.toggle()
//        }
        
        // try out transaction:
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
//                guard let lastLogin = document.data()?["last_login"] as? Date,
//                      let currStreak = document.data()?["streak"] as? Int else {
//                    return nil
//                }
                // debug
//                print(document.data()?["last_login"] as Any)
//                print("fetched data = \(String(describing: (document.data()?["streak_update_timestamp"] as? Timestamp)?.dateValue()))")
                let lastLogin = document.data()?["last_login"] as? Date ?? Date.now+100
                let lastStreakUpdate = document.data()?["streak_update_timestamp"] as? Timestamp
                let currStreak = document.data()?["streak"] as? Int ?? -1
                // debug
//                print("streak update timestamp = \(String(describing: lastStreakUpdate))")
//                print("day start= \(dayStart())")
//                print("current streak= \(currStreak)")
                print("got data")
                
                // 3. update data (based on criteria)
                
                // Compare the values and update if the condition is met
//                if lastLogin < Date.now && lastLogin > dateYesterday() {
                if (lastStreakUpdate?.dateValue())! < dayStart() {      // if last streak update was before 12AM today (start of new day); update streak & timestamp
                    print("updating streak, timestamp and progress --> \(currStreak) , \(lastStreakUpdate?.dateValue() ?? Date())")
                    transaction.updateData([
                        "streak": currStreak + 1,
                        "streak_update_timestamp" : Date(),
                        "progress.\(topic)": problemNum
                    ], forDocument: ref)
                } else {
                    print("only streak updated")
                    transaction.updateData([
                        "progress.\(topic)": problemNum
                    ], forDocument: ref)
                }
                print("updated data")
                return nil
            })
            print("Transaction successful!")
        } catch {
            print("Transaction failed! \(error)")
        }
        navigateToNext.toggle()
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
}

struct ProblemOption: View {
    let choices     : [String]
    let isPressed   : Binding<CGFloat>
    let choiceNum   : CGFloat
    
    init(
        _ choices   : [String],
        _ isPressed : Binding<CGFloat>,
        _ choiceNum : CGFloat
    ) {
        self.choices   = choices
        self.isPressed = isPressed
        self.choiceNum = choiceNum
    }
    
    // Horizontal buttons - For options which don't fit in the vertical view)
    var width: CGFloat = UIScreen.main.bounds.width-100
    var height: CGFloat = UIScreen.main.bounds.height/14
    
    //    var width: CGFloat = UIScreen.main.bounds.width/3
    //    var height: CGFloat = UIScreen.main.bounds.height/6
    var offset: CGFloat = 6
    
    let active  : Color = Color(.systemTeal)
    let inactive: Color = Color(.systemGray3)
    var color2: Color = Color(.bgTint)
    
    var body: some View {
        // OPTION-I - Rectangle with shadows
        VStack {
            Button(action: {
                isPressed.wrappedValue = choiceNum
            }, label: {
                Text(choices[Int(choiceNum)-1])
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(Color(.textTint))
                    .frame(width: width, height: height)
                    .overlay {
                        if (isPressed.wrappedValue == choiceNum) {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.bgContrast), lineWidth: 10)
                        }
                    }
                    .background(
                        ZStack {
                            Color(isPressed.wrappedValue == choiceNum ? active : inactive)
                                .opacity(0.4)
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                            //                            .stroke(Color(.black), lineWidth: 3)
                                .fill(color2)
                                .blur(radius: 4)
                                .offset(x: -4, y: -4)
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                            //                            .stroke(Color(.black), lineWidth: 3)
                                .fill(
                                    LinearGradient(colors: [
                                        (isPressed.wrappedValue == choiceNum ? active : inactive)
                                            .opacity(0.1), color2], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .padding(2)
                                .blur(radius: 2)
                        }
                    ).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color(.bgContrast).opacity(0.15), radius: 6, x: offset, y: offset)
                    .shadow(color: color2.opacity(0.3), radius: 12, x: -offset, y: -offset)
            }).buttonStyle(OptionButtonStyle())
        }
        
    }
}

// Default Button Press-down style
struct OptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .brightness(configuration.isPressed ? 0.05 : 0)
    }
}


struct SubmitButton: View {
    
    var isPressed: CGFloat
    var isPOTD   : Bool
    init(
        _ isPressed: CGFloat,
        isPOTD  : Bool
    ) {
        self.isPressed = isPressed
        self.isPOTD = isPOTD
    }
    
    @EnvironmentObject private var app: AppVariables
    
    @Environment(\.dismiss) var dismiss
    @State private var isCorrect = false
    @State private var showAlert = false
    @State private var showConfetti = 0
    
    var width: CGFloat = UIScreen.main.bounds.width-60
    var height: CGFloat = 58
    var radius: CGFloat = 24
    var offset: CGFloat = 6
    
    var color1: Color = Color(.systemTeal).opacity(0.6)
    var color2: Color = Color(.systemTeal)
    var color3: Color = Color(.systemBlue).opacity(0.5)
    var color4: Color = Color(.green).opacity(0.5)
    
    var body: some View {
        // Shadow Rectangle Button
        VStack {
            Button(action: {
                if isPressed == 1 {
                    isCorrect = true
                    showConfetti = 1
                    Task {
                        await createNotification()
                        await updateProgress()
                    }
                } else {
                    isCorrect = false
                }
                showAlert = true
            }, label: {
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
            }).buttonStyle(SubmitButtonStyle())
                .confettiCannon(counter: $showConfetti, num: 150, confettiSize: 10, rainHeight: 400)
            // TODO: add red hue to the background if answer is incorrect
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Problem Submission"),
                          message: Text(isCorrect ? "Correct Answer!" : "Try Again!"),
                          dismissButton: .default(Text(isCorrect ? (isPOTD ? "Back to Home" : "Next Problem") : "Ok")) {
                        if isCorrect {
                            if isPOTD {
                                app.setStreak(newVal: $app.streak.wrappedValue+1)
                                self.app.primes += 5
                                self.app.probOfDaySolved = true
                                print(self.app.streak)
                                dismiss()
                            } else {
                                // TODO: go to next question
                                
                            }
                        }
                        
                    })
                }
        }
    }
    
    func updateProgress() async {
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
                        "score" : currScore+10
                    ], forDocument: ref)
                } else {
                    print("only streak updated")
                    transaction.updateData([
                        "score" : currScore+10
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
    
}

struct SubmitButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 1.08 : 1)
    }
}

struct ProblemProgressBar2: View {
    let progress: Int
    let color1: Color
    let color2: Color
    
    var width: CGFloat = UIScreen.main.bounds.width-60
    var height: CGFloat = 32
    var radius: CGFloat = 24
    //    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            // base
            RoundedRectangle(cornerRadius: radius, style: .continuous)
            //                .stroke(Color(.bgContrast).opacity(0.7), lineWidth: 2)
            //                .fill(Color(.bgContrast).opacity(colorScheme == .dark ? 0.1 : 0.8))     // TODO: use this to adjust base background for light/dark mode
                .fill(Color(.bgContrast).opacity(0.15))
                .frame(width: width, height: height)
            
            // progress
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(LinearGradient(colors: [color1, color2],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: (CGFloat(progress)/10)*width, height: height)
                .foregroundStyle(Color(.bgContrast).opacity(0.1))
        }
    }
}

struct ProblemProgressBar1: View {
    let progress: CGFloat
    let color1: Color
    let color2: Color
    
    var width: CGFloat = (UIScreen.main.bounds.width-60) / 10 // for each problem bar
    var height: CGFloat = 48
    var radius: CGFloat = 24
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            // base
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(Color(.bgContrast), lineWidth: 2)
                .frame(width: width*10+9, height: height)       // max frame = (width)*10 [for each problem] + 9 [width of vertical dividers]
                .foregroundStyle(Color(.bgContrast).opacity(0.1))
            
            HStack(spacing: 0) {
                // Problem 1
                if(progress > 0) {
                    Rectangle()
                        .fill(LinearGradient(colors: [color1, color2],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: width, height: height)
                        .padding(.trailing, radius)
                        .cornerRadius(radius)
                        .padding(.trailing, -radius)
                    Color(.black).frame(width: 1, height: height).padding(0)
                }
                // Problem 2
                let count = progress == 10 ? 8 : Int(round(progress))-1
                ForEach(0..<count, id: \.self) { index in
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(LinearGradient(colors: [color1, color2],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: width, height: height)
                        Color(.black).frame(width: 1, height: height)
                    }
                }
                
                // Problem 10
                if(progress == 10) {
                    Rectangle()
                        .fill(LinearGradient(colors: [color1, color2],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: width, height: height)
                        .padding(.leading, radius)
                        .cornerRadius(radius)
                        .padding(.leading, -radius)
                }
            }
        }
    }
}

#Preview {
    ProblemView(
        topic: "Trig",
        problemNum: 0,
        question: "Which of these shapes have 4 sides?\nImagine I drew a circle",
        choices: ["Triangle", "Circle", "Square", "Rectangle"],
        problemSet: factoringSet
    )
//    SubmitButton(1, isPOTD: true).environmentObject(AppVariables())
}

