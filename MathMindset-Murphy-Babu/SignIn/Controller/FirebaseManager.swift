import Foundation
import SwiftUI
import Firebase
import FirebaseStorage

class FirebaseManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUser: User?
    
    var auth = Auth.auth()
    var db = Firestore.firestore()
    var storage = Storage.storage()
    
    init() {
        self.auth.addStateDidChangeListener { auth, user in
            if let user = user {
                print("Signed in as user :\(user.uid).")
                self.isSignedIn = true
            }
            else {
                self.isSignedIn = false
            }
        }
    }
    
    func loginUser(email: String, 
                   pass: String,
                   loginStatus: Binding<Bool>,
                   showAlert: Binding<Bool>,
                   requestBiometricAlert: Binding<Bool>
    ) {
        self.auth.signIn(withEmail: email, password: pass) { authResult, err in
            if let err = err {
                print("Error logging in user: \(err.localizedDescription)")
                showAlert.wrappedValue = true
                return
            }
            // sign-in
            guard let user = authResult?.user else { return }
            let uid = user.uid
            print("User logged in: \(uid)")
            loginStatus.wrappedValue = true // signify successful login
            
            // check if first login (i.e. biometricEnabled = "" [not false] )
            self.db.collection("Users")
                .document(uid)
                .getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data: [String: Any] = document.data() ?? [:]
                        if data["biometricEnabled"] as! String == "" {
                            withAnimation(Animation.easeIn) {
                                requestBiometricAlert.wrappedValue = true
                            }
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
        }
    }
    
    func registerUser(email: String, pass: String, username: String, dateOfBirth: Date, showAlert: Binding<Bool>, userid: Binding<String>) {
        // register for authentication
        auth.createUser(withEmail: email, password: pass) { authResult, err in
            if let err = err {
                print("Error registering user: \(err.localizedDescription)")
                return
            }
            
            // sign-in
            guard let user = authResult?.user else { return }
            let uid = user.uid      // used to upload profile photo, if any
            userid.wrappedValue = uid        // used to u
            print("User registered: \(uid)")
            
            // update display name (as username)
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error updating display name: \(error.localizedDescription)")
                } else {
                    print("Display name updated successfully")
                }
            }
            
            let data: [String: Any] = [
                "email"                 : email,
                "username"              : username,
                "dateOfBirth"           : dateOfBirth,
                "account_creation_date" : Date(),
                "last_login"            : Date(),
                "progress"              : ["Factoring": 0, "Trig": 0, "Derivative": 0],
                "profileImage"          : "", // save firestore storage downloadURL here
                "biometricEnabled"      : "",
                "score"                 : 0,
                "streak"                : 0
            ]
        
            // save user details (after sign-in) to database
            self.saveUserDetails(uid: uid, data: data)
            showAlert.wrappedValue = true   // signify successful registeration
        }
    }
    
    func saveUserDetails(uid: String, data: [String: Any]) {
        db.collection("Users")
            .document(uid)
            .setData(data) { err in
                if let err = err {
                    print("Error adding user details : \(err.localizedDescription)")
                } else {
                    print("User details added: \(self.auth.currentUser!.uid)")
                }
            }
    }
    
    func setBiometric(_ status: String) {
        // enable/disable biometric login
        let currentUser = self.auth.currentUser?.uid
        self.db.collection("Users")
            .document(currentUser!)
            .updateData(["biometricEnabled" : status]) { err in
                if let err = err {
                    print("Error updating biometric status for \(currentUser!): \(err.localizedDescription)")
                } else {
                    print("\(currentUser!)'s biometric status updated to: \(status)")
                }
            }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("Error while trying to sign out: \(error.localizedDescription)")
        }
    }
    
    func loginWithCredential(
        credential : AuthCredential,
        showAlert  : Binding<Bool>,
        loginStatus : Binding<Bool>
    ) {
        self.auth.signIn(with: credential) { authResult, err in
            if let err = err {
                print("Error logging in google user: \(err.localizedDescription)")
                showAlert.wrappedValue = true
                return
            }
            
            // sign-in
            guard let user = authResult?.user else { return }
            let uid = user.uid
            print("User logged in: \(uid)")
            loginStatus.wrappedValue = true // signify successful login
        }
    }
    
    func checkIfGoogleUserExists(
        userID : String,
        user   : User?
    ) {
        db.collection("Users")
            .document(userID)
            .getDocument { (document, error) in
                if let document = document, document.exists {
                    print("google sign-in user already exists, proceed with normal login and fetch")
//                    let data: [String: Any] = document.data() ?? [:]
//                    if data["biometricEnabled"] as! String == "" {
//                        withAnimation(Animation.easeIn) {
//                            requestBiometricAlert.wrappedValue = true
//                        }
//                    }
                } else {
                    // if does not exist, "register" the user and save initial details (to track info)
                    print("First sign-in with Google: \(userID)")
                    
                    print("email= \(String(describing: user?.email ?? ""))")
                    print("name= \(String(describing: user?.displayName ?? ""))")
                    print("photo url= \(String(describing: user?.photoURL))")
                    
                    let gEmail: String = user?.email ?? ""
                    let gName: String = user?.displayName ?? ""
                    let gDOB: Date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 1900, month: 1, day: 1))!
                    var gProfileImage: String = String(describing: user?.photoURL)
                    gProfileImage = gProfileImage.contains("Optional")
                    ? gProfileImage.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
                    : gProfileImage
//                        .contains("Optional") ? user?.photoURL[3..<(user?.photoURL.count) : ""]
                    // NOTE that this DOB is explicitly made to be a placeholder
                    // so it can be verified that the user does not have a DOB in place
                    // since this data is regulative to privacy control, we can't get this info from google directly
                    let calendar = Calendar.current
                    let data: [String: Any] = [
                        "email"                 : gEmail,
                        "username"              : gName,
                        "dateOfBirth"           : gDOB,
                        "account_creation_date" : Date(),
                        "last_login"            : Date(),
                        "progress"              : ["Factoring": 0, "Trig": 0, "Derivative": 0],
                        "quiz_scores"           : ["Factoring": 0, "Trig": 0, "Derivative": 0],
                        "profileImage"          : gProfileImage, // save firestore storage downloadURL here
                        "biometricEnabled"      : "",
                        "score"                 : 0,
                        "streak"                : 0,
                        "streak_update_timestamp" : calendar.date(from: DateComponents(
                            year: calendar.component(.year, from: .now)-1,
                            month: calendar.component(.month, from: .now),
                            day: calendar.component(.day, from: .now))
                        )!,      // deliberately setting date as an year in the past (so the first problem solve leads to proper update)
                        "potd_timestamp"          : calendar.date(from: DateComponents(
                            year: calendar.component(.year, from: .now)-1,
                            month: calendar.component(.month, from: .now),
                            day: calendar.component(.day, from: .now))
                        )!       // deliberately setting date as an year in the past (so the first problem solve leads to proper update)
                    ]
                
                    // save user details (after sign-in) to database
                    self.saveUserDetails(uid: userID, data: data)
                }
            }
    }
    
    
}
