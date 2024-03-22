import SwiftUI

struct HelperView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
   
}

struct LoadingButton: View {
    
    @Binding private var btnText      : String
    @Binding private var isPressed    : Bool      // handles initial animation from button to loading circle
    @Binding private var isAwaiting   : Bool      // initiates the rotating load-circle
    @Binding private var isLoading    : Bool      //
    
    @Binding private var doneLoading  : Bool      // signifies loading has finished
    @Binding private var backToBtn    : Bool      // triggers reset of button back to normal length and text
    
    let width       : CGFloat       // width of button + loading circle
    let height      : CGFloat       // height of button + loading circle
    let radius      : CGFloat       // corner radius of button + loading circle (needs to match with height)
    let animDuration: CGFloat       // duration of animation (between 0.0 - 1.0)
    let loadWidth   : CGFloat       // line width of loading circle's stroke (which rotates)
    let fontSize    : CGFloat       // font size of button text
    
    init(
        btnText     : Binding<String>,
        isPressed   : Binding<Bool>,
        isAwaiting  : Binding<Bool>,
        isLoading   : Binding<Bool>,
        doneLoading : Binding<Bool>,
        backToBtn   : Binding<Bool>,
        width       : CGFloat = UIScreen.main.bounds.width - 120,
        height      : CGFloat = 50,
        radius      : CGFloat = 50,
        fontSize    : CGFloat = 20,
        animDuration: CGFloat = 0.5,
        loadWidth   : CGFloat = 6
    ) {
        self._btnText = btnText
        self._isPressed = isPressed
        self._isAwaiting = isAwaiting
        self._isLoading = isLoading
        self._doneLoading = doneLoading
        self._backToBtn = backToBtn
        self.width = width
        self.height = height
        self.radius = radius
        self.fontSize = fontSize
        self.animDuration = animDuration
        self.loadWidth = loadWidth
    }
    
    
    var body: some View {
        ZStack {
            Text(btnText)
                .font(.system(size: 20, weight: .bold))
                .padding(.vertical)
                .foregroundColor(.textTint)
                .fontWeight(.bold)
                .frame(width: isPressed ? height : width, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(.black, lineWidth: 8)
                )
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(.systemBlue), Color(.systemTeal), Color(.systemMint)]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                ).cornerRadius(radius)
                .shadow(radius: 25)
                .onTapGesture {
                    withAnimation(Animation.linear(duration: animDuration)) {
                        isPressed = true
                        btnText = btnText == "" ? btnText : ""
                    }
                }
            
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .foregroundStyle(.white)
                .frame(width: width-10, height: width-10, alignment: .center)
                .opacity(doneLoading ? 1 : 0)
                .padding()
            
            if isPressed {
                Group {
                    Circle()
                        .trim(from: 0, to: isAwaiting ? 0.3 : 0)
                        .stroke(.white, lineWidth: loadWidth)
                        .frame(width: width-10, height: width-10)
                        .onAppear() {
                            withAnimation(Animation.linear(duration: animDuration).delay(animDuration)) {
                                isAwaiting = true
                            }
                        }
                }.rotationEffect(.degrees(isLoading ? 360 : 0), anchor: .center)
                    .onAppear() {
                        withAnimation(Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                            .delay(animDuration)) {
                                self.isLoading = true
                            }
                    }
            }
            
        }.onTapGesture {
            isPressed = true
        }
        
        /*
         DUMMY BUTTONS - used to test stopping conditions
         
        HStack {
            Spacer()
            Button(action: {
                withAnimation(Animation.linear(duration: animDuration)) {
                    self.doneLoading = true
                    
                    self.isAwaiting = false          // remove loading circle
                    self.isLoading = false          // stop loading animation
                }
            }, label: {
                Text("press this to done")
                    .font(.system(size: 24))
            }).padding(.trailing, 24)
        }
        
        HStack {
            Spacer()
            Button(action: {
                withAnimation(Animation.linear(duration: 0.3)) {
                    self.doneLoading = false
                    self.isPressed = false
                    self.btnText = "RESET"
                }
            }, label: {
                Text("press this to revert back")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }).padding(.trailing, 24)
        }
         */
        
        
    }
    
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            ZStack {
                Text(text).font(.system(size: 36))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x: width, y: width)
                Text(text).font(.system(size: 36))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x: -width, y: -width)
                Text(text).font(.system(size: 36))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x: -width, y: width)
                Text(text).font(.system(size: 36))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x: width, y: -width)
            }
            .foregroundColor(color)
            Text(text).font(.system(size: 36))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    HelperView()
//    StrokeText(text: "test", width: 0.5, color: Color(.systemTeal))
}
