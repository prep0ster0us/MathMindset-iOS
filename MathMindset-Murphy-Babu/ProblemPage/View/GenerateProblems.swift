import SwiftUI
import Firebase

struct GenerateProblems: View {
    
    let db = Firestore.firestore()

    var body: some View {
        Text("<< Add more questions to database >> ")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color(.textTint))
        
        /* test show */
                let problem: Problem = Trig()
        
                Text(problem.printQuestion() + "\n" + problem.print())
                ForEach(0..<4) { i in
                    Text(problem.printFakeSol(choice: i+1))
                }
        
        VStack {
            Button(action: {addProblem("Derivative")}, label: {
                Text("Add Derivative questions")
                    .foregroundStyle(Color(.white))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 200)
            }).padding()
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 4).fill(Color(.systemTeal).opacity(0.8)))
                .padding()
            
            // *** Trig question sometimes crashes preview (possibly due to special symbol)
            Button(action: {addProblem("Trig")}, label: {
                Text("Add Trig questions")
                    .foregroundStyle(Color(.white))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 200)
            }).padding()
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 24).stroke(.black, lineWidth: 4).fill(Color(.systemTeal).opacity(0.8)))
                .padding()
            
            Button(action: {addProblem("Poly")}, label: {
                Text("Add Poly questions")
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
        case "Trig":
            problem = Trig()
        case "Poly":
            problem = Poly()
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
            "question"  : question,
            "choices"   : choices
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("Problems")
            .document(problemTopic)
            .collection(problemTopic)
            .addDocument(data: problemData) { err in
                if let err = err {
                    print("Error adding question to \(problemTopic): \(err.localizedDescription)")
                } else {
                    print("Question added to \(problemTopic): \(ref!.documentID)")
                }
            }
    }
}

#Preview {
    GenerateProblems()
}
