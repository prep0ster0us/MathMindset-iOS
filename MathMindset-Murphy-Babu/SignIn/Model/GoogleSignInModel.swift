//
//  GoogleSignInModel.swift
//  MathMindset-Murphy-Babu
//
//  Created by Ritwik on 4/11/24.
//

import Foundation
import Firebase
import GoogleSignIn

class GoogleSignInModel: ObservableObject {
    
    // check state of google sign-in
//    enum SignInState {
//        case signedIn
//        case signedOut
//    }
//    @Published var state: SignInState = .signedOut
    @Published var isSignedIn = false
    
    var dbManager = FirebaseManager()

    
    func signIn() {
        // If user already logged in, restore session
//        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
//            GIDSignIn.sharedInstance.restorePreviousSignIn()
//        } else {    // if not logged in previously
            // fetch clientID of app
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            // create google sign-in configuraiton object
            let configuration = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = configuration
            
            // sign in
            
            // create rootViewController (for sign-in view)
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            // 5
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { user, error in
//                authenticateUser(for: user, with: error)
                // if error, throw and return
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                // get user details
                guard
                    let user = user?.user,
                    let idToken = user.idToken else { return }
                
                let accessToken = user.accessToken
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                
                // Firebase Auth (using google creds)
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Error logging in google user: \(error.localizedDescription)")
                        return
                    }
                    
                    // sign-in
                    guard let user = authResult?.user else { return }
                    let uid = user.uid
                    print("User logged in: \(uid)")
                    self.isSignedIn = true // signify successful login
                    
                    // check if the user already exists
                    self.dbManager.checkIfGoogleUserExists(userID: uid, user: user)
                }
            }
//        }
    }
}


