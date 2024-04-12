import Foundation
import FirebaseFirestore

struct UserData: Codable, Identifiable {
    var id                      : String?
    var progress                : [String: Int]
    var last_login              : Date
    var account_creation_date   : Date
    var dateOfBirth             : Date
    var email                   : String
    var username                : String
    var score                   : Int
    var streak                  : Int
    var biometricEnabled        : String
    
    init(
        _ id                    : String?,
        _ email                 : String,
        _ username              : String,
        _ dateOfBirth           : Date,
        _ last_login            : Date,
        _ progress              : [String: Int],
        _ account_creation_date : Date,
        _ score                 : Int,
        _ streak                : Int,
        _ biometricEnabled      : String
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.dateOfBirth = dateOfBirth
        self.last_login = last_login
        self.progress = progress
        self.account_creation_date = account_creation_date
        self.score = score
        self.streak = streak
        self.biometricEnabled = biometricEnabled
    }
    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case myMap = "progress"
//    }
}
