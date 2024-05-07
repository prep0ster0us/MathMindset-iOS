import Foundation

struct ProblemSetData: Codable, Hashable {
    var Problem1  : ProblemData
    var Problem2  : ProblemData
    var Problem3  : ProblemData
    var Problem4  : ProblemData
    var Problem5  : ProblemData
    var Problem6  : ProblemData
    var Problem7  : ProblemData
    var Problem8  : ProblemData
    var Problem9  : ProblemData
    var Problem10 : ProblemData
}

var ProblemSets : [String: ProblemSetData] = [:]
