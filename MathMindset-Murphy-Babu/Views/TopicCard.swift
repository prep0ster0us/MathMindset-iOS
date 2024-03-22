//
//  TopicCard.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 3/19/24.
//

import SwiftUI

struct TopicCard: View {
    
    let name: String
    let image: String
    @State var completed: Int
    @State var starCount: Double
    
    init(name: String, image: String, completed: Int) {
        self.name = name
        self.image = image
        self.completed = completed
        self.starCount = Double(completed) / 2.0
    }
    
    func increaseCompleted() {
        if self.completed <= 9 {
            self.completed += 1
            self.starCount += 0.5
        }
    }
    
    var body: some View {
        HStack {
            Text(self.name)
                .font(.system(size: 16, weight: .bold))
                .padding(.trailing, 8)// TODO: update to Image(self.image) if we find enough images
            
            VStack {
                HStack {
                    StarImage(count: 0, completed: self.completed)
                    StarImage(count: 1, completed: self.completed)
                    StarImage(count: 2, completed: self.completed)
                    StarImage(count: 3, completed: self.completed)
                    StarImage(count: 4, completed: self.completed)
                }
                HStack {
                    StarImage(count: 5, completed: self.completed)
                    StarImage(count: 6, completed: self.completed)
                    StarImage(count: 7, completed: self.completed)
                    StarImage(count: 8, completed: self.completed)
                    StarImage(count: 9, completed: self.completed)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(red: 0.85, green: 0.95, blue: 1))
                .shadow(radius: 5)
        .frame(width: 285, height: 80))
    }
    
    
}

struct StarImage: View {
    var count : Int
    var completed: Int
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
