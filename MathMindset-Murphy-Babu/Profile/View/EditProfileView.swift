import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage

struct EditProfileView: View {
    
    var profileData: [String: Any]
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var pass: String = "Masked Password"     // hard-coded on purpose (this value is only shown as masked password, for security purposes)
    @State private var dob: Date = Date()
    @State private var pfpUrl: String = ""
    @State private var dbPfpImage: UIImage = UIImage()
    
    @State private var dateSelected: String = "No Record"
    @State private var isDatePickerVisible: Bool = false
    
    @State private var photoPickerItem: PhotosPickerItem?
    
    @State private var showUpdate: Bool = false
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    let storage = Storage.storage().reference()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            VStack {
                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    AsyncImage(url: URL(string: pfpUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(width: 150, height: 150)
                    .foregroundStyle(Color(red: 100/255, green: 100/255, blue: 100/255))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.iconTint, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    )
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
                       let image = try? await photoPickerItem.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: image) {
                            print(image)
                            self.dbPfpImage = uiImage
                            setImageUrl(image: uiImage)
                        }
                    }
                }
            }.padding(.bottom, 24)
            // User Name
            ProfileEditField(
                field: "User Name",
                icon : "usernameEdit",
                text : $username
            ).padding(.bottom, 32)
            // Email Address
            ProfileEditField(
                field: "Email Address",
                icon : "emailEdit",
                text : $email
            ).padding(.bottom, 32)
            // Password
            ProfileEditField(
                field: "Password",
                icon : "passEdit",
                text : $pass
            ).padding(.bottom, 32)
            
            // Date of birth
            ZStack {
                TextField("Date of Birth", text: $dateSelected)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.borderTint.opacity(0.5), lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
                    .disabled(true)
                HStack {
                    Text(" Date of Birth ")
                        .font(.system(size: 16, weight: .bold))
                        .background(.bgTint)
                        .padding(.leading, 24)
                        .offset(y: -28)
                    Spacer()
                }
                
                DatePicker("", selection: $dob, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .frame(width: 0, height: 0, alignment: .center)
                    .clipped()
                    .scaleEffect(1.2)
                    .background(Color(.systemBlue))
                    .labelsHidden()
                    .onChange(of: dob) { _, selectedDate in
                        if selectedDate != Date() && Calendar.current.component(.year, from: selectedDate) != 1900 {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            dateSelected = formatter.string(from: selectedDate)
                        } else {
                            dateSelected = "No Record"
                        }
                        withAnimation(Animation.easeOut(duration: 0.5)) {
                            isDatePickerVisible.toggle()
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width-32, alignment: .leading)
                HStack {
                    Spacer()
                    Image("dobEdit")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .padding(.trailing, 28)
                }
            }.padding(.bottom, 24)
            Button(action: {
                updateUserProfile()
                saveProfileImage()
                showUpdate.toggle()     // show confirmation alert
            }, label: {
                HStack {
                    Image("updateProfile")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.leading, 20)
                    Spacer()
                    Text("Update Profile")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.textTint)
                        .offset(x: -10)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                        .fill(.bgTint)
                )
            }).overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.bgContrast, lineWidth: 3)
                    .shadow(color: .bgContrast, radius: 16, x: 6, y: 4)
            )
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .alert(isPresented: $showUpdate) {
                Alert(title: Text("Update Profile"),
                      message: Text("Profile updated successfully!"),
                      dismissButton: .default(Text("Got it")) {
                    dismiss()       // go back
                })
            }
            Spacer()
        }.onAppear {
            username = profileData["username"] as! String
            email = profileData["email"] as! String
//            pass = profileData["pass"] as! String
            dob = profileData["dateOfBirth"] as! Date
            
            pfpUrl = profileData["pfpImageUrl"] as! String
        }
    }
    
    func setImageUrl(image: UIImage) {
        let imageData = image.jpegData(compressionQuality: 1.0)
        let base64String = imageData?.base64EncodedString() ?? ""
        pfpUrl = "data:image/jpeg;base64,\(base64String)"
    }
    
    func updateUserProfile() {
        let docRef = db.collection("Users").document(auth.currentUser!.uid)
        docRef.updateData([
            "username"    : username,
            "email"       : email,
            "dateOfBirth" : dob
        ]) { err in
            if let err = err {
                print("Error updating profile: \(err.localizedDescription)")
            } else {
                print("\(auth.currentUser!.uid)'s profile updated!")
            }
        }
        
        // update password, if changed
        if pass != "Masked Password" {
            // update in Firebase Auth
            auth.currentUser!.updatePassword(to: pass) { error in
                if let error = error {
                    print("Error updating password: \(error.localizedDescription)")
                } else {
                    print("Password updated successfully.")
                }
            }
            
            // update for biometric login, if saved
            if UserDefaults.standard.string(forKey: "email") != nil {
                // if current saved credentials match; then update password
                if UserDefaults.standard.string(forKey: "email")! == email {
                    UserDefaults.standard.set(pass, forKey: "password")
                }
            }
        }
    }
    
    func saveProfileImage() {
        // no photo uploaded
        if dbPfpImage == UIImage() {
            print ("no photo to upload")
            return
        }
        
        guard let imageData = dbPfpImage.jpegData(compressionQuality: 0.5) else { return }
        let useruuid = auth.currentUser!.uid
        let imgRef = storage.child("Users/\(useruuid)/profileImage.jpg")
        
        imgRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            print("profile image updated successfully")
            
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
                
                // update in Firebase Auth
                let changeRequest = auth.currentUser!.createProfileChangeRequest()
                changeRequest.photoURL = url
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error updating profile: \(error.localizedDescription)")
                    } else {
                        print("Profile updated successfully.")
                    }
                }
            })
        }
    }
}



#Preview {
    EditProfileView(profileData: [
        "username" : "testusername",
        "email"    : "dummy@test.com",
        "pass"     : "testsettest",
        "dateOfBirth" : Date.now
    ])
}
