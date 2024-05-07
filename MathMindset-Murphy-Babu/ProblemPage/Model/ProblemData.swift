import Foundation

struct ProblemData: Codable, Hashable {
    var question : String = ""
    var choices  : [String] = []
    
    init(
        question: String = "",
        choices : [String] = []
    ) {
        self.question = question
        self.choices = choices
    }
}
