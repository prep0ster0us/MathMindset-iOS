//
//  SignUpView.swift
//  MathMindset-Murphy-Babu
//
//  Created by Ritwik on 3/11/24.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage

private var isRegistered = false

struct SignUpView: View {
    
    @Binding var loginStatus: Bool
    init(loginStatus: Binding<Bool>) {
        self._loginStatus = loginStatus
    }
    
    @StateObject var dbManager = FirebaseManager()
    @StateObject var googleAuthManager = GoogleSignInModel()
    // TODO: delegate these state variables to have the values from the TextFields
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var isDarkMode
    
    // Photo Picker package
    // followed tutorial for how to use
    // https://www.youtube.com/watch?v=jCskmh46L-s "New SwiftUI Photo Picker - Single & Multiple Selection" by Sean Allen
    @State private var pfpImage: Image? = Image(systemName: "person.crop.circle")       // default
    @State private var photoPickerItem: PhotosPickerItem?
    
    // input fields
    @State private var email = ""
    @State private var username = ""
    @State private var pass = ""
    @State private var confirmPass = ""
    @State private var dateOfBirth = Date()
    
    @State private var dateSelected = "Enter date of birth"
    @State private var isDatePickerVisible = false
    
    @FocusState var pwdFocused: Bool
    @FocusState var confirmPwdFocused: Bool
    @State private var pwdVisible = false
    @State private var confirmPwdVisible = false
    @State private var pwdMismatch = false
    @State private var pwdCriteriaNotFulfilled = false
    @State private var emptyFields = false
    @State private var registerError = false
    @State private var useruuid = ""
    
    @State private var loginText = "LOGIN"
    @State private var animLogin = false
    @State private var animLoading = false
    @State private var showAlert = false
    
    @State private var dbPfpImage: UIImage = UIImage()
    @State private var fetchedImageUrl: URL?
    
    private var width = 0.5;
    
    // for authentication
    private var auth = Auth.auth()
    private var db = Firestore.firestore()
    private var storage = Storage.storage().reference()
    
