//
//  SignUpView.swift
//  MathMindset-Murphy-Babu
//
//  Created by Ritwik on 3/11/24.
//

import SwiftUI

struct SignUpView: View {
    
    
//    @State private var visible = false
    @State private var btnColor = Color("#1FA744")
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: .init(colors: [Color(.systemTeal), Color(.systemCyan), Color(.systemBlue)])
                           , startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            LoginView()
        }
    }
}

struct LoginView: View {
    @State private var emailAddress = ""
    @State private var pass = ""
    @State private var visible = false
    
    private var width = 0.5;
    
    var body: some View {
        VStack {
            // App Logo
            Image("appLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 4))
                .shadow(radius: 25, x: 12, y: 16)
                .padding(.bottom, 24)
            // Header
            StrokeText(text: "Sign In", width: 0.5, color: Color(.textTint))
            
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
                
            // Login Input
            VStack {
                // Username/Email
                HStack {
                    // Icon
                    Image(systemName: "envelope")
                        .foregroundColor(.iconTint)
                        .frame(width: 24, height: 24, alignment: .center)
                    // Input Field
                    TextField("Username / Email Address", text: $emailAddress)
                        .padding()
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
    //                        .background(RoundedRectangle(cornerRadius:8)
    //                        .stroke(Color("loginTextField"),lineWidth:2))
    //                        .font(Font.custom("roboto", size: 16))      // TODO: addd custom font files for "Nexa"
                    } else {
                        SecureField("Password", text: $pass)
                            .autocapitalization(.none)
                            .foregroundColor(Color(.textTint))
                            .padding()
                            
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
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Forgot Password?")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(.textTint))
                            .italic()
                    })
                }.padding(.top, 12)
                    .padding(.trailing, 25)
            }.padding(.vertical, 36)
                .padding(.bottom, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.bgTint).opacity(0.85))
                .padding(.horizontal, 16)
                .padding(.top, 12)
            
            // Login Button
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("LOGIN")
                    .padding(.vertical)
                    .foregroundColor(.textTint)
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 100)     // dynamic width, based on device's max screen width
                
            }).background(LinearGradient(gradient: Gradient(colors: [Color(.systemBlue), Color(.systemTeal), Color(.systemMint)]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
                .cornerRadius(8)
                .offset(y: -40)
                .padding(.bottom, -40)
                .shadow(radius: 25)
            
            // Biometrics
            HStack {
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Use Biometrics")
                        .font(.system(size: 14))
//                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(Color(.textTint))
                        .underline()
                })
                Spacer()
            }.padding(.horizontal, 24)
                .padding(.top, 16)
            Spacer()
                
        }
    }
}


struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            ZStack {
                Text(text).font(.system(size: 36))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x: width, y: width)
                Text(text).font(.system(size: 36))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x: -width, y: -width)
                Text(text).font(.system(size: 36))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x: -width, y: width)
                Text(text).font(.system(size: 36))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x: width, y: -width)
            }
            .foregroundColor(color)
            Text(text).font(.system(size: 36))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    SignUpView()
}
