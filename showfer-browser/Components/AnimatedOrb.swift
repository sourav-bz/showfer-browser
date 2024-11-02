import SwiftUI

struct PetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height
            
            path.move(to: .zero)
            path.addCurve(
                to: CGPoint(x: width * 0.549, y: height * 0.705),
                control1: CGPoint(x: width * 0.199, y: height * 0.023),
                control2: CGPoint(x: width * 0.592, y: height * 0.355)
            )
            path.addCurve(
                to: CGPoint(x: width * -0.121, y: height * 0.981),
                control1: CGPoint(x: width * 0.506, y: height * 1.054),
                control2: CGPoint(x: width * 0.078, y: height * 1.004)
            )
            path.addCurve(
                to: CGPoint(x: width * -0.439, y: height * 0.591),
                control1: CGPoint(x: width * -0.320, y: height * 0.958),
                control2: CGPoint(x: width * -0.482, y: height * 0.940)
            )
            path.addCurve(
                to: .zero,
                control1: CGPoint(x: width * -0.396, y: height * 0.241),
                control2: CGPoint(x: width * -0.199, y: height * -0.023)
            )
            path.closeSubpath()
        }
    }
}

struct AnimatedOrb: View {
    let width: CGFloat
    let height: CGFloat
    let primaryColor: Color
    
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Base circle with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            primaryColor.opacity(0.05),
                            primaryColor.opacity(0.15),
                            primaryColor.opacity(0.25),
                            primaryColor.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: min(width, height) * 0.5
                    )
                )
                .frame(width: width, height: height)
            
            // Overlay white circle with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.white.opacity(0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: min(width, height) * 0.3
                    )
                )
                .frame(width: width * 0.8, height: height * 0.8)
            
            // Three rotating petals
            GeometryReader { geometry in
                ZStack {
                    // First petal (0 degrees offset)
                    PetalShape()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: primaryColor, location: 0),
                                    .init(color: primaryColor.opacity(0), location: 1)
                                ]),
                                startPoint: UnitPoint(x: 0, y: 0),
                                endPoint: UnitPoint(x: 1, y: 1)
                            )
                        )
                        .frame(width: width * 0.4   , height: height * 0.4)
                        .position(x: geometry.size.width / 2 + 3, y: geometry.size.height / 2)
                        .rotationEffect(.degrees(rotation))
                    
                    // Second petal (120 degrees offset)
                    PetalShape()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: primaryColor, location: 0),
                                    .init(color: primaryColor.opacity(0), location: 1)
                                ]),
                                startPoint: UnitPoint(x: 0, y: 0),
                                endPoint: UnitPoint(x: 1, y: 1)
                            )
                        )
                        .frame(width: width * 0.4, height: height * 0.4)
                        .position(x: geometry.size.width / 2 + 3, y: geometry.size.height / 2)
                        .rotationEffect(.degrees(rotation + 120))
                    
                    // Third petal (240 degrees offset)
                    PetalShape()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: primaryColor, location: 0),
                                    .init(color: primaryColor.opacity(0), location: 1)
                                ]),
                                startPoint: UnitPoint(x: 0, y: 0),
                                endPoint: UnitPoint(x: 1, y: 1)
                            )
                        )
                        .frame(width: width * 0.4, height: height * 0.4)
                        .position(x: geometry.size.width / 2 + 3, y: geometry.size.height / 2)
                        .rotationEffect(.degrees(rotation + 240))
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}

// Preview provider for SwiftUI canvas
struct AnimatedOrb_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedOrb(
            width: 200,
            height: 200,
            primaryColor: .blue
        )
        .preferredColorScheme(.dark)
    }
}