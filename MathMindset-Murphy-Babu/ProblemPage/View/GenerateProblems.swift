import SwiftUI
import Firebase

struct GenerateProblems: View {
    
    let db = Firestore.firestore()
    let problemMap = [
        // TODO: complete this map based on the available problem sets
        // for which the question generation logic has been developed
        "Trig" : "Trigometry",
        "Poly" : "Polynomial",
        "Factoring" : "Factoring"
    ]
    
    
    
    var body: some View {
        // TODO: call the question builder, generate objects which contain the
        // - question
        // - 4 choices
        // - correct answer
        Text("test")
        let question: String = ""
        let choices: [String] = []
        let answer: String = ""
        
       
        
//
//        case "Trig":
//            self.thisProblem = Trig()
//        case "Factoring":
//            self.thisProblem = Poly()
//        default:
//            self.thisProblem = Poly()
//        }
        
//        let data: [String: Any] = [
//            "question"  : question,
//            "choices"   : choices,
//            "answer"    : answer
//        ]
//        addProblem(data)
        
    }
    
    private func addProblem(
        problemSet  : String,
        problemData : [String: Any]
    ) {
        var ref: DocumentReference? = nil
        ref = db.collection("Problems")
            .document(problemMap[problemSet]!)
            .collection(problemMap[problemSet]!)
            .addDocument(data: problemData) { err in
                if let err = err {
                    print("Error adding question to \(problemSet): \(err.localizedDescription)")
                } else {
                    print("Question added to \(problemMap[problemSet]!): \(ref!.documentID)")
                }
            }
    }
}

#Preview {
    GenerateProblems()
}
