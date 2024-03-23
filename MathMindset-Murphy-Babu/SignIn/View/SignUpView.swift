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
    
    @StateObject var dbManager = FirebaseManager()
    // TODO: delegate these state variables to have the values from the TextFields
    
    @Environment(\.dismiss) var dismiss
    
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
    
    @State private var pwdVisible = false
    @State private var confirmPwdVisible = false
    
    @State private var loginText = "LOGIN"
    @State private var animLogin = false
    @State private var animLoading = false
    @State private var showAlert = false
    
    private var width = 0.5;
    
    // for authentication
    private var auth = Auth.auth()
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    @State private var btnColor = Color("#1FA744")
    
    var body: some View {
        //        if isLoggedIn {
        //            // go somewhere
        //        } else {
        //            // show login page
        //            content
        //        }
        content
    }
    
    var content: some View {
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
                
                // Google-Sign in
                // Placeholder, TODO: update to actual sign-in button
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "key.viewfinder")
                        .foregroundStyle(Color(.iconTint))
                        .frame(width: 24, height: 24, alignment: .center)
                    Text("Sign in with Google")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.textTint))
                    
                }).padding(.vertical, 12)
                    .frame(width: UIScreen.main.bounds.width-50)
                    .background(RoundedRectangle(cornerRadius: 24).stroke(Color(.black), lineWidth: 2).fill(.bgTint).opacity(0.85))
                    .padding(.bottom, 12)
                
                // divider
                HStack {
                    Color(.white).opacity(0.5).frame(width: UIScreen.main.bounds.width/4, height: 1)
                    Text("OR").font(.system(size: 16)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).opacity(0.7).padding(.horizontal, 8)
                    Color(.white).opacity(0.5).frame(width: UIScreen.main.bounds.width/4, height: 1)
                }
                // Header
                StrokeText(text: "Sign Up", width: 0.5, color: Color(.textTint))
                
                // Register Input
                VStack {
                    // Profile Image
                    VStack {
                        PhotosPicker(selection: $photoPickerItem, matching: .images) {
                            pfpImage?
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .foregroundStyle(Color(red: 100/255, green: 100/255, blue: 100/255))
                                .clipShape(Circle())
                                .shadow(radius: 20, x: 8, y: 8)
                            
                        }
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.black)
                            .offset(y: -25)
                            .padding(.leading, 120)
                    }.onChange(of: photoPickerItem) { _, _ in
                        Task {
                            if let photoPickerItem,
                               let image = try? await photoPickerItem.loadTransferable(type: Image.self) {
                                pfpImage = image
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
                        .padding(.bottom, 24)
                    
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
                        .padding(.bottom, 24)
                    
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
                }.padding(.vertical, 36)
                    .padding(.bottom, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.bgTint).opacity(0.85))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                // Register Button
                Button(action: {
                    dbManager.registerUser(
                        email: email,
                        pass: pass,
                        username: username,
                        dateOfBirth: dateOfBirth,
                        pfpImage: pfpImage,
                        showAlert: $showAlert
                    )
                }, label: {
                    Text("REGISTER")
                        .padding(.vertical)
                        .foregroundColor(.textTint)
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
                        })
                    }
                
                // Redirect to log in
                HStack {
                    Button(action: {dismiss()}, label: {
                        Text("Already registered? \(Text("Sign In").underline())")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.textContrast))
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
}

#Preview {
    SignUpView()
}
