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
    @State var pfpImageUrl : String
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
                .fill(standing == -1 ? Color(.bgTint).opacity(0.8) : Color(.bgContrast).opacity(0.1))
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
                    ZStack {
                        // Profile Image
                        if pfpImageUrl.isEmpty {
                            VStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: height-25, height: height-25)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                        .overlay(
                                            Circle()
                                                .stroke(.iconTint, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                                        )
                                        .foregroundStyle(.iconTint).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                            }
                        } else {
                            VStack {
                                AsyncImage(url: URL(string: pfpImageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
//                                    ProgressView()
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                                .frame(width: height-25, height: height-25)
                                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                    .overlay(
                                        Circle()
                                            .stroke(.iconTint, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                    )
                            }
                        }
                        Group {
                            switch(standing) {
                            case 0: Image("rank1")
                            case 1: Image("rank2")
                            case 2: Image("rank3")
                            default: Image(systemName: "trophy").opacity(0)
                            }
                        }.offset(x: -height/3, y: -height/4)
                    }.padding(.leading, 4)
                    
                    // Username
                    Text(username)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundStyle(.textTint)
                        .padding(.horizontal, 4)
                        .lineLimit(1)
                    
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
    }
    
}

#Preview {
    VStack(spacing: 30) {
        UserCard("UsernameVeryLong", "https://firebasestorage.googleapis.com:443/v0/b/mathmindset.appspot.com/o/Users%2FJbMMFqWltOhHk27cLgJ1CWCykzm1%2FprofileImage.jpg?alt=media&token=9562e9db-1589-4a4d-8746-a3080448ef5f", 9, "primes", 2)
        UserCard("standard google image",
        "Optional(https://lh3.googleusercontent.com/a/ACg8ocIoeHII-ObQlY-sif96lDVjiDf-Dn_mWY3YOEtp2CaktBhMGg=s96-c)", 15, "primes", 4)
        UserCard("empty user",
        "", 15, "primes", 4)
    }
}
