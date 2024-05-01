import SwiftUI
import Firebase

struct ProblemOfDay: View {

    
    @EnvironmentObject private var app: AppVariables
    @State private var isPressed: CGFloat = -1
    @State private var isLoading: Bool = true
    
    @State private var question : String = ""
    @State private var choices  : [String] = []
    
    let db = Firestore.firestore()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                content
            }
        }.onAppear {
            fetchProblemOfTheDay()
        }
    }
    
    var content: some View {
        VStack {
            
            // Problem Number header
            Text("Problem of the day")
                .font(.system(size: 32))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .underline()
                .padding(.top, 32)
                .padding(.bottom, 24)
            
            // Problem Statement
            let problemStatement = question.split(whereSeparator: \.isNewline)
            
            Text(problemStatement[0])
                .font(.title2)
                .fontWeight(.semibold)
                .shadow(radius: 20)
                
                .animation(.easeIn, value: 0.8)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(problemStatement[1])
                .font(.title)
                .fontWeight(.bold)
                .shadow(radius: 20)
                .padding(24)
                .animation(.easeIn, value: 0.8)
                .padding(.bottom, 16)
            
            // Layout for choices
            VStack(spacing: 28) {
                ProblemOption(choices, $isPressed, 1)
                ProblemOption(choices, $isPressed, 2)
                ProblemOption(choices, $isPressed, 3)
                ProblemOption(choices, $isPressed, 4)
            }.padding(.horizontal, 40)
            
            Spacer()
            
            // Submit answer
            SubmitButton(isPressed, isPOTD: true).environmentObject(app)
                .padding()
        }.background(
            LinearGradient(colors: [Color(.systemTeal).opacity(0.4), Color(.systemBlue).opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundStyle(.ultraThinMaterial)
                .ignoresSafeArea()                  // to cover the entire screen
        )
    }
    func fetchProblemOfTheDay() {
        // fetch a question at random
        let ref = db.collection("DailyProblems")
        ref.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    // fetch all documents
                    let documentIDs = querySnapshot?.documents.map { $0.documentID } ?? []
                    
                    if let firstID = documentIDs.randomElement() {
                        ref.document(firstID)
                            .getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data: [String: Any] = document.data() ?? [:]
                                print(data)
                                question = data["question"] as! String
                                choices = data["choices"] as! [String]
                                isLoading = false
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                }
            }
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
    @AppStorage("isNotificationsEnabled") private var notificationsEnabled: Bool = true
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
                        if notificationsEnabled { await createNotification() }
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
                // metric for keeping track of ProblemsOfTheDay solved by a user (account lifetime)
                let potdCount = document.data()?["POTD_count"] as? Int ?? -1
                transaction.updateData([
                    "POTD_count" : potdCount+1
                    ], forDocument: ref
                )
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

#Preview {
    ProblemOfDay()
        .environmentObject(AppVariables())
//    ProblemOfDay(
//        question: "This is a sample question\nThis is sample equation",
//        choices : ["Circle", "Triangle", "Square", "Polygon"]
//    ).environmentObject(AppVariables())
}
