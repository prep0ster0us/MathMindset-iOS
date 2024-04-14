//
//  TopicCard.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 3/19/24.
//

import SwiftUI
import Firebase

struct TopicCard: View {
    
    let name: String
    let image: String
    @State var completed: Int
    @State var starCount: Double
    
    init(name: String, image: String, completed: Int) {
        self.name = name
        self.image = image
        self.completed = completed
        //        self.starCount = Double(completed) / 2.0
        self.starCount = Double(completed)
    }
    
    let db = Firestore.firestore()
//    
//    func increaseCompleted() {
//        if self.completed <= 9 {
//            self.completed += 1
//            //            self.starCount += 0.5
//            self.starCount += 1
//        }
//    }
    
    var body: some View {

//        NavigationStack  {
            HStack {
                Spacer().overlay(
                    Text(self.name)
                        .font(.system(size: 16, weight: .bold))
                        .padding(.trailing, 8)
                )
                // TODO: update to Image(self.image) if we find enough images
                Spacer().overlay (
                    VStack {
                        HStack {
                            ForEach(0..<5) { i in
                                StarImage(count: i, completed: self.completed)
                            }
                        }
                        HStack {
                            ForEach(5..<10) { i in
                                StarImage(count: i, completed: self.completed)
                            }
                        }
                    }.padding(.trailing, 50)
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.85, green: 0.95, blue: 1))
                    .shadow(radius: 5)
                    .frame(width: 285, height: 80))
            .padding(42)
//        }
    }
    
    
    
}

struct StarImage: View {
    @State var count : Int
    @State var completed: Int
    var body : some View {
        VStack {
            Image(systemName: completed>count ? "star.fill" : "star")
                .foregroundStyle(Color(.yellow))
                .overlay(Image(systemName: "star")
                    .foregroundStyle(.black))
        }
    }
}

#Preview {
    TopicCard(name: "Factoring",
              image: "Factoring",
              completed: 7)
}
