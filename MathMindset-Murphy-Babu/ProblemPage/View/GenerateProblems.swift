import SwiftUI
import Firebase

struct GenerateProblems: View {
    
    let db = Firestore.firestore()
    
    let probNum = [2,3,4,5,6,7,8,9,10]
    @State private var factoringNum = 1
    @State private var derivNum = 1
    @State private var trigNum = 1
    @State private var intersectionNum = 1
    @State private var integralNum = 1
    @State private var num: Int = 1

    var body: some View {
        Text("<< Add more questions to database >> ")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color(.textTint))
        
//        /* test show */
//                let problem: Problem = Trig()
//
//                Text(problem.printQuestion() + "\n" + problem.print())
//                ForEach(0..<4) { i in
//                    Text(problem.printFakeSol(choice: i+1))
//                }
        
        VStack {
            Button(action: {
                addProblem("Derivative")
                derivNum += 1
            }, label: {
                Text("Add Derivative questions")
                    .foregroundStyle(Color(.white))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 200)
            }).padding()
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 4).fill(Color(.systemTeal).opacity(0.8)))
                .padding()
            
            // *** Trig question sometimes crashes preview
            Button(action: {
                addProblem("Trig")
                trigNum += 1
            }, label: {
                Text("Add Trig questions")
                    .foregroundStyle(Color(.white))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 200)
            }).padding()
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 4).fill(Color(.systemTeal).opacity(0.8)))
                .padding()
            
            Button(action: {
                addProblem("Factoring")
                factoringNum += 1
            }, label: {
                Text("Add factoring questions")
                    .foregroundStyle(Color(.white))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 200)
            }).padding()
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 4).fill(Color(.systemTeal).opacity(0.8)))
                .padding()
            
            Button(action: {
                addProblem("Intersection")
                intersectionNum += 1
            }, label: {
                Text("Add intersection questions")
                    .foregroundStyle(Color(.white))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 200)
            }).padding()
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 4).fill(Color(.systemTeal).opacity(0.8)))
                .padding()
            
            Button(action: {
                addProblem("Integral")
                integralNum += 1
            }, label: {
                Text("Add integral questions")
                    .foregroundStyle(Color(.white))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 200)
            }).padding()
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 4).fill(Color(.systemTeal).opacity(0.8)))
                .padding()
            
            Button(action: {
                addPOTD()
            }, label: {
                Text("Add Problem of the day questions")
                    .foregroundStyle(Color(.white))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 200)
            }).padding()
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 4).fill(Color(.systemTeal).opacity(0.8)))
                .padding()
            
            Button(action: {
                addNewTopicProgressToUser()
            }, label: {
                Text("Add New Topics")
                    .foregroundStyle(Color(.white))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 200)
            }).padding()
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 4).fill(Color(.systemTeal).opacity(0.8)))
                .padding()
        }
        
    }
    
    private func addProblem(_ problemTopic  : String) {
        // create problem
        var problem: Problem
        switch(problemTopic) {
        case "Derivative":
            problem = Derivative()
            num = derivNum
        case "Trig":
            problem = Trig()
            num = trigNum
        case "Factoring":
            problem = Factoring()
            num = factoringNum
        case "Intersection":
            problem = Intersection()
            num = intersectionNum
        case "Integral":
            problem = Integral()
            num = integralNum
        default:
            print("Invalid problem topic")
            return
        }
        
        let choices: [String] = [
            problem.printFakeSol(choice: 1),        // this is the correct choice
            problem.printFakeSol(choice: 2),
            problem.printFakeSol(choice: 3),
            problem.printFakeSol(choice: 4),
        ]
        
        let problemData: [String: Any] = [
            "question"  : problem.printQuestion() + "\n" + problem.print(),
            "choices"   : choices
        ]
        
        let docRef = db.collection("Problems").document(problemTopic)
        
        // first
        if(num == 1) {
            docRef.setData([
                "Problem\(num)" : problemData
            ]) { err in
                if let err = err {
                    print("Error adding question to \(problemTopic): \(err.localizedDescription)")
                } else {
                    print("Question added to \(problemTopic)")
                }
            }
        } else if(num < 11) {
            docRef.updateData([
                "Problem\(num)" : problemData
            ]) { err in
                if let err = err {
                    print("Error adding question to \(problemTopic): \(err.localizedDescription)")
                } else {
                    print("Question added to \(problemTopic)")
                }
            }
        }
    }
    
    private func addNewTopicProgressToUser() {
        let ref = db.collection("Users")
        ref.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error adding new topic progress: \(error.localizedDescription)")
            } else {
                let documentIDs = querySnapshot?.documents.map { $0.documentID } ?? []
                for document in documentIDs {
                    db.collection("Users")
                        .document(document)
                        .updateData([
                            // add in new topic names here, to update in users collection
                            "progress.Intersection": 0,
                            "progress.Integral"    : 0,
                            "quiz_scores.Intersection": -1,
                            "quiz_scores.Integral"    : -1,
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                }
            }
        }
    }
    
    private func addPOTD() {
        // create problem
        var problem: Problem
        let problemTopic = ["Derivative", "Trig", "Factoring", "Intersection","Integral"].randomElement()
        
        switch(problemTopic) {
        case "Derivative":
            problem = Derivative()
            num = derivNum
        case "Trig":
            problem = Trig()
            num = trigNum
        case "Factoring":
            problem = Factoring()
            num = factoringNum
        case "Intersection":
            problem = Intersection()
            num = intersectionNum
        case "Integral":
            problem = Integral()
            num = integralNum
        default:
            print("Invalid problem topic")
            return
        }
        
        let choices: [String] = [
            problem.printFakeSol(choice: 1),        // this is the correct choice
            problem.printFakeSol(choice: 2),
            problem.printFakeSol(choice: 3),
            problem.printFakeSol(choice: 4),
        ]
        
        let problemData: [String: Any] = [
            "question"  : problem.printQuestion() + "\n" + problem.print(),
            "choices"   : choices,
            "answered_correctly" : 0,       // TODO: update to reflect actual acount
            "answered_incorrectly" : 0
        ]
        
        let docRef = db.collection("DailyProblems").document()
        docRef.setData(problemData) { err in
            if let err = err {
                print("Error adding question to \(String(describing: problemTopic))-POTD: \(err.localizedDescription)")
            } else {
                print("Question added to \(String(describing: problemTopic))-POTD")
            }
        }
    }
}

#Preview {
    GenerateProblems()
}
