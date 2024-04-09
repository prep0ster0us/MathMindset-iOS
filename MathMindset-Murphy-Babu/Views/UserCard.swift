//
//  UserCard.swift
//  MathMindset-Murphy-Babu
//
//  Created by Ritwik on 4/5/24.
//

import SwiftUI
import FirebaseStorage

struct UserCard: View {
    
    let username    : String
    let pfpImageUrl : String
    let metric      : CGFloat
    let metricType  : String
    let standing    : Int
    
    init(
        _ username     : String = "UserXYZ",
        _ pfpImageUrl  : String = "",
        _ metric       : CGFloat = 0,
        _ metricType   : String = "primes",
        _ standing     : Int = 1
    ){
        self.username    = username
        self.pfpImageUrl = pfpImageUrl
        self.standing    = standing
        self.metric      = metric
        self.metricType  = metricType
    }
    @State private var isTap = false
    @State private var imgData: Data? = nil // = UIImage(systemName: "person.circle")!.pngData()!
    
    let focusColor   : Color = Color(.bgContrast).opacity(0.3)
    let width        : CGFloat = UIScreen.main.bounds.width - 25
    let height       : CGFloat = 80
    let shadowRadius : CGFloat = 12
    let cornerRadius : CGFloat = 8
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isTap ? focusColor : Color(.bgContrast).opacity(0.1))
                .shadow(radius: shadowRadius, x: 12, y: 16)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.iconTint, lineWidth: 2)
                )
                .frame(maxWidth: width, minHeight: height, maxHeight: height)
                .padding(.horizontal, 12)
//                .padding(.vertical, 16)
            
            VStack {
                HStack {
                    // Top3 badge
                    Image(systemName: "trophy")
                        .foregroundStyle(standing == 0 ? 
                                         Color(.red) : (standing == 1 ? 
                                                        Color(.teal) : (standing == 2 ?
                                                                        Color(.yellow)
                                                                        : Color(.black)
                                                                       )
                                                       )
                        )
                        .opacity(standing < 3 ? 1 : 0)    // TODO: update top3 badge image
                    
                    // Profile Image
                    AsyncImage(url: URL(string: pfpImageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }.frame(width: height-25, height: height-25)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .overlay(
                            Circle()
                                .stroke(.iconTint, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        )
                    
                    // Username
                    Text(username)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundStyle(.textTint)
                        .padding()
                    
                    Spacer()
                    
                    // Leaderboard metric
                    VStack(alignment: .trailing) {
                        Text("\(Int(round(metric))) \(metricType)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.textTint)
                    }.padding(.trailing, 4)
                }.padding(.horizontal, 16)
            }
            .frame(maxWidth: width, maxHeight: height)
        }
//        .onTapGesture {
//            click()
//        }
//        .onLongPressGesture(minimumDuration: 0.3, pressing: {
//            pressing in isTap = pressing}, perform: { longClick()
//        })
    }
    
}

//struct UserCard: View {
//    @State private var isTap: Bool = false
//    
//    let cornerRadius : CGFloat
//    let fgColor      : Color
//    let bgColor      : Color
//    let focusColor   : Color?
//    let shadowRadius : CGFloat
//    let width        : CGFloat
//    let height       : CGFloat
//    let click        : () -> Void
//    let longClick    : () -> Void
//    let views        : () -> AnyView
//    
//    init(
//        cornerRadius : CGFloat = 16,
//        color        : Color   = Color(.white),
//        focusColor   : Color?  = nil,
//        shadowRadius : CGFloat = 12,
//        height       : CGFloat = 100,
//        width        : CGFloat = CGFloat.infinity,
//        click        : @escaping () -> Void = {},
//        longClick    : @escaping () -> Void = {},
//        views        : @escaping () -> AnyView
//    ){
//        self.cornerRadius = cornerRadius
//        self.fgColor      = color
//        self.bgColor      = color
//        self.focusColor   = focusColor
//        self.shadowRadius = shadowRadius
//        self.height       = height
//        self.width        = width
//        self.click        = click
//        self.longClick    = longClick
//        self.views        = views
//        
//    }
//    
//    var body: some View {
//        ZStack{
//            RoundedRectangle(cornerRadius: cornerRadius)
//                .fill(isTap ? focusColor ?? bgColor : bgColor)
//                .shadow(radius: shadowRadius)
//                .frame(maxWidth: width, minHeight: height, maxHeight: height)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 12)
//            
//            VStack{
//                views()
//            }
//            .frame(maxWidth: width, maxHeight: height)
//        }
//        .onTapGesture {
//            click()
//        }
//        .onLongPressGesture(minimumDuration: 0.3, pressing: {
//            pressing in isTap = pressing}, perform: { longClick()
//        })
//    }
//}

//    private func fetchProfileImage(_ pfpImageUrl: String) {
//        print(pfpImageUrl)
//        let storage = Storage.storage().reference()
//        let ref = storage.child(pfpImageUrl)
//        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
//            if let error = error {
//                print("\(error.localizedDescription)")
//            }
//
//            DispatchQueue.main.async {
//                withAnimation(Animation.easeIn) {
//                    self.imgData = data
//                    print("got data")
//                }
//            }
//        }
//    }

#Preview {
    UserCard("UserXYZ", "https://firebasestorage.googleapis.com:443/v0/b/mathmindset.appspot.com/o/Users%2FJbMMFqWltOhHk27cLgJ1CWCykzm1%2FprofileImage.jpg?alt=media&token=9562e9db-1589-4a4d-8746-a3080448ef5f", 9, "primes", 2)
//        AnyView(Text("this")
//            .padding(.vertical)
//            .padding(.horizontal, 20))
}
