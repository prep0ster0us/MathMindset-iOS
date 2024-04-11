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
    
    
}
