import Foundation

class ProblemData: ObservableObject {
    let id: String
    @Published var question : String = ""
    @Published var choices  : [String] = []
    
    required init?(
        id      : String,
        question: String,
        choices : [String]
    ) {
        self.id = id
        self.question = question
        self.choices = choices
    }
}

var PolySet       : [ProblemData] = []
var TrigSet       : [ProblemData] = []
var DerivativeSet : [ProblemData] = []
