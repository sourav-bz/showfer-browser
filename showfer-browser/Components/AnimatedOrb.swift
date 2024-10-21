import SwiftUI

struct AnimatedOrb: View {
    let width: CGFloat
    let height: CGFloat
    let primaryColor: Color
    
    @State private var rotationAngle: Double = 0
    @State private var scale1: CGFloat = 1.0
    @State private var scale2: CGFloat = 1.0
    @State private var scale3: CGFloat = 1.0
    @State private var offset1: CGSize = .zero
    @State private var offset2: CGSize = .zero
    @State private var offset3: CGSize = .zero
    
    init(width: CGFloat = 500, height: CGFloat = 500, primaryColor: Color = .yellow) {
        self.width = width
        self.height = height
        self.primaryColor = primaryColor
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(.white)
                .frame(width: width, height: height)
                .shadow(color: primaryColor.opacity(0.5), radius: 50, x: 0, y: 0)
            
            // Animated shapes
            ZStack {
                OrbShape()
                    .fill(LinearGradient(gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: width * 0.5, height: height * 0.5)
                    .offset(offset1)
                    .scaleEffect(scale1)
                    .rotationEffect(.degrees(160))
                
                OrbShape()
                    .fill(LinearGradient(gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: width * 0.5, height: height * 0.5)
                    .offset(offset2)
                    .scaleEffect(scale2)
                    .rotationEffect(.degrees(-160))
                
                OrbShape()
                    .fill(LinearGradient(gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: width * 0.5, height: height * 0.5)
                    .offset(offset3)
                    .scaleEffect(scale3)
                    .rotationEffect(.degrees(20))
            }
            .rotationEffect(.degrees(rotationAngle))
            .opacity(0.7)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            withAnimation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                scale1 = 1.1
                offset1 = CGSize(width: 20, height: 20)
            }
            
            withAnimation(Animation.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                scale2 = 0.9
                offset2 = CGSize(width: -20, height: 20)
            }
            
            withAnimation(Animation.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                scale3 = 1.05
                offset3 = CGSize(width: 20, height: -20)
            }
        }
    }
}

struct OrbShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.44617*width, y: 0.00164*height))
        path.addCurve(to: CGPoint(x: 0.99529*width, y: 0.70687*height), control1: CGPoint(x: 0.64529*width, y: 0.02465*height), control2: CGPoint(x: 1.03839*width, y: 0.35761*height))
        path.addCurve(to: CGPoint(x: 0.32538*width, y: 0.98338*height), control1: CGPoint(x: 0.95219*width, y: 1.05614*height), control2: CGPoint(x: 0.52449*width, y: 1.00639*height))
        path.addCurve(to: CGPoint(x: 0.00821*width, y: 0.59297*height), control1: CGPoint(x: 0.12626*width, y: 0.96037*height), control2: CGPoint(x: -0.03489*width, y: 0.94223*height))
        path.addCurve(to: CGPoint(x: 0.44617*width, y: 0.00164*height), control1: CGPoint(x: 0.05131*width, y: 0.2437*height), control2: CGPoint(x: 0.24704*width, y: -0.02137*height))
        path.closeSubpath()
        return path
    }
}

struct AnimatedOrb_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedOrb()
    }
}