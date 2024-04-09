import Foundation

@Identifiable class TopUser {
    var username    : String
    var pfpImageUrl : String
    var streak      : Int
    var score       : Int
    
    init(
        username    : String = "",
        pfpImageUrl : String = "",
        streak      : Int = 0,
        score       : Int = 0
    ) {
        self.username = username
        self.pfpImageUrl = pfpImageUrl
        self.streak = streak
        self.score = score
    }
}

var TopUsers : [TopUser] = []
