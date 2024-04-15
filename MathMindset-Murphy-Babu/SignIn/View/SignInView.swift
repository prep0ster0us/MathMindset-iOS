import SwiftUI
import Firebase
import LocalAuthentication      // for biometric login
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore
import FirebaseAuth

private var auth = Auth.auth()
private var isLoggedIn = false

struct SignInView: View {
    
    @StateObject var dbManager = FirebaseManager()
    @StateObject var googleAuthManager = GoogleSignInModel()
    
    // TODO: delegate these state variables to have the values from the TextFields
    @State private var email = ""
    @State private var pass = ""
    
    @State private var visible = false
    
    @State private var loginText = "LOGIN"
    @State private var animLogin = false
    @State private var animLoading = false
    
    @State private var loginStatus = false
    @State private var showAlert = false
    @State private var requestBiometricAlert = false
    @State private var usnEntered = false
    
//    @StateObject private var googleSignInModel = GoogleSignInModel()
    
    private var width = 0.5;
    
    private var auth = Auth.auth()
    
    //    @State private var visible = false
    @State private var btnColor = Color("#1FA744")
    
    @State var homePath = NavigationPath()
    
    var body: some View {
        // to enable view, based on 'stay signed in'
//        if isLoggedIn {
//            // go somewhere
//            NavigationLink(destination: HomeView().environmentObject(AppVariables())) { EmptyView() }
//        } else {
//            // show login page
//            content
//        }
        if googleAuthManager.isSignedIn {
            BottomBar(
                AnyView(HomeView()),
                AnyView(Leaderboards()),
                AnyView(Profile())
            )
            .environmentObject(AppVariables())
        } else {
            content
        }
//        content
    }
    
