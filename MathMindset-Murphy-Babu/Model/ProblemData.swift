import Foundation

struct ProblemData: Codable, Hashable {
    var id       : String
    var question : String = ""
    var choices  : [String] = []
    
    init(
        id      : String = "",
        question: String = "",
        choices : [String] = []
    ) {
        self.id = id
        self.question = question
        self.choices = choices
    }
}

var FactoringSet       : [ProblemData] = []
var TrigSet       : [ProblemData] = []
var DerivativeSet : [ProblemData] = []
