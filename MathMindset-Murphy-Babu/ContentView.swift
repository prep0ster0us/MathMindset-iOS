//
//  ContentView.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 1/30/24.
//

import SwiftUI

//class AppVariables: ObservableObject {
//    var screenWidth: CGFloat {
//        return UIScreen.main.bounds.width
//    }
//
//    var screenHeight: CGFloat {
//        return UIScreen.main.bounds.height
//    }
//}

//class AppVariables: ObservableObject {
//    var screenWidth: Int = Int(UIScreen.main.bounds.width)
//
//    var screenHeight: Int = Int(UIScreen.main.bounds.height)
//}

struct ContentView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
