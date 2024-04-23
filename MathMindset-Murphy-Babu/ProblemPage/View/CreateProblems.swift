import Foundation
import Firebase

let db = Firestore.firestore()
let problemMap = [
    // TODO: complete this map based on the available problem sets
    // for which the question generation logic has been developed
    "Trig" : "Trigometry",
    "Derivative" : "Derivative",
    "Factoring" : "Factoring"
]


private var problem: Problem = Derivative()

var question: String = problem.printQuestion() + "\n" + problem.print()
var choices: [String] = [
    problem.printFakeSol(choice: 1),        // this is the correct choice
    problem.printFakeSol(choice: 2),
    problem.printFakeSol(choice: 3),
    problem.printFakeSol(choice: 4),
]

// add questions


let data: [String: Any] = [
    "question"  : question,
    "choices"   : choices
//    "answer"    : answer
]
//addProblem(problemSet: "Derivative", problemData: data)
//
private func addProblem(
    problemSet  : String,
    problemData : [String: Any]
) {
    var ref: DocumentReference? = nil
    ref = db.collection("Problems")
        .document("Derivative")
        .collection("Derivative")
        .addDocument(data: problemData) { err in
            if let err = err {
                print("Error adding question to \(problemSet): \(err.localizedDescription)")
            } else {
                print("Question added to \(problemMap[problemSet]!): \(ref!.documentID)")
            }
        }
}
