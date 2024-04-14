import Foundation
import Firebase

struct ProblemViewModel: Codable, Hashable {
    var problemNum  : Int
    var question    : String
    var choices     : [String]
    var problemSet  : [ProblemData]
    
    init(
        problemNum  : Int = 0,
        question    : String = "",
        choices     : [String] = [],
        problemSet  : [ProblemData] = []
    ) {
        self.problemNum = problemNum
        self.question = question
        self.choices = choices
        self.problemSet = problemSet
    }
}