    var content: some View {
        NavigationStack(path: $homePath) {
            ZStack {
                LinearGradient(gradient: .init(colors: [Color(.systemTeal), Color(.systemCyan), Color(.systemBlue)])
                               , startPoint: .top, endPoint: .bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                showLogin
            }
        }.tint(.black)
    }
    
    var showLogin: some View {
        VStack {
            // App Logo
            Image("appLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 125, height: 125)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 4))
                .shadow(radius: 25, x: 12, y: 16)
                .padding(.bottom, 24)
            // Header
            StrokeText(text: "Sign In", width: 0.5, color: Color(.textTint))
            
            // Google-Sign in
            // Placeholder, TODO: update to actual sign-in button
            Button(action: {
                googleAuthManager.signIn()
            }, label: {
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
//            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal), action: {
//                handleGoogleSignIn()
//            })
            
            // divider
            HStack {
                Color(.white).opacity(0.5).frame(width: UIScreen.main.bounds.width/4, height: 1)
                Text("OR").font(.system(size: 16)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).opacity(0.7).padding(.horizontal, 8)
                Color(.white).opacity(0.5).frame(width: UIScreen.main.bounds.width/4, height: 1)
            }
            
            ZStack (alignment: .bottom) {
                // Login Input
                VStack {
                    // Username/Email
                    HStack {
                        // Icon
                        Image(systemName: "envelope")
                            .foregroundColor(.iconTint)
                            .frame(width: 24, height: 24, alignment: .center)
                        // Input Field
                        TextField("Username / Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding()
                            .padding(.leading, -12)
                            .onChange(of: email, {
                                if isValidEmail(email) {
                                    withAnimation(Animation.easeIn) {
                                        usnEntered.toggle()
                                    }
                                }
                            })
                    }.padding(.horizontal, 12)          // internal padding
                        .background(RoundedRectangle(cornerRadius:6)
                            .stroke(Color("loginTextField"),lineWidth:2))
                        .padding(.horizontal, 24)       // margin (external padding)
                        .padding(.bottom, 32)
                    
                    // Password
                    HStack {
                        // Icon
                        Image(systemName: "key")
                            .foregroundColor(.iconTint)
                            .frame(width: 24, height: 24, alignment: .center)
                        // Input Field
                        if visible {
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
                            visible.toggle()
                        }) {
                            Image(systemName: visible ? "eye.circle.fill" : "eye.slash.circle")
                                .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                                .foregroundColor(Color("iconTint"))
                                .opacity(0.8)
                        }
                    }.padding(.horizontal, 12)      // internal padding
                        .background(RoundedRectangle(cornerRadius:6)
                            .stroke(Color("loginTextField"),lineWidth:2))
                        .padding(.horizontal, 24)   // margin (external padding)
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        NavigationLink(destination: ForgotPwdView()) {
                            Text("Forgot Password?")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(.textTint))
                                .italic()
                        }
                    }.padding(.top, 12)
                        .padding(.trailing, 25)
                }.padding(.vertical, 36)
                    .padding(.bottom, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.bgTint).opacity(0.85))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                // Login Button
                
                NavigationLink(
                    destination: BottomBar(
                        AnyView(HomeView()),
                        AnyView(Leaderboards()),
                        AnyView(Profile())
                    )
                    .environmentObject(AppVariables()),
                    isActive: $loginStatus
                ) {
                    Button(action: {
                        print("pressed")
//                        dbManager.loginUser(
//                            email: email,
//                            pass: pass,
//                            loginStatus: $loginStatus,
//                            showAlert: $showAlert,
//                            requestBiometricAlert: $requestBiometricAlert
//                        )
                    }, label: {
                        Text("LOGIN")
                            .padding(.vertical)
                            .foregroundColor(.textContrast)
                            .fontWeight(.heavy)
                            .frame(width: UIScreen.main.bounds.width - 100)     // dynamic width, based on device's max screen width
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Login Error"),
                                      message: Text("Wrong credentials! Try Again"),
                                      dismissButton: .default(Text("Ok")) {
                                    pass=""     // clear password field
                                })
                            }
                        
                    }).background(LinearGradient(gradient: Gradient(colors: [Color(.systemBlue), Color(.systemTeal), Color(.systemMint)]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8).stroke(.iconTint, lineWidth: 2.5)
                        )
                        .offset(y: -40)
                        .padding(.bottom, -40)
                        .shadow(radius: 25)
                        .alert(isPresented: $requestBiometricAlert) {
                            Alert(title: Text("Biometric"),
                                  message: Text("Enable Biometric Login?"),
                                  primaryButton: .default(Text("Sure")) {
                                    UserDefaults.standard.set(email, forKey: "email")
                                    UserDefaults.standard.set(pass, forKey: "password")
                                    dbManager.setBiometric("true")
                                  },
                                  secondaryButton: .cancel(Text("Not now")) {
                                    dbManager.setBiometric("false")
                                  }
                            )
                        }
                }
                        .offset(y: 25)
            }
//            .navigationBarBackButtonHidden()
            
            // Biometrics
            // TODO: configure biometric login
            HStack (alignment: .center) {
                Button(action: {
                    biometricLogin()
                }, label: {
                    Text("Use Biometrics")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(.textContrast))
                        .underline()
                        .padding(.bottom, 25)
                })
            }.padding(.horizontal, 24)
                .padding(.top, 16)
                .opacity(usnEntered ? 1 : 0)
            

            Spacer()
            HStack {
                NavigationLink(destination: SignUpView()) {
                    Text("New User? \(Text("Create an account!").underline())")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.bottom, 24)
                }
            }
            
        }.onAppear() {
            self.auth.addStateDidChangeListener { auth, user in
                if user != nil {
                    isLoggedIn.toggle()
                }
                if UserDefaults.standard.string(forKey: "email") != nil {
                    print(UserDefaults.standard.string(forKey: "email") as Any)
                    email = UserDefaults.standard.string(forKey: "email")!
                }
            }
        }
    }
    
    // email format validation
    // reference: https://xavier7t.com/regex-in-swiftui
    private func isValidEmail(_ email: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{3,}$", options: [.caseInsensitive])
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count)) != nil
    }
    
    private func loginUser() {
        self.auth.signIn(withEmail: email, password: pass) { authResult, err in
            if let err = err {
                print("Error logging in user: \(err.localizedDescription)")
                return
            }
            // sign-in
            guard let user = authResult?.user else { return }
            let uid = user.uid
            print("User logged in: \(uid)")
            loginStatus = true // signify successful login
        }
    }
    
    private func biometricLogin() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "This is for security reasons"
            ) { success, authError in
                if authError != nil {
                    print(authError?.localizedDescription ?? "<invalid error>")
                    return
                }
                // if successful
                // first check if email matches saved credentials
                if UserDefaults.standard.string(forKey: "email") != nil {
                    if email == UserDefaults.standard.string(forKey: "email")! {
                        // if so, enter saved credentials and login
                        email = UserDefaults.standard.string(forKey: "email")!
                        pass = UserDefaults.standard.string(forKey: "password")!
                        dbManager.loginUser(
                            email: email,
                            pass: pass,
                            loginStatus: $loginStatus,
                            showAlert: $showAlert,
                            requestBiometricAlert: $requestBiometricAlert
                        )
                    } else {
                        print("Credentials don't match: \(email) - \(String(describing: UserDefaults.standard.string(forKey: "email")))")
                        return
                    }
                } else {
                    print("No saved credentials")
                    return
                }
                
            }
        }
    }
}

