import SwiftUI
import Firebase

struct QuizView: View {
    //    @State private var topic       : String
    //     var problem     : Problem!
    //    @State private var problemNum  : Int
    //     var question    : String!
    //     var choices     : [String]!
    //    @State private var score       : Int // tracks number of correct answers
    
    @EnvironmentObject private var app: AppVariables
    // Topic should never change throughout the quiz
    // Descriptors
    private var topic: String
    @State private var problemNum: Int
    @State private var score: Int // tracks number of correct answers
    
    // Problem related vars
    private var correctIndex: Int = 1
    @State var selections: [Int] = [1, 2, 3, 4].shuffled()
    @State var problem: Problem!
    @State var question: String!
    @State var choices: [String]!
    //    @State var isPressed: Int = -1
    
    // After solving all questions, show score and dismiss back to home view
    @State var showScore: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var width: CGFloat = UIScreen.main.bounds.width-60
    var height: CGFloat = 58
    var radius: CGFloat = 24
    var offset: CGFloat = 6
    
    var color1: Color = Color(.systemTeal).opacity(0.6)
    var color2: Color = Color(.systemTeal)
    var color3: Color = Color(.systemBlue).opacity(0.5)
    var color4: Color = Color(.green).opacity(0.5)
    
    init(topic: String) {
        self.topic = topic
        
        // Initialize state values
        _problemNum = State(initialValue: 1) // counts to 10
        _score = State(initialValue: 0) // Anywhere from 0 to 10
        // no need to store self.problem.print()
        
        // The following is responsible for initializing:
        // problem, question, and choices
        self.generateProblem()
    }
    
    var body: some View {
        VStack {
            // Problem Number header
            Text("Quiz Problem \(problemNum)")
                .font(.system(size: 32))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .underline()
                .padding(.top, 20)
                .padding(.bottom, 24)
            
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
            
            // Horizontal Layout for choices
            VStack(spacing: 28) {
                QuizProblemOption(choice: choices[selections[0] - 1], choiceNum: selections[0])
                QuizProblemOption(choice: choices[selections[1] - 1], choiceNum: selections[1])
                QuizProblemOption(choice: choices[selections[2] - 1], choiceNum: selections[2])
                QuizProblemOption(choice: choices[selections[3] - 1], choiceNum: selections[3])
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Submit answer
            // TODO:
            // It did not seem simple to separate this
            // in another struct
            //            SubmitQuizProblem(isPressed, problemNum)
            Button(action: {
                if ($app.selectedButton.wrappedValue > 0) {
                    print("Wrapped value: \($app.selectedButton.wrappedValue)")
                    print("Selections: \(selections[0]), \(selections[1]), \(selections[2]), \(selections[3])")
                    print("Correct index just in case: \(correctIndex)")
                    if ($app.selectedButton.wrappedValue == correctIndex) {
                        print("Correct answer")
                        score += 1
                    } else {
                        print("Wrong answer")
                    }
                    app.selectedButton = -1
                    if (self.problemNum >= 10) { // not zero indexed
                        // TODO:
                        // Return to home page
                        // Compare score to old score
                        // If new score is greater:
                        //      Display new score and confetti
                        //      Update db if necessary
                        Task {
                            await updateQuizScore()
                        }
                        showScore.toggle()
                    } else {
                        problemNum += 1
                        problem = addQuizProblem(problemTopic: self.topic)
                        choices = [
                            problem.printFakeSol(choice: 1),// this is the correct choice
                            problem.printFakeSol(choice: 2),
                            problem.printFakeSol(choice: 3),
                            problem.printFakeSol(choice: 4)
                        ]
                        selections = [1, 2, 3, 4].shuffled()
                        question = problem.printQuestion() + "\n\(problem.print())"
                    }
                }
            }, label: {
                Text("Submit")
                    .font(.system(size: 24))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(Color(.textContrast))
                    .frame(width: width, height: height)
                    .background(
                        ZStack {
                            LinearGradient(colors: [color1, color2, color3, color4], startPoint: .topLeading, endPoint: .bottomTrailing)
                            RoundedRectangle(cornerRadius: radius,  style: .continuous)
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
                .alert(isPresented: $showScore) {
                    Alert(title: Text("Quiz Results"),
                          message: Text("Final Score : \(score)/10"),
                          dismissButton: .default(Text("Back to Home")) {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                }
        }
        .background(
            LinearGradient(colors: [Color(.systemTeal).opacity(0.4), Color(.systemBlue).opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundStyle(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
    
    private func addQuizProblem(problemTopic: String) -> Problem {
        // create problem
        var problem: Problem
        
        switch(problemTopic) {
        case "Derivative":
            problem = Derivative()
        case "Trig":
            problem = Trig()
        case "Factoring":
            problem = Factoring()
        case "Intersection":
            problem = Intersection()
        case "Integral":
            problem = Integral()
        default:
            // Default to avoid errors
            problem = Derivative()
        }
        return problem
    }
    
    mutating func generateProblem() {
        // TODO: Use self. accessor?
        _problem = State(initialValue: addQuizProblem(problemTopic: self.topic))
        _choices = State(initialValue: [
            problem.printFakeSol(choice: 1),// this is the correct choice
            problem.printFakeSol(choice: 2),
            problem.printFakeSol(choice: 3),
            problem.printFakeSol(choice: 4)
        ])
        
        _question = State(initialValue: problem.printQuestion() + "\n\(problem.print())")
    }
    
    func updateQuizScore() async {
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
                print("got user doc")
                
                // 2. get existing data
                //                let lastLogin = document.data()?["last_login"] as? Date ?? Date.now+100
                let userScores = document.data()?["quiz_scores"] as? [String: Int]
                let currScore = userScores!["\(topic)"]
                print("current score: \(String(describing: currScore))")
                print("got current scores")
                
                // 3. update data (based on criteria)
                
                // Compare the values and update if the condition is met
                if score > currScore! {      // if current quiz score > existing score (in db)
                    print("updating score, current --> \(String(describing: currScore)) to new --> \(score)")
                    transaction.updateData([
                        "quiz_scores.\(topic)": score
                    ], forDocument: ref)
                } else {
                    print("existing score is greater than current quiz score")
                }
                print("updated scores")
                return nil
            })
            print("Transaction successful!")
        } catch {
            print("Transaction failed! \(error)")
        }
    }
}

struct QuizProblemOption: View {
    //    @Binding var isPressed: Int
    
    @EnvironmentObject private var app: AppVariables
    var choice: String
    var choiceNum: Int
    
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
                app.selectedButton = choiceNum
            }, label: {
                //                Text(choices[Int(choiceNum)-1])
                Text(choice)
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(Color(.textTint))
                    .frame(width: width, height: height)
                    .overlay {
                        if ($app.selectedButton.wrappedValue == choiceNum) {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.bgContrast), lineWidth: 10)
                        }
                    }
                    .background(
                        ZStack {
                            Color($app.selectedButton.wrappedValue == choiceNum ? active : inactive)
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
                                        ($app.selectedButton.wrappedValue == choiceNum ? active : inactive)
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

#Preview {
    QuizView(topic: "Derivative")
        .environmentObject(AppVariables())
}
