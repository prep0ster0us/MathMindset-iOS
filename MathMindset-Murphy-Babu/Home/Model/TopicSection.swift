//
//  TopicSection.swift
//  MathMindset-Murphy-Babu
//
//  Created by Ritwik on 5/1/24.
//

import SwiftUI

struct TopicSection: View {
    @State var currentPage : Int? = 0
    
    var body: some View {
        VStack (alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack  {
                    ForEach(0..<5) { index in
                        Text("Card \(index + 1)")
                            .font(.headline)
                            .frame(width: 200, height: 200)
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 10, x: 5, y: 10)
                            .padding(.leading, 12)
//                            .padding(.trailing, -12)
                            .scrollTransition(topLeading: .interactive,
                                              bottomTrailing: .interactive,
                                              axis: .horizontal) { effect, phase in
                                effect
                                    .scaleEffect(1-(abs(phase.value)))
                                    .opacity(1-(abs(phase.value)))
                                    .rotation3DEffect(.degrees(phase.value * -90), axis: (x: 0, y: 1, z: 0))
                            }
                                              .containerRelativeFrame(.horizontal, count: 2, spacing: -42)
                        // fill frame as single page
                    }
                }
                .scrollTargetLayout()  // ends frame at the border on scroll
            }
            .contentMargins(24, for: .scrollContent)
            .frame(height: 200)
//            .safeAreaPadding(.horizontal, 12)     // for device border
            .scrollClipDisabled()       // for shadows which spill out
            .scrollTargetBehavior(.viewAligned)  // snap frame-by-frame
            .scrollPosition(id: $currentPage)
            
            HStack(spacing: 10) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.horizontal, 20)
        }
//        .onChange(of: currentPage) { _, newValue in
//            // Update the active dot indicator
////            currentPage = newValue
//        }
    }
}

#Preview {
    TopicSection()
}