    @State private var btnColor = Color("#1FA744")
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: .init(colors: [Color(.systemTeal), Color(.systemCyan), Color(.systemBlue)])
                               , startPoint: .top, endPoint: .bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                showRegister
            }
        }
            
    }
    
    var showRegister: some View {
        ScrollView {
            VStack {
                // App Logo
                Image("appLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 4))
                    .shadow(radius: 25, x: 12, y: 16)
                    .padding(.bottom, 24)
                
                Button(action: {
                    googleAuthManager.signIn(loginStatus: $loginStatus)
                }, label: {
                    Image("google-logo")
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                    Text("Sign in with Google")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(.textTint))
                    
                }).padding(.vertical, 12)
                    .frame(width: UIScreen.main.bounds.width-50)
                    .background(RoundedRectangle(cornerRadius: 24).stroke(Color(.bgTint), lineWidth: 2).fill(.bgTint).opacity(0.85))
                    .padding(.bottom, 12)
                
                // divider
                HStack {
                    Color(.white)
                        .opacity(0.5)
                        .frame(width: UIScreen.main.bounds.width/4, height: 1)
                    Text("OR")
                        .font(.system(size: 16, weight: /*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/))
                        .foregroundStyle(.white)
                        .opacity(0.8)
                        .padding(.horizontal, 8)
                    Color(.white)
                        .opacity(0.5)
                        .frame(width: UIScreen.main.bounds.width/4, height: 1)
                }
                // Header
                StrokeText(text: "Sign Up", width: 0.5, color: Color(.black))
                
                // Register Input
                VStack {
                    // Profile Image
                    VStack {
                        PhotosPicker(selection: $photoPickerItem, matching: .images) {
                            pfpImage?
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .foregroundStyle(isDarkMode == .dark ? .iconTint : .iconTint.opacity(0.7))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.iconTint, lineWidth: 2))
                                .shadow(radius: 20, x: 8, y: 8)
                            
                        }
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(isDarkMode == .dark ? .iconTint : .iconTint.opacity(0.7))
                            .offset(y: -25)
                            .padding(.leading, 120)
                    }.onChange(of: photoPickerItem) { _, _ in
                        Task {
                            if let photoPickerItem,
                               let image = try? await photoPickerItem.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: image) {
                                    print(image)
                                    self.dbPfpImage = uiImage
                                    self.pfpImage = Image(uiImage: uiImage)
                                }
                            }
                        }
                    }
                    // Email Address
                    HStack {
                        // Icon
                        Image(systemName: "envelope")
                            .foregroundColor(.iconTint)
                            .frame(width: 24, height: 24, alignment: .center)
                        // Input Field
                        TextField("Enter your Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding()
                            .padding(.leading, -12)
                    }.padding(.horizontal, 12)          // internal padding
                        .background(RoundedRectangle(cornerRadius:6)
                            .stroke(Color("loginTextField"),lineWidth:2))
                        .padding(.horizontal, 24)       // margin (external padding)
                        .padding(.bottom, 24)
                    
                    // Username
                    HStack {
                        // Icon
                        Image(systemName: "person.text.rectangle")
                            .foregroundColor(.iconTint)
                            .frame(width: 24, height: 24, alignment: .center)
                        // Input Field
                        TextField("Create a username", text: $username)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding()
                            .padding(.leading, -12)
                    }.padding(.horizontal, 12)          // internal padding
                        .background(RoundedRectangle(cornerRadius:6)
                            .stroke(Color("loginTextField"),lineWidth:2))
                        .padding(.horizontal, 24)       // margin (external padding)
                        .padding(.bottom, 24)
                    
                    // Password
                    HStack {
                        // Icon
                        Image(systemName: "key")
                            .foregroundColor(.iconTint)
                            .frame(width: 24, height: 24, alignment: .center)
                        // Input Field
                        if pwdVisible {
                            TextField("Password", text: $pass)
                                .autocapitalization(.none)
                                .padding()
                                .padding(.leading, -12)
                                .focused($pwdFocused)
                            //                        .background(RoundedRectangle(cornerRadius:8)
                            //                        .stroke(Color("loginTextField"),lineWidth:2))
                            //                        .font(Font.custom("roboto", size: 16))      // TODO: addd custom font files for "Nexa"
                        } else {
                            SecureField("Password", text: $pass)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .foregroundColor(Color(.textTint))
                                .padding()
                                .padding(.leading, -12)
                                .focused($pwdFocused)
                            
                        }
                        // Toggle visibility of password field
                        Button(action: {
                            pwdVisible.toggle()
                        }) {
                            Image(systemName: pwdVisible ? "eye.circle.fill" : "eye.slash.circle")
                                .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                                .foregroundColor(Color("iconTint"))
                                .opacity(0.8)
                        }
                    }.padding(.horizontal, 12)      // internal padding
                        .background(RoundedRectangle(cornerRadius:6)
                            .stroke(Color("loginTextField"),lineWidth:2))
                        .padding(.horizontal, 24)   // margin (external padding)
                        
                    // Password criteria
                    if pwdFocused {
                        VStack (alignment: .leading, spacing: 2) {
                            Text("+ Contains atleast 6 characters")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(verifyPwdCondition(type: "length") ? .green : .red)
                            Text("+ Contains atleast 1 number [0-9]")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(verifyPwdCondition(type: "number") ? .green : .red)
                            Text("+ Contains atleast 1 special character [! @ # $ % ^ & *]")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(verifyPwdCondition(type: "special") ? .green : .red)
                        }
                            .padding(.top, 2)
                            .padding(.leading, -28)
                    }
                    // Confirm Password
                    HStack {
                        // Icon
                        Image(systemName: "key")
                            .foregroundColor(.iconTint)
                            .frame(width: 24, height: 24, alignment: .center)
                        // Input Field
                        if confirmPwdVisible {
                            TextField("Confirm Password", text: $confirmPass)
                                .autocapitalization(.none)
                                .padding()
                                .padding(.leading, -12)
                                .focused($confirmPwdFocused)
                            //                        .background(RoundedRectangle(cornerRadius:8)
                            //                        .stroke(Color("loginTextField"),lineWidth:2))
                            //                        .font(Font.custom("roboto", size: 16))      // TODO: addd custom font files for "Nexa"
                        } else {
                            SecureField("Confirm Password", text: $confirmPass)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .foregroundColor(Color(.textTint))
                                .padding()
                                .padding(.leading, -12)
                                .focused($confirmPwdFocused)
                            
                        }
                        // Toggle visibility of password field
                        Button(action: {
                            confirmPwdVisible.toggle()
                        }) {
                            Image(systemName: confirmPwdVisible ? "eye.circle.fill" : "eye.slash.circle")
                                .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                                .foregroundColor(Color("iconTint"))
                                .opacity(0.8)
                        }
                    }.padding(.horizontal, 12)      // internal padding
                        .background(RoundedRectangle(cornerRadius:6)
                            .stroke(Color("loginTextField"),lineWidth:2))
                        .padding(.horizontal, 24)   // margin (external padding)
                        .padding(.top, pwdFocused ? 16 : 24)
                    if confirmPwdFocused {
                        HStack {
                            Text(confirmPass == pass ? "Passwords match" : "Passwords do not match")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(confirmPass == pass ? .green : .red)
                            Spacer()
                        }.padding(.top, 2)
                            .padding(.leading, 32)
                    }
                    
                    // Date of Birth
                    HStack {
                        // Icon
                        Image(systemName: "calendar")
                            .foregroundColor(.iconTint)
                            .frame(width: 24, height: 24, alignment: .center)
                        // Date Picker
                        ZStack {
                            Text(dateSelected)
                                .opacity(dateSelected == "Enter date of birth" ? 0.3 : 1)
                                .foregroundColor(Color(.textTint))
                                .padding()
                                .padding(.leading, -12)
                            
                            DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .frame(width: 0, height: 0, alignment: .center)
                                .clipped()
                                .scaleEffect(1.2)
                                .background(Color(.systemBlue))
                                .labelsHidden()
                                .onChange(of: dateOfBirth) { _, selectedDate in
                                    if selectedDate != Date() {
                                        let formatter = DateFormatter()
                                        formatter.dateStyle = .medium
                                        dateSelected = formatter.string(from: selectedDate)
                                    } else {
                                        dateSelected = "Enter date of birth"
                                    }
                                    withAnimation(Animation.easeOut(duration: 0.5)) {
                                        isDatePickerVisible.toggle()
                                    }
                                }
                        }
                        Spacer()
                    }.padding(.horizontal, 12)      // internal padding
                        .background(RoundedRectangle(cornerRadius:6)
                            .stroke(Color("loginTextField"),lineWidth:2))
                        .padding(.horizontal, 24)   // margin (external padding)
                        .padding(.bottom, 24)
                        .padding(.top, confirmPwdFocused ? 16 : 24)
                }.padding(.vertical, 36)
                    .padding(.bottom, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.bgTint).opacity(0.85))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                // Register Button
                Button(action: {
                    if email.isEmpty || username.isEmpty || pass.isEmpty || confirmPass.isEmpty {
                        registerError.toggle()
                        emptyFields.toggle()
                        print("empty fields")
                    } else if !verifyPwdCondition(type: "length") || !verifyPwdCondition(type: "number") || !verifyPwdCondition(type: "special") {
                        registerError.toggle()
                        pwdCriteriaNotFulfilled.toggle()
                        print("criteria not match")
                    } else if confirmPass != pass {
                        registerError.toggle()
                        pwdMismatch.toggle()
                        print("mismatch")
                    } else {
                        dbManager.registerUser(
                            email: email,
                            pass: pass,
                            username: username,
                            dateOfBirth: dateOfBirth,
                            showAlert: $showAlert,
                            userid: $useruuid
                        )
                        print("sign in")
                    }
                }, label: {
                    Text("REGISTER")
                        .padding(.vertical)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .frame(width: UIScreen.main.bounds.width - 100)     // dynamic width, based on device's max screen width
                    
                }).background(LinearGradient(gradient: Gradient(colors: [Color(.systemBlue), Color(.systemTeal), Color(.systemMint)]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
                    .cornerRadius(8)
                    .offset(y: -40)
                    .padding(.bottom, -40)
                    .shadow(radius: 25)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Registered!"),
                              message: Text("Sign up complete. Please log in using your credentials."),
                              dismissButton: .default(Text("Ok")) {
                            dismiss()
                            saveProfileImage()
                        })
                    }
                    .alert(isPresented: $registerError) {
                        if pwdCriteriaNotFulfilled {
                            return Alert(title: Text("Weak Password!"),
                                  message: Text("\nPassword conditions not met.\nPlease ensure all criteria are fulfilled."),
                                  dismissButton: .default(Text("Enter again")) {
                                pwdCriteriaNotFulfilled.toggle()
                                withAnimation(Animation.easeOut){
                                    confirmPass = ""
                                    pass = ""
                                }
                            })
                        } else if pwdMismatch {
                            return Alert(title: Text("Password Mismatch!"),
                                         message: Text("Passwords entered do not match."),
                                         dismissButton: .default(Text("Enter again")) {
                                pwdMismatch.toggle()
                                withAnimation(Animation.easeOut) {
                                    confirmPass = ""
                                    pass = ""
                                }
                            })
                        }
                        // default
                        return Alert(title: Text("Missing Information!"),
                                     message: Text("Please fill in all the information before proceeding."),
                                     dismissButton: .default(Text("OK")) {
                            emptyFields.toggle()
                        } )
                    
                    }
                
                // Redirect to log in
                HStack {
                    Button(action: {dismiss()}, label: {
                        Text("Already registered? \(Text("Sign In").underline())")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.bottom, 12)
                    })
                }.padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.top, 36)
                Spacer()
                
            }.onAppear() {
                self.auth.addStateDidChangeListener { auth, user in
                    if user != nil {
                        isRegistered.toggle()
                    }
                }
            }
        }
    }
    
    func verifyPwdCondition(type: String) -> Bool {
        switch(type) {
        case "length" : return pass.count >= 6
        case "number" :
//            let numbersRange = pass.rangeOfCharacter(from:.decimalDigits)
//            return (numbersRange != nil)
            return pass.range(of: "[0-9]",options: .regularExpression) != nil
//            return pass.contains { $0.isASCII && $0.isNumber }
        case "special" :
//            let specialCharacters: CharacterSet = CharacterSet(charactersIn: "!@#$%^&*")
//            return pass.rangeOfCharacter(from: specialCharacters.inverted) != nil
            return pass.contains { String("!@#$%^&*").contains($0) }
        default: return true
        }
    }

    func saveProfileImage() {
        // no photo uploaded
        if dbPfpImage == UIImage() {
            print ("no photo to upload")
            return
        }
        guard let imageData = dbPfpImage.jpegData(compressionQuality: 0.5) else { return }
        let imgRef = storage.child("Users/\(useruuid)/profileImage.jpg")
        
        imgRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            print("Image uploaded successfully")
            
            
            // get download url for image
            imgRef.downloadURL(completion: { (url, err) in
                // error
                if let err = err {
                    print("Error getting download URL: \(err.localizedDescription)")
                    return
                }
                // nil data
                guard let url = url else {
                    print("Error: URL is nil")
                    return
                }
                let imageUrl = url.absoluteString
                
                // write url to database
                db.collection("Users")
                    .document(useruuid)
                    .updateData( ["profileImage": imageUrl]) { err in
                        if let err = err {
                            print("Error saving url to user's database: \(err.localizedDescription)")
                            return
                        }
                        print("image url successfully uploaded to user's database")
                    }
            })
        }
    }
}

#Preview {
    SignUpView(loginStatus: .constant(true))
}
