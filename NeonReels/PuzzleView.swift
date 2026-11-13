import SwiftUI
import UIKit

struct PuzzleView: View {
    let puzzle: Puzzle
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var router: GameRouter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var attempt = Attempt(state:[0,0,0])
    @State private var message = "Match the centre row to the target above."
    @State private var showResult = false
    @State private var didWin = false
    @State private var showRestart = false
    @State private var offsets = [CGFloat](repeating:0,count:3)
    #if DEBUG && targetEnvironment(simulator)
    @State private var capturePresented = false
    #endif
    var body: some View {
        ZStack {
            NeonBackground()
            ScrollView {
                VStack(spacing:20) {
                    HStack {
                        VStack(alignment:.leading,spacing:4) { Eyebrow(text:Puzzle.rooms[puzzle.room]); Text(puzzle.title).font(.system(.title,design:.rounded,weight:.heavy)) }
                        Spacer()
                        VStack(alignment:.trailing,spacing:4) { Text("\(store.data.completed)/120").font(.system(.title3,design:.rounded,weight:.bold)).monospacedDigit();Text("completed").font(.caption).foregroundStyle(Neon.muted) }
                    }
                    HStack(spacing:16) {
                        VStack(alignment:.leading,spacing:6) { Eyebrow(text:"Your target");Text("Centre row").font(.caption).foregroundStyle(Neon.muted) }
                        Spacer();TargetRow(state:puzzle.target,size:36)
                    }.panel(Neon.gold)
                    machine
                    HStack(spacing:12) {
                        Label("\(attempt.moves) / \(puzzle.limit) moves",systemImage:"arrow.triangle.2.circlepath").font(.system(.headline,design:.rounded)).monospacedDigit().accessibilityIdentifier("move-count")
                        Spacer()
                        Text("\(max(0,puzzle.limit-attempt.moves)) left").font(.subheadline).foregroundStyle(Neon.gold).monospacedDigit()
                    }
                    HStack(alignment:.center,spacing:16) {
                        Button { attempt.undo(); message = "Move undone. One move restored.";store.update(attempt,for:puzzle) } label: {
                            VStack(spacing:8) { Image(systemName:"arrow.uturn.backward").font(.title2);Text("Undo").font(.subheadline.bold()) }.frame(maxWidth:.infinity,minHeight:84)
                        }.disabled(attempt.history.isEmpty).opacity(attempt.history.isEmpty ? 0.4 : 1).accessibilityIdentifier("undo")
                        Button(action:check) {
                            VStack(spacing:6) { Image(systemName:"checkmark").font(.system(size:27,weight:.heavy));Text("CHECK").font(.system(size:13,weight:.heavy,design:.rounded)).tracking(2) }
                                .foregroundStyle(Neon.bg).frame(width:108,height:108)
                                .background(LinearGradient(colors:[Color(hex:0xFFF0C2),Neon.gold,Color(hex:0xB67E2E)],startPoint:.topLeading,endPoint:.bottomTrailing),in:Circle())
                                .overlay(Circle().stroke(Color(hex:0xFFEAB1),lineWidth:3).padding(5))
                                .shadow(color:Neon.gold.opacity(0.26),radius:14,y:3)
                        }.buttonStyle(.plain).accessibilityLabel("Check combination").accessibilityIdentifier("check")
                        Button(action:hint) {
                            VStack(spacing:8) { Image(systemName:"lightbulb").font(.title2);Text("Hint").font(.subheadline.bold()) }.frame(maxWidth:.infinity,minHeight:84)
                        }.accessibilityIdentifier("hint")
                    }.foregroundStyle(Neon.gold)
                    Text(message).font(.subheadline).foregroundStyle(Neon.text).multilineTextAlignment(.center).frame(maxWidth:.infinity,minHeight:44).accessibilityIdentifier("game-message")
                    VStack(alignment:.leading,spacing:8) {
                        Label(puzzle.room == 0 ? "Independent reels" : "Linked reels",systemImage:puzzle.room == 0 ? "hand.draw" : "link").font(.headline)
                        Text(puzzle.rule).font(.subheadline)
                        Text("Up brings the symbol below into the centre. Each arrow or swipe uses one move. Undo restores one move.").font(.footnote)
                    }.foregroundStyle(Neon.muted).frame(maxWidth:.infinity,alignment:.leading).panel()
                    if let error = store.error { Text(error).font(.footnote).foregroundStyle(Neon.gold) }
                }.page().padding(.top,12)
            }
        }.navigationTitle(puzzle.isDaily ? String(puzzle.id.dropFirst(6)) : "Make your move").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement:.topBarLeading) { Button("Close",systemImage:"xmark") { dismiss() }.labelStyle(.iconOnly).accessibilityIdentifier("close-game") }
            ToolbarItem(placement:.topBarTrailing) { Button("Restart",systemImage:"arrow.clockwise") { showRestart = true }.labelStyle(.iconOnly) }
        }.toolbarBackground(Neon.bg,for:.navigationBar)
        .confirmationDialog("Restart this puzzle?",isPresented:$showRestart,titleVisibility:.visible) { Button("Restart puzzle",role:.destructive) { restart() } } message: { Text("Your best result stays saved. This attempt returns to the fixed starting position.") }
        .onAppear {
            attempt = store.attempt(puzzle); store.update(attempt,for:puzzle)
            #if DEBUG && targetEnvironment(simulator)
            if !capturePresented {
                capturePresented = true
                if ScreenshotLaunch.key == "linked-reel-puzzle", puzzle.id == Puzzle.levels[40].id { hint() }
                if ScreenshotLaunch.key == "puzzle-result", puzzle.id == Puzzle.levels[0].id { check() }
            }
            #endif
        }
        .sheet(isPresented:$showResult) {
            ResultView(puzzle:puzzle,attempt:attempt,won:didWin,retry:{ showResult=false;restart() },close:{ showResult=false;dismiss() })
                .presentationDragIndicator(.visible)
        }
    }
    var machine: some View {
        HStack(spacing:8) {
            ForEach(0..<3) { reel in
                VStack(spacing:10) {
                    Text("0\(reel+1)").font(.system(size:12,weight:.heavy,design:.rounded)).tracking(2).foregroundStyle(Neon.gold)
                    ZStack {
                        LinearGradient(colors:[Color(hex:0x10091C),Color(hex:0x543366),Color(hex:0x10091C)],startPoint:.top,endPoint:.bottom)
                        VStack(spacing:12) {
                            SymbolArt(index:(attempt.state[reel]+4)%5,size:42).opacity(0.32)
                            SymbolArt(index:attempt.state[reel],size:60)
                            SymbolArt(index:(attempt.state[reel]+1)%5,size:42).opacity(0.32)
                        }.offset(y:offsets[reel])
                        VStack { Spacer();RoundedRectangle(cornerRadius:8).stroke(Neon.gold.opacity(0.9),lineWidth:1.5).frame(height:80).background(Neon.gold.opacity(0.06));Spacer() }
                    }.frame(height:210).clipShape(RoundedRectangle(cornerRadius:14))
                        .overlay(RoundedRectangle(cornerRadius:14).stroke(Neon.gold.opacity(0.3)))
                        .contentShape(Rectangle())
                        .highPriorityGesture(DragGesture(minimumDistance:12).onEnded { value in
                            if abs(value.translation.height)>abs(value.translation.width) { move(Turn(reel:reel,direction:value.translation.height < 0 ? 1 : -1)) }
                        })
                        .accessibilityElement(children:.ignore)
                        .accessibilityLabel("Reel \(reel+1), \(Puzzle.symbols[attempt.state[reel]])")
                        .accessibilityAdjustableAction { direction in move(Turn(reel:reel,direction:direction == .increment ? 1 : -1)) }
                        .accessibilityIdentifier("reel-\(reel)")
                    HStack(spacing:4) {
                        arrow(reel:reel,direction:1)
                        arrow(reel:reel,direction:-1)
                    }
                    if puzzle.room > 0 { Text(puzzle.room == 1 && reel == 2 ? "SOLO" : "LINK → \((reel+1)%3+1)").font(.system(size:10,weight:.heavy,design:.rounded)).foregroundStyle(Neon.muted) }
                }.frame(maxWidth:.infinity)
            }
        }.padding(12)
            .background(LinearGradient(colors:[Color(hex:0x80522B),Color(hex:0x2A143E),Color(hex:0x62362D)],startPoint:.topLeading,endPoint:.bottomTrailing),in:RoundedRectangle(cornerRadius:26))
            .overlay(RoundedRectangle(cornerRadius:26).stroke(LinearGradient(colors:[Color(hex:0xFFEABB),Neon.gold.opacity(0.45),Neon.gold],startPoint:.topLeading,endPoint:.bottomTrailing),lineWidth:2))
            .shadow(color:Neon.purple.opacity(0.3),radius:22,y:8)
            .environment(\.layoutDirection,.leftToRight)
    }
    func arrow(reel:Int,direction:Int) -> some View {
        Button { move(Turn(reel:reel,direction:direction)) } label: {
            Image(systemName:direction == 1 ? "chevron.up" : "chevron.down").font(.system(size:16,weight:.heavy)).frame(maxWidth:.infinity,minHeight:44)
                .background(Neon.purple.opacity(0.3),in:RoundedRectangle(cornerRadius:10))
        }.buttonStyle(.plain).foregroundStyle(Neon.text).disabled(attempt.moves >= puzzle.limit)
            .opacity(attempt.moves >= puzzle.limit ? 0.4 : 1)
            .accessibilityLabel("Reel \(reel+1) \(direction == 1 ? "up" : "down")")
            .accessibilityIdentifier("reel-\(reel)-\(direction == 1 ? "up" : "down")")
    }
    func move(_ turn:Turn) {
        guard attempt.moves < puzzle.limit else { message = "Move limit reached. Check the row, undo a move or restart.";return }
        attempt.turn(turn,puzzle:puzzle)
        store.update(attempt,for:puzzle)
        if store.data.haptics { UIImpactFeedbackGenerator(style:.soft).impactOccurred() }
        if !reduceMotion && !store.data.reducedMotion {
            for i in Engine.affected(turn.reel,room:puzzle.room) { offsets[i] = CGFloat(turn.direction)*12 }
            withAnimation(.easeOut(duration:0.18)) { offsets = [0,0,0] }
        }
        message = attempt.moves == puzzle.limit ? "Move limit reached. Check your row or undo a move." : "\(turn.label). \(puzzle.limit-attempt.moves) \(puzzle.limit-attempt.moves == 1 ? "move" : "moves") remaining."
    }
    func check() {
        if attempt.state == puzzle.target {
            didWin = true;store.complete(puzzle,attempt:attempt);showResult = true
        } else if attempt.moves >= puzzle.limit { didWin=false;showResult=true }
        else { message = "Not matched yet. Compare the centre row with your target, or ask for a hint." }
    }
    func hint() {
        let path = Engine.solve(attempt.state,target:puzzle.target,room:puzzle.room)!
        guard let next = path.first else { message = "The target is matched. Tap Check to finish.";return }
        let linked = Engine.affected(next.reel,room:puzzle.room)
        let explanation = linked.count > 1 ? " This also moves reel \(linked[1]+1)." : " Only this reel moves."
        message = "Next: \(next.label).\(explanation) Shortest path: \(path.count) \(path.count == 1 ? "move" : "moves")." + (path.count > puzzle.limit-attempt.moves ? " Undo or restart to stay within the limit." : "")
    }
    func restart() { attempt=Attempt(state:puzzle.start);store.update(attempt,for:puzzle);message="A fresh start. The target and starting row are unchanged." }
}

