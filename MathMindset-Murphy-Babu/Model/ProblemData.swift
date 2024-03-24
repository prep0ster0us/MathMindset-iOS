import Foundation

class ProblemData: ObservableObject {
    let id: String
    @Published var question : String = ""
    @Published var choices  : [String: Any] = [:]
//    @Published var choices  : [String] = []
    
    required init?(
        id: String,
        data: [String: Any]
    ) {
        let question = data["question"] as? String != nil ? data["question"] as! String: ""
//        let choices = data["choices"] as? [String] != nil ? data["type"] as! [String]: []
        let choices = data["choices"] as? [String: Any] != nil ? data["type"] as! [String: Any]: [:]
        
        self.id = id
        self.question = question
        self.choices = choices
    }
}

var PolySet       : [ProblemData] = []
var TrigSet       : [ProblemData] = []
var DerivativeSet : [ProblemData] = []
