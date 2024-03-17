import SwiftUI

struct SignInView: View {
    
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
