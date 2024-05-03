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
    @Binding var completed: [String: Any?]
//    @State var starCount: Double
    @State var quizScore : Int
    
    init(name: String, image: String, completed: Binding<[String: Any?]>, quizScore: Int) {
        self.name = name
        self.image = image
        self._completed = completed
        //        self.starCount = Double(completed) / 2.0
//        self.starCount = Double(completed)
        self.quizScore = quizScore
    }
    
    var body: some View {
        
        HStack {
            Spacer().overlay(
                Text(self.name)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(.black)
            )
            Spacer().overlay(
                Group{
                    if self.completed[name] as! Int == 10 {
                        // in a VStack, since need both views in the if-condition to return same views
                        VStack {
                            QuizButton(true)
                                .padding(.leading, 16)
                            if quizScore != -1 {
                                Text("Best Score: \(quizScore)/10")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.leading, 16)
                            }
                        }
                    } else {
                        VStack {
                            HStack {
                                ForEach(0..<5) { i in
                                    StarImage(count: i, topic: name, completed: $completed)
                                }
                            }
                            HStack {
                                ForEach(5..<10) { i in
                                    StarImage(count: i, topic: name, completed: $completed)
                                }
                            }
                        }
                    }
                }
                , alignment: .leading
            )
        }.frame(width: UIScreen.main.bounds.width - 50, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(getGradientColor().opacity(0.6))
                .shadow(radius: 6)
        ).overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.black, lineWidth: 3)
                .shadow(radius: 6)
        )
    }
    
    func getGradientColor() -> LinearGradient {
        LinearGradient(gradient: .init(colors: [Color(.systemTeal), Color(.systemCyan), Color(.systemBlue)])
                       , startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct StarImage: View {
    @State var count : Int
    @State var topic: String
    @Binding var completed: [String: Any?]
    var body : some View {
        VStack {
            Image(systemName: (completed[topic] as! Int) > count ? "star.fill" : "star")
                .foregroundStyle(Color(.yellow))
                .overlay(
                    Image(systemName: "star")
                        .foregroundStyle(.black)
                )
        }
    }
}

struct QuizButton: View {
    var isEnabled: Bool
    
    init(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        // Quiz
        Text("Take Quiz")
            .font(.system(size: 18, weight: .medium))
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        self.isEnabled
                        ? Color(red: 0, green: 0.8, blue: 1)
                        : Color(red: 0.7, green: 0.7, blue: 0.7)
                    )
                    .strokeBorder(.iconTint)
                    .shadow(radius: 4)
                    .frame(width: 150)
            )
            .foregroundColor(.black)
    }
}
//
//
//#Preview {
//    VStack(spacing: 15) {
//        TopicCard(name: "Factoring",
//                  image: "Factoring",
//                  completed: 10, quizScore: 4)
////        Spacer().frame(height: 50)
////        TopicCard(name: "Factoring",
////                  image: "Factoring",
////                  completed: 10)
////        TopicCard(name: "Trig",
////                  image: "Trig",
////                  completed: 7)
//    }
//}