struct ResultView: View {
    let puzzle: Puzzle
    let attempt: Attempt
    let won: Bool
    let retry: () -> Void
    let close: () -> Void
    @EnvironmentObject private var store: GameStore
    var body: some View {
        ZStack {
            NeonBackground()
            ScrollView {
                VStack(spacing:24) {
                    Eyebrow(text:won ? "Beautifully aligned" : "A new angle awaits")
                    Text(won ? "Brilliant move." : "Try a fresh approach.").font(.system(size:34,weight:.heavy,design:.rounded)).multilineTextAlignment(.center).accessibilityIdentifier("result-title")
                    if won { Stars(count:Engine.stars(moves:attempt.moves,optimum:puzzle.optimal.count)).scaleEffect(2).padding(8) }
                    TargetRow(state:attempt.state,size:64).padding(24).panel(Neon.gold)
                    HStack(spacing:32) {
                        metric("Your moves",value:"\(attempt.moves)")
                        metric("Optimal",value:"\(puzzle.optimal.count)")
                        metric("Best",value:store.data.records[puzzle.id].map { String($0.moves) } ?? "—")
                    }
                    VStack(alignment:.leading,spacing:12) {
                        Text("The shortest route").font(.title2.bold())
                        Text("From the original starting row. Each step uses one move; linked reels move together.").font(.subheadline).foregroundStyle(Neon.muted)
                        ForEach(Array(puzzle.optimal.enumerated()),id:\.offset) { step in
                            HStack(alignment:.top,spacing:12) {
                                Text("\(step.offset+1)").font(.headline).foregroundStyle(Neon.gold).frame(width:24)
                                VStack(alignment:.leading,spacing:3) { Text(step.element.label).font(.headline);Text(Engine.affected(step.element.reel,room:puzzle.room).count == 1 ? "Turns independently" : "Also turns reel \((step.element.reel+1)%3+1)").font(.caption).foregroundStyle(Neon.muted) }
                                Spacer()
                            }
                        }
                        Divider()
                        Text("3 stars: \(puzzle.optimal.count) \(puzzle.optimal.count == 1 ? "move" : "moves") · 2 stars: \(puzzle.optimal.count+1) · 1 star: within \(puzzle.limit). Undo restores a move; hints do not affect your rating.").font(.footnote).foregroundStyle(Neon.muted)
                    }.frame(maxWidth:.infinity,alignment:.leading).panel()
                    Button(won ? "Play again" : "Retry puzzle",action:retry).buttonStyle(NeonButton()).accessibilityIdentifier("retry-result")
                    Button(puzzle.isDaily ? "Back to daily" : "Back to the hall",action:close).buttonStyle(NeonButton(secondary:true)).accessibilityIdentifier("result-close")
                }.page().padding(.top,36)
            }
        }
    }
    func metric(_ title:String,value:String) -> some View {
        VStack(spacing:5) { Text(value).font(.system(size:32,weight:.bold,design:.rounded)).monospacedDigit().foregroundStyle(Neon.gold);Text(title).font(.caption).foregroundStyle(Neon.muted) }
    }
}
