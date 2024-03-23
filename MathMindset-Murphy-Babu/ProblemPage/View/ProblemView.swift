import SwiftUI

struct ProblemView: View {
    
    let problemNum  : CGFloat
    let question    : String
    let choices     : [String]
    
    @State private var isPressed: CGFloat = -1
    
    var body: some View {
        VStack {
            // Problem Number header
            Text("Problem \(Int(round(problemNum)))")
                .font(.system(size: 32))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .underline()
                .padding(.top, 20)
                .padding(.bottom, 24)
            
            // Progress Bar
            ProblemProgressBar2(progress: problemNum, color1: Color(.systemTeal), color2: Color(.systemGreen))
                .animation(.easeIn, value: 0.5)     // TODO: figure out load-in animation for bar
                .padding(.bottom, 16)
            
            
            // Problem Statement
            let problemStatement = question.split(whereSeparator: \.isNewline)
            
            Text(problemStatement[0])
                .font(.title2)
                .fontWeight(.semibold)
                .shadow(radius: 20)
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .animation(.easeIn, value: 0.8)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(problemStatement[1])
                .font(.title)
                .fontWeight(.bold)
                .shadow(radius: 20)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 20, trailing: 16))
                .animation(.easeIn, value: 0.8)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            // Problem Choices
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
                ProblemOption(choices, $isPressed, 0)
                ProblemOption(choices, $isPressed, 1)
                ProblemOption(choices, $isPressed, 2)
                ProblemOption(choices, $isPressed, 3)
            }.padding(.horizontal, 40)
            
            Spacer()
            
            // Submit answer
            SubmitButton(isPressed, isPOTD: false)
                .padding()
        }.background(
            LinearGradient(colors: [Color(.systemTeal).opacity(0.4), Color(.systemBlue).opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundStyle(.ultraThinMaterial)
                .ignoresSafeArea()                  // to cover the entire screen
        )
    }
}

struct ProblemOption: View {
    let choices     : [String]
    let isPressed   : Binding<CGFloat>
    let choiceNum   : CGFloat
    
    init(
        _ choices   : [String],
        _ isPressed : Binding<CGFloat>,
        _ choiceNum : CGFloat
    ) {
        self.choices   = choices
        self.isPressed = isPressed
        self.choiceNum = choiceNum
    }
    
    // Horizontal buttons - For options which don't fit in the vertical view)
    var width: CGFloat = UIScreen.main.bounds.width-100
    var height: CGFloat = UIScreen.main.bounds.height/14
    
    //    var width: CGFloat = UIScreen.main.bounds.width/3
    //    var height: CGFloat = UIScreen.main.bounds.height/6
    var offset: CGFloat = 6
    
    let active  : Color = Color(.systemTeal)
    let inactive: Color = Color(.systemGray3)
    var color2: Color = Color(.bgTint)
    
    var body: some View {
        // OPTION-I - Rectangle with shadows
        VStack {
            Button(action: {
                isPressed.wrappedValue = choiceNum
            }, label: {
                Text(choices[Int(choiceNum)])
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(Color(.textTint))
                    .frame(width: width, height: height)
                    .overlay {
                        if (isPressed.wrappedValue == choiceNum) {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.bgContrast), lineWidth: 10)
                        }
                    }
                    .background(
                        ZStack {
                            Color(isPressed.wrappedValue == choiceNum ? active : inactive)
                                .opacity(0.4)
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                            //                            .stroke(Color(.black), lineWidth: 3)
                                .fill(color2)
                                .blur(radius: 4)
                                .offset(x: -4, y: -4)
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                            //                            .stroke(Color(.black), lineWidth: 3)
                                .fill(
                                    LinearGradient(colors: [
                                        (isPressed.wrappedValue == choiceNum ? active : inactive)
                                            .opacity(0.1), color2], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .padding(2)
                                .blur(radius: 2)
                        }
                    ).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color(.bgContrast).opacity(0.15), radius: 6, x: offset, y: offset)
                    .shadow(color: color2.opacity(0.3), radius: 12, x: -offset, y: -offset)
            }).buttonStyle(OptionButtonStyle())
        }
        
        // OPTION-II - Raised Button
        /*
         ZStack {
         RoundedRectangle(cornerRadius: 12)
         .fill(.black).opacity(0.2)
         .frame(width: width, height: height)
         .offset(x: offset, y: offset)
         Text(choice)
         .font(.title2)
         .foregroundStyle(Color(.textTint))
         .background(
         RoundedRectangle(cornerRadius: 12)
         .stroke(Color(.bgContrast), lineWidth: 3)
         .fill(.bgTint)
         .frame(width: width, height: height)
         .shadow(color: Color(.bgContrast).opacity(0.4), radius: 6, x: offset, y: offset)
         ).padding(0)
         }
         */
    }
}

// Default Button Press-down style
struct OptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .brightness(configuration.isPressed ? 0.05 : 0)
    }
}


struct SubmitButton: View {
    
    var isPressed: CGFloat
    var isPOTD   : Bool
    init(
        _ isPressed: CGFloat,
        isPOTD  : Bool
    ) {
        self.isPressed = isPressed
        self.isPOTD = isPOTD
    }
    
    @EnvironmentObject private var app: AppVariables
    
    @Environment(\.dismiss) var dismiss
    @State private var isCorrect = false
    @State private var showAlert = false
    
    var width: CGFloat = UIScreen.main.bounds.width-60
    var height: CGFloat = 58
    var radius: CGFloat = 24
    var offset: CGFloat = 6
    
