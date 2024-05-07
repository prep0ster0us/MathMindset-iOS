//
//  ProfileEditField.swift
//  MathMindset-Murphy-Babu
//
//  Created by Ritwik on 4/30/24.
//

import SwiftUI

struct ProfileEditField: View {
    let field: String
    let icon : String
    @Binding var text : String
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingPwdChangeLayout: Bool = false
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            if field == "Password" {
                SecureField(field, text: $text)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.borderTint.opacity(0.5), lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
                    .disabled(true)
                    .onTapGesture {
                        isShowingPwdChangeLayout.toggle()
                    }
                    .sheet(isPresented: $isShowingPwdChangeLayout) {
                        pwdChangeLayout
                            .presentationDetents([.fraction(0.45), .medium])
                    }
            } else {
                TextField(field, text: $text)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.borderTint.opacity(0.5), lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
            }
            Text(" \(field) ")
                .font(.system(size: 16, weight: .bold))
                .background(.bgTint)
                .padding(.leading, 24)
                .offset(y: -11)
            HStack {
                Spacer()
                Image(icon)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .padding(.trailing, 28)
                    .padding(.top, 10)
            }
        }
    }
    
    @State private var newPwdVisible: Bool = false
    @State private var confirmPwdVisible: Bool = false
    @State private var newPwd    : String = ""
    @State private var confirmPwd: String = ""
    @State private var showPwdMatch : Bool = false
    
    var pwdChangeLayout: some View {
        VStack {
            Text("Update Password")
                .font(.title)
                .fontWeight(.heavy)
                .padding(.top, 16)
            
            VStack {
                PasswordField(field: "New Password",
                              fieldVisible: $newPwdVisible,
                              fieldValue: $newPwd
                ).padding(.bottom, 36)
                PasswordField(field: "Confirm Password",
                              fieldVisible: $confirmPwdVisible,
                              fieldValue: $confirmPwd
                ).padding(.bottom, 12)
                HStack {
                    Button("Cancel") {
                        isShowingPwdChangeLayout.toggle()
                    }.buttonStyle(BorderedButtonStyle())
                        .padding(.vertical, 1)
                    Spacer()
                    Button(action: {
                        // match if new password matches confirm password
                        if newPwd == confirmPwd {
                            text = newPwd
                            isShowingPwdChangeLayout.toggle()
                        } else {
                            showPwdMatch.toggle()
                        }
                    }, label: {
                        Text("Save")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.textTint)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 4)
                            .background(.bgTint)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.iconTint, lineWidth: 2.5)
                            )
                    })
                }.alert(isPresented: $showPwdMatch, content: {
                    Alert(title: Text("Password Mismatch"),
                          message: Text("Passwords entered do not match!"),
                          dismissButton: .default(Text("OK")) {
                            newPwd = ""
                            confirmPwd = ""
                        }
                    )
                })
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }.padding(.top, 24)
        }
    }
}

struct PasswordField: View {
    let field : String
    @Binding var fieldVisible : Bool
    @Binding var fieldValue   : String
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            if fieldVisible {
                TextField(field, text: $fieldValue)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.borderTint.opacity(0.5), lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
            } else {
                SecureField(field, text: $fieldValue)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.borderTint.opacity(0.5), lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            Text(" \(field) ")
                .font(.system(size: 16, weight: .bold))
                .background(Color(.systemBackground))
                .padding(.leading, 24)
                .offset(y: -11)
            HStack {
                Spacer()
                Button(action: {
                    fieldVisible.toggle()
                }) {
                    Image(systemName: fieldVisible ? "eye.circle.fill" : "eye.slash.circle")
                        .foregroundStyle(.iconTint)
                        .opacity(0.8)
                }.padding(.top, 16)
                    .padding(.trailing, 28)
            }
        }
    }
}

#Preview {
    ProfileEditField(
        field: "Password",
        icon : "problemSolved",
        text : .constant("sample sample sample")
    )
}
