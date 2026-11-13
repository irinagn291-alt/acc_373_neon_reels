import SwiftUI

enum Neon {
    static let bg = Color(hex: 0x160B28)
    static let panel = Color(hex: 0x281343)
    static let purple = Color(hex: 0x914BFF)
    static let pink = Color(hex: 0xFF4FC8)
    static let gold = Color(hex: 0xF5C867)
    static let text = Color(hex: 0xFFF8FF)
    static let muted = Color(hex: 0xBBA8D1)
    static let roomColors = [pink, purple, Color(hex: 0x6DE9EE)]
}
extension Color {
    init(hex: UInt32) { self.init(red: Double((hex >> 16) & 255)/255, green: Double((hex >> 8) & 255)/255, blue: Double(hex & 255)/255) }
}
struct NeonBackground: View {
    var body: some View {
        ZStack {
            Neon.bg
            RadialGradient(colors: [Neon.purple.opacity(0.23), .clear], center: .topTrailing, startRadius: 0, endRadius: 500)
            Canvas { context, size in
                for i in 0..<45 {
                    let x = CGFloat((i * 73 + 19) % 397) / 397 * size.width
                    let y = CGFloat((i * 149 + 11) % 809) / 809 * size.height
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: i % 3 == 0 ? 2 : 1, height: i % 3 == 0 ? 2 : 1)), with: .color(Neon.gold.opacity(0.22)))
                }
            }.accessibilityHidden(true)
        }.ignoresSafeArea()
    }
}
struct Panel: ViewModifier {
    var colour: Color = Neon.purple
    func body(content: Content) -> some View {
        content.padding(16)
            .background(LinearGradient(colors: [colour.opacity(0.13), Neon.panel], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(colour.opacity(0.28), lineWidth: 1))
    }
}
extension View {
    func panel(_ colour: Color = Neon.purple) -> some View { modifier(Panel(colour: colour)) }
    func page() -> some View {
        self.frame(maxWidth: 680).padding(.horizontal, 16).padding(.bottom, 24).frame(maxWidth: .infinity)
    }
}
struct NeonButton: ButtonStyle {
    var secondary = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.body, design: .rounded, weight: .bold)).foregroundStyle(secondary ? Neon.text : Neon.bg)
            .padding(.horizontal, 20).frame(minHeight: 52).frame(maxWidth: .infinity)
            .background(secondary ? AnyShapeStyle(Neon.purple.opacity(0.22)) : AnyShapeStyle(LinearGradient(colors: [Color(hex: 0xFFE6A6), Neon.gold], startPoint: .top, endPoint: .bottom)), in: RoundedRectangle(cornerRadius: 17))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}
struct Eyebrow: View {
    let text: String
    var body: some View { Text(text.uppercased()).font(.system(size: 12, weight: .heavy, design: .rounded)).tracking(2).foregroundStyle(Neon.gold) }
}
struct Stars: View {
    let count: Int
    var body: some View {
        HStack(spacing: 4) { ForEach(0..<3) { i in Image(systemName: i < count ? "star.fill" : "star").foregroundStyle(i < count ? Neon.gold : Neon.muted.opacity(0.5)) } }
            .font(.system(size: 12, weight: .bold)).accessibilityElement(children: .ignore).accessibilityLabel("\(count) of 3 stars")
    }
}
struct GemShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path(); let pts: [CGPoint] = [.init(x: 0.22,y: 0.12),.init(x: 0.78,y: 0.12),.init(x: 1,y: 0.4),.init(x: 0.5,y: 0.96),.init(x: 0,y: 0.4)]
        p.addLines(pts.map { CGPoint(x: r.minX + $0.x*r.width,y: r.minY + $0.y*r.height) });p.closeSubpath();return p
    }
}
struct SymbolArt: View {
    let index: Int
    var size: CGFloat = 64
    var body: some View {
        ZStack {
            if index == 0 { cherry }
            else if index == 4 { diamond }
            else {
                let name = ["", "star.fill", "bell.fill", "bolt.fill"][index]
                let colour = index == 3 ? Neon.purple : Neon.gold
                Image(systemName: name).resizable().scaledToFit()
                    .foregroundStyle(LinearGradient(colors: [.white, colour, index == 3 ? Color(hex: 0x43149C) : Color(hex: 0xA75B12)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: colour.opacity(0.5), radius: 8, y: 3)
                    .overlay(alignment: .topLeading) { Image(systemName: name).resizable().scaledToFit().foregroundStyle(.white.opacity(0.19)).scaleEffect(0.77).offset(x: -2, y: -3) }
            }
        }.frame(width: size, height: size).accessibilityLabel(Puzzle.symbols[index])
    }
    var cherry: some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: size*0.27,y: size*0.57));p.addQuadCurve(to: CGPoint(x: size*0.62,y: size*0.12), control: CGPoint(x:size*0.46,y:size*0.32))
                p.move(to: CGPoint(x: size*0.75,y: size*0.60));p.addQuadCurve(to: CGPoint(x: size*0.62,y: size*0.12), control: CGPoint(x:size*0.76,y:size*0.28))
            }.stroke(LinearGradient(colors: [Color(hex: 0xBDFA88), Color(hex: 0x378D43)], startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: size*0.055,lineCap: .round))
            Ellipse().fill(LinearGradient(colors: [Color(hex: 0xD8FFB8), Color(hex: 0x43AE5D)], startPoint: .top, endPoint: .bottom)).frame(width:size*0.3,height:size*0.14).rotationEffect(.degrees(-20)).offset(x: -size*0.025,y: -size*0.32)
            berry.offset(x: -size*0.22,y: size*0.18)
            berry.offset(x: size*0.22,y: size*0.21)
        }
    }
    var berry: some View {
        Circle().fill(RadialGradient(colors: [Color(hex: 0xFF91AD), Color(hex: 0xFF326A), Color(hex: 0x970C43)], center: .topLeading, startRadius: 0, endRadius: size*0.5))
            .frame(width:size*0.48,height:size*0.48)
            .overlay(alignment: .topLeading) { Capsule().fill(.white.opacity(0.8)).frame(width: size*0.12,height:size*0.055).rotationEffect(.degrees(-40)).offset(x:size*0.08,y:size*0.08) }
            .shadow(color: Neon.pink.opacity(0.25), radius: 5, y: 4)
    }
    var diamond: some View {
        GemShape().fill(LinearGradient(colors: [.white, Color(hex: 0x89F6FF), Color(hex: 0x348BAA)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Path { p in
                    p.move(to: CGPoint(x:0,y:size*0.4));p.addLine(to: CGPoint(x:size,y:size*0.4))
                    p.move(to: CGPoint(x:size*0.22,y:size*0.12));p.addLine(to: CGPoint(x:size*0.5,y:size*0.96));p.addLine(to: CGPoint(x:size*0.78,y:size*0.12))
                    p.move(to: CGPoint(x:size*0.22,y:size*0.12));p.addLine(to: CGPoint(x:size*0.5,y:size*0.4));p.addLine(to: CGPoint(x:size*0.78,y:size*0.12))
                }.stroke(.white.opacity(0.65),lineWidth: 1.5)
            }.shadow(color: .cyan.opacity(0.35),radius:8,y:3)
    }
}
struct TargetRow: View {
    let state: [Int]
    var size: CGFloat = 34
    var body: some View {
        HStack(spacing: 16) { ForEach(0..<3) { i in SymbolArt(index: state[i],size: size) } }
            .environment(\.layoutDirection, .leftToRight)
            .accessibilityElement(children: .ignore).accessibilityLabel(state.map { Puzzle.symbols[$0] }.joined(separator: ", "))
    }
}