    var color1: Color = Color(.systemTeal).opacity(0.6)
    var color2: Color = Color(.systemTeal)
    var color3: Color = Color(.systemBlue).opacity(0.5)
    var color4: Color = Color(.green).opacity(0.5)
    
    var body: some View {
        // Shadow Rectangle Button
        VStack {
            Button(action: {
                if isPressed == 0 {
                    isCorrect = true
                } else {
                    isCorrect = false
                }
                showAlert = true
            }, label: {
                Text("Check")
                    .font(.system(size: 24))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(Color(.textContrast))
                    .frame(width: width, height: height)
                    .background(
                        ZStack {
                            LinearGradient(colors: [color1, color2, color3, color4], startPoint: .topLeading, endPoint: .bottomTrailing)
                            RoundedRectangle(cornerRadius: radius, style: .continuous)
                            //                            .stroke(Color(.black), lineWidth: 3)
                                .fill(color1)
                                .blur(radius: 4)
                                .offset(x: -4, y: -4)
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                            //                            .stroke(Color(.black), lineWidth: 3)
                                .fill(LinearGradient(colors: [color2.opacity(0.1), color2], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .padding(2)
                                .blur(radius: 2)
                        }
                    ).clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                    .shadow(color: Color(.bgContrast).opacity(0.15), radius: 6, x: offset, y: offset)
                    .shadow(color: color1.opacity(0.1), radius: 12, x: -offset, y: -offset)
            }).buttonStyle(SubmitButtonStyle())
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Problem Submission"),
                          message: Text(isCorrect ? "Correct Answer!" : "Try Again!"),
                          dismissButton: .default(Text(isCorrect ? (isPOTD ? "Back to Home" : "Next Problem") : "Ok")) {
                        if isCorrect {
                            if isPOTD {
                                $app.streak.wrappedValue += 1
                                $app.primes.wrappedValue += 5
                                $app.probOfDaySolved.wrappedValue = true
                                dismiss()
                            } else {
                                // TODO: go to next question
                                
                            }
                        }
                        
                    })
                }
        }
        
        // OPTION-II - Raised Button
        /*
         ZStack {
         RoundedRectangle(cornerRadius: 12)
         .fill(.black).opacity(0.2)
         .frame(width: width, height: height)
         .offset(x: offset, y: offset)
         Text(choice)
         .font(.title2)
         .foregroundStyle(Color(.textTint))
         .background(
         RoundedRectangle(cornerRadius: 12)
         .stroke(Color(.bgContrast), lineWidth: 3)
         .fill(.bgTint)
         .frame(width: width, height: height)
         .shadow(color: Color(.bgContrast).opacity(0.4), radius: 6, x: offset, y: offset)
         ).padding(0)
         }
         */
    }
}

struct SubmitButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 1.08 : 1)
    }
}

struct ProblemProgressBar2: View {
    let progress: CGFloat
    let color1: Color
    let color2: Color
    
    var width: CGFloat = UIScreen.main.bounds.width-60
    var height: CGFloat = 32
    var radius: CGFloat = 24
    //    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            // base
            RoundedRectangle(cornerRadius: radius, style: .continuous)
            //                .stroke(Color(.bgContrast).opacity(0.7), lineWidth: 2)
            //                .fill(Color(.bgContrast).opacity(colorScheme == .dark ? 0.1 : 0.8))     // TODO: use this to adjust base background for light/dark mode
                .fill(Color(.bgContrast).opacity(0.15))
                .frame(width: width, height: height)
            
            // progress
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(LinearGradient(colors: [color1, color2],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: (progress/10)*width, height: height)
                .foregroundStyle(Color(.bgContrast).opacity(0.1))
        }
    }
}

struct ProblemProgressBar1: View {
    let progress: CGFloat
    let color1: Color
    let color2: Color
    
    var width: CGFloat = (UIScreen.main.bounds.width-60) / 10 // for each problem bar
    var height: CGFloat = 48
    var radius: CGFloat = 24
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            // base
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(Color(.bgContrast), lineWidth: 2)
                .frame(width: width*10+9, height: height)       // max frame = (width)*10 [for each problem] + 9 [width of vertical dividers]
                .foregroundStyle(Color(.bgContrast).opacity(0.1))
            
            HStack(spacing: 0) {
                // Problem 1
                if(progress > 0) {
                    Rectangle()
                        .fill(LinearGradient(colors: [color1, color2],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: width, height: height)
                        .padding(.trailing, radius)
                        .cornerRadius(radius)
                        .padding(.trailing, -radius)
                    Color(.black).frame(width: 1, height: height).padding(0)
                }
                // Problem 2
                let count = progress == 10 ? 8 : Int(round(progress))-1
                ForEach(0..<count, id: \.self) { index in
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(LinearGradient(colors: [color1, color2],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: width, height: height)
                        Color(.black).frame(width: 1, height: height)
                    }
                }
                
                // Problem 10
                if(progress == 10) {
                    Rectangle()
                        .fill(LinearGradient(colors: [color1, color2],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: width, height: height)
                        .padding(.leading, radius)
                        .cornerRadius(radius)
                        .padding(.leading, -radius)
                }
            }
        }
    }
}

#Preview {
    ProblemView(
        problemNum: 4,
        question: "Which of these shapes have 4 sides?\nImagine I drew a circle",
        choices: ["Triangle", "Circle", "Square", "Rectangle"]
    )
}

