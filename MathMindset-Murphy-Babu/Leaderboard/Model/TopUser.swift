import Foundation

struct TopUser: Codable, Hashable {
    
    var username    : String
    var profileImage : String
    var streak      : Int
    var score       : Int
    
    init(
        username    : String = "",
        profileImage : String = "",
        streak      : Int = 0,
        score       : Int = 0
    ) {
        self.username = username
        self.profileImage = profileImage
        self.streak = streak
        self.score = score
    }
}

var TopUsers : [TopUser] = []
