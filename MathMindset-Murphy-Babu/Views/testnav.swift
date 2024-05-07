//
//  testnav.swift
//  MathMindset-Murphy-Babu
//
//  Created by Ritwik on 4/12/24.
//

import SwiftUI

struct testnav: View {
    var titles: [String] = ["Factoring",
                            "Derivative",
                            "Trig"]
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ForEach(titles, id: \.self) { title in
//                let problemSet = title == "Factoring" ? PolySet : (title == "Trig" ? TrigSet : DerivativeSet)
                NavigationLink(
                    value:
                        ProblemViewModel(
                            problemNum: 4,
                            question: "this is a template question",
                            choices: ["c1", "c2", "c3", "c4"],
                            problemSet: []
                        )
                ) {
                    TopicCard(name: title, image: title, completed: 3)
//                    Text(title)
                }
            }.navigationDestination(for: ProblemViewModel.self) { problem in
                testview(
                    problemNum: problem.problemNum,
                    question: problem.question,
                    choices: problem.choices,
                    problemSet: problem.problemSet,
                    path: $path
                )
            }
        }
    }
    
    var test: some View {
        NavigationStack(path: $path) {
            VStack {
                ForEach((1...10).reversed(), id: \.self) { num in
                    NavigationLink(value: num) {
                        Text("I'm on page \(num)")
                    }
                }
                .navigationDestination(for: Int.self) { num in
//                    ProgressView(String(describing: num))
                    DisplayView(
                        number  : num,
                        path    : $path)
                }
            }
        }
    }
}

struct testview : View {
    var problemNum: Int
    var question: String
    var choices: [String]
    var problemSet: [ProblemData]
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            NavigationLink(value: 
                            ProblemViewModel(
                                problemNum: problemNum+1,
                                question: "this is a template question",
                                choices: ["c1", "c2", "c3", "c4"],
                                problemSet: problemSet
                            )
            ) {
                Text(question)
            }
                .navigationTitle("Number \(problemNum)")
                .toolbar {
                    Button("GO to root") {
                        path = NavigationPath()
                    }
                }
//            Text(String(problemNum))
            ForEach(choices, id: \.self) { choice in
                Text(choice)
            }
        }
    }
}

struct DisplayView: View {
    var number: Int
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationLink(value: number+1) {
            Text("go deeper")
        }
            .navigationTitle("Number \(number)")
            .toolbar {
                Button("GO to root") {
                    path = NavigationPath()
                }
            }
    }
}

#Preview {
    testnav()
}
