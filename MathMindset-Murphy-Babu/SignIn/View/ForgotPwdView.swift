import SwiftUI
import Firebase

struct ForgotPwdView: View {
    
    private var auth = Auth.auth()
    
    @State private var emailAddress: String = ""
    
    @Environment(\.dismiss) var dismiss
    @State private var showAlert : Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: .init(colors: [Color(.systemTeal), Color(.systemCyan), Color(.systemBlue)])
                           , startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            content
        }
    }
    
    var content: some View {
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
            // Header
            StrokeText(text: "Password Reset", width: 0.5, color: Color(.black))
            
            // Sub-Header - description
            Text("We'll send you a verification email to reset your password")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)          // internal padding
                .padding(.bottom, 36)           // margin
            
            // email address input field
            TextField("Enter your email address", text: $emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()                      // internal padding
                .padding(.horizontal, 12)       // horizontal spacing (for text)
                .background(
                    RoundedRectangle(cornerRadius:8)
                        .stroke(.black,lineWidth:2)
                        .fill(.white)
                )
                .foregroundStyle(.black)
                .padding(.horizontal, 24)       // margin (external padding)
                .padding(.bottom, 32)
            
            // Send reset mail btn
            Button(action: {
//                print("\(emailAddress)")        // debug
                // TODO: error testing this on preview/simulator; need to check on real device
                auth.sendPasswordReset(withEmail: emailAddress) { error in
                    if let error = error {
                        print("Error sending password reset mail : \(error.localizedDescription)")
                    } else {
                        print("Sent password reset mail!")
                    }
                }
                // show pop-up to confirm to user that the reset password has been sent
                // and once they acknowledge reading it, click button to go back to the login page
                withAnimation(Animation.easeIn(duration: 0.5)) {
                    showAlert = true
                }
            }, label: {
                Text("RESET")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.vertical)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 120)     // dynamic width, based on device's max screen width
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 8)
                    )
                
            }).background(
                LinearGradient(gradient: Gradient(colors: [Color(.systemBlue), Color(.systemTeal), Color(.systemMint)]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
            ).cornerRadius(50)
                .shadow(radius: 25)
                .alert("Email sent!", isPresented: $showAlert) {
                    Button(action: {dismiss()}, label: {
                        Text("Got it")
                    })
                } message: {
                    Text("You will receive an email to reset your password.")
                }
            
            
            Spacer()
        }
    }
}

#Preview {
    ForgotPwdView()
}
