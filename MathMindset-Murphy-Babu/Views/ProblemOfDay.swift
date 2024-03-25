//
//  ProblemOfDay.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 3/18/24.
//

import SwiftUI
import Firebase

struct ProblemOfDay: View {

    
    @EnvironmentObject private var app: AppVariables
    @State private var isPressed: CGFloat = -1
    @State private var isLoading: Bool = true
    
    @State private var question : String = ""
    @State private var choices  : [String] = []
    
    let db = Firestore.firestore()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                content
            }
        }.onAppear {
            fetchProblemOfTheDay()
        }
    }
    
    var content: some View {
        VStack {
            
            // Problem Number header
            Text("Problem of the day")
                .font(.system(size: 32))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .underline()
                .padding(.top, 32)
                .padding(.bottom, 24)
            
            // Problem Statement
            let problemStatement = question.split(whereSeparator: \.isNewline)
            
            Text(problemStatement[0])
                .font(.title2)
                .fontWeight(.semibold)
                .shadow(radius: 20)
                
                .animation(.easeIn, value: 0.8)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(problemStatement[1])
                .font(.title)
                .fontWeight(.bold)
                .shadow(radius: 20)
                .padding(24)
                .animation(.easeIn, value: 0.8)
                .padding(.bottom, 16)
            
            // VERTICAL Layout for choices
            //            VStack(spacing: 30) {
            //                HStack {
            //                    ProblemOption(choice: choices[0])
            //                    Spacer()
            //                    ProblemOption(choice: choices[1])
            //                }.padding(.horizontal, 40)
            //                HStack {
            //                    ProblemOption(choice: choices[2])
            //                    Spacer()
            //                    ProblemOption(choice: choices[3])
            //                }.padding(.horizontal, 40)
            //            }
            
            // Horizontal Layout for choices
            VStack(spacing: 28) {
                ProblemOption(choices, $isPressed, 1)
                ProblemOption(choices, $isPressed, 2)
                ProblemOption(choices, $isPressed, 3)
                ProblemOption(choices, $isPressed, 4)
            }.padding(.horizontal, 40)
            
            Spacer()
            
            // Submit answer
            SubmitButton(isPressed, isPOTD: true).environmentObject(app)
                .padding()
        }.background(
            LinearGradient(colors: [Color(.systemTeal).opacity(0.4), Color(.systemBlue).opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundStyle(.ultraThinMaterial)
                .ignoresSafeArea()                  // to cover the entire screen
        )
    }
    func fetchProblemOfTheDay() {
        // fetch a question at random
        let ref = db.collection("DailyProblems")
        ref.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    // fetch all documents
                    let documentIDs = querySnapshot?.documents.map { $0.documentID } ?? []
//                    let shuffledIDs = documentIDs.shuffled()
                    
                    if let firstID = documentIDs.randomElement() {
                        ref.document(firstID)
                            .getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data: [String: Any] = document.data() ?? [:]
                                print(data)
                                question = data["question"] as! String
                                choices = data["choices"] as! [String]
                                isLoading = false
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                }
            }
    }
    
}

#Preview {
    ProblemOfDay()
        .environmentObject(AppVariables())
//    ProblemOfDay(
//        question: "This is a sample question\nThis is sample equation",
//        choices : ["Circle", "Triangle", "Square", "Polygon"]
//    ).environmentObject(AppVariables())
}
