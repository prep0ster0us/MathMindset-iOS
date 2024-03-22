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
    
    func loginUser(email: String, pass: String) {
        self.auth.signIn(withEmail: email, password: pass) { authResult, err in
            if let err = err {
                print("Error logging in user: \(err.localizedDescription)")
                return
            }
            // sign-in
            guard let user = authResult?.user else { return }
            let uid = user.uid
            print("User logged in: \(uid)")
        }
    }
    
    func registerUser(email: String, pass: String, username: String, dateOfBirth: Date, pfpImage: Image?) {
        // register for authentication
        auth.createUser(withEmail: email, password: pass) { authResult, err in
            if let err = err {
                print("Error registering user: \(err.localizedDescription)")
                return
            }
            
            // sign-in
            guard let user = authResult?.user else { return }
            let uid = user.uid
            print("User registered: \(uid)")
            
            let data: [String: Any] = [
                "email"                 : email,
                "username"              : username,
                "dateOfBirth"           : dateOfBirth,
                "account_creation_date" : Date(),
                "last_login"            : Date()
                // "profileImage"       : self.pfpImage // TODO: save firestore storage downloadURL here
            ]
            
            // TODO: safe profile image, if any
            //            if pfpImage != Image(systemName: "person.crop.circle") {
            //                let storageRef = self.storage.reference().child("/Users/\(String(describing: self.auth.currentUser?.uid))/profileImage.jpg")
            //                let metaImage = ImageRenderer(content: self.pfpImage)
            //                let imageData = .jpegData(withCompressionQuality: 0.5)
            //                storageRef.putData(image)
            //            }
            
            // save user details (after sign-in) to database
            self.saveUserDetails(uid: uid, data: data)
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
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("Error while trying to sign out: \(error.localizedDescription)")
        }
    }
    
    
}