struct PlainSignInView: View {
    
    @State private var emailAddress = ""
    @State private var pass = ""
    @State private var visible = false
    @State private var btnColor = Color("#1FA744")
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Sign in to your account")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 15)
            HStack(spacing: 15) {
                Spacer()
                TextField("Username or Email", text: $emailAddress)
                    .autocapitalization(.none)
                    .frame(width: 300)
                    .padding()
                    .background(RoundedRectangle(cornerRadius:8)
                        .stroke(Color("loginTextField"),lineWidth:2)
                    )
                Spacer()
            }.padding(.horizontal, 4)
            
            ZStack(alignment: .trailing) {
                if self.visible {
                    TextField("Password", text: self.$pass)
                        .autocapitalization(.none)
                        .frame(width: 300)
                        .padding()
                        .background(RoundedRectangle(cornerRadius:8)
                            .stroke(Color("loginTextField"),lineWidth:2))
                        .font(Font.custom("roboto", size: 16))      // TODO: addd cusotm font files for "Nexa"
                } else {
                    SecureField("Password", text: self.$pass)
                        .autocapitalization(.none)
                        .frame(width: 300)
                        .padding()
                        .background(RoundedRectangle(cornerRadius:6)
                            .stroke(Color("loginTextField"),lineWidth:2))
                }
                // TODO: add password visibility toggle btn
                Button(action: {
                    visible.toggle()
                }) {
                    Image(systemName: visible ? "eye.circle.fill" : "eye.slash.circle.fill")
                        .foregroundColor(Color("iconTint"))
                        .opacity(0.8)
                }.padding(.trailing, 12)
            }.padding(EdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 4))
            
        }
        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
            Text("Login")
        }).frame(width: 300, height: 50)
            .foregroundColor(Color(.black))
            .background(RoundedRectangle(cornerRadius: 24).stroke(Color(.loginTextField), lineWidth: 2).fill(Color(.green)))
            .padding(EdgeInsets(top: 36, leading: 12, bottom: 12, trailing: 12))
        Text("Forgot Password?").foregroundColor(Color(.systemBlue)).underline().italic()
            .frame(width: 300, alignment: .trailing)
            .font(.system(size: 12))
            .font(Font.custom("roboto", size: 12))   // TODO: addd cusotm font files for "Nexa"
        Spacer()
        Group {
            Text("First Time?") +
            Text(" Create an account!").foregroundColor(Color(.systemBlue)).underline()
        }.font(.system(size: 12))
            .font(Font.custom("roboto", size: 12))   // TODO: addd cusotm font files for "Nexa"
    }
}

#Preview {
    SignInView()
}
