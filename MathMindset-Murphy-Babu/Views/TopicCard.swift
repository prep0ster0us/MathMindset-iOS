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
    
    var body: some View {
        
        HStack {
            Spacer().overlay(
                Text(self.name)
                    .font(.system(size: 20, weight: .heavy))
            )
            Spacer().overlay(
                Group{
                    if self.completed == 10 {
                        // in a VStack, since need both views in the if-condition to return same views
                        VStack {
                            QuizButton(true)
                                .padding(.leading, 16)
                        }
                    } else {
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
                        }
                    }
                }
                , alignment: .leading
            )
        }.frame(width: UIScreen.main.bounds.width - 50, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(getGradientColor().opacity(0.5))
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
    @State var completed: Int
    var body : some View {
        VStack {
            Image(systemName: completed>count ? "star.fill" : "star")
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
            .font(.title2)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        self.isEnabled
                        ? Color(red: 0, green: 0.8, blue: 1)
                        : Color(red: 0.7, green: 0.7, blue: 0.7)
                    )
                    .strokeBorder(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                    .shadow(radius: 4)
                    .frame(width: 150)
            )
            .foregroundColor(.textTint)
    }
}


#Preview {
    VStack(spacing: 15) {
        TopicCard(name: "Factoring",
                  image: "Factoring",
                  completed: 8)
        Spacer().frame(height: 50)
        TopicCard(name: "Factoring",
                  image: "Factoring",
                  completed: 10)
        TopicCard(name: "Trig",
                  image: "Trig",
                  completed: 7)
    }
}
