import SwiftUI

struct DailyView: View {
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var router: GameRouter
    @Environment(\.scenePhase) private var phase
    @State private var day = Puzzle.dayKey()
    var puzzle: Puzzle { Puzzle.daily(day) }
    var history: [String] { store.data.records.keys.filter { $0.hasPrefix("daily-") }.sorted(by:>) }
    var body: some View {
        ZStack {
            NeonBackground()
            ScrollView {
                VStack(alignment:.leading,spacing:24) {
                    Eyebrow(text:"The daily ritual")
                    Text("One day.\nOne bright puzzle.").font(.system(size:36,weight:.heavy,design:.rounded))
                    VStack(spacing:20) {
                        HStack { Label(day,systemImage:"calendar").font(.headline).monospacedDigit();Spacer();Text("UTC").font(.caption).foregroundStyle(Neon.muted) }
                        SymbolArt(index:4,size:100).padding(12)
                        TargetRow(state:puzzle.target,size:36)
                        Text("\(puzzle.limit) moves · \(Puzzle.rooms[puzzle.room])").font(.subheadline).foregroundStyle(Neon.muted)
                        if let record = store.data.records[puzzle.id] { Stars(count:record.stars);Text("Best: \(record.moves) \(record.moves == 1 ? "move" : "moves")").font(.headline).foregroundStyle(Neon.gold) }
                        Button(store.data.records[puzzle.id] == nil ? "Play today's puzzle" : "Replay today's puzzle") { router.puzzle=puzzle }.buttonStyle(NeonButton()).accessibilityIdentifier("play-daily")
                    }.panel(Neon.roomColors[2])
                    Label("Available offline. The date sets the puzzle; its starting row and target always stay the same. A new puzzle arrives at 00:00 UTC.",systemImage:"clock").font(.subheadline).foregroundStyle(Neon.muted)
                    Text("Your daily history").font(.system(.title2,design:.rounded,weight:.bold))
                    if history.isEmpty {
                        VStack(alignment:.leading,spacing:10) { Image(systemName:"calendar.badge.checkmark").font(.title).foregroundStyle(Neon.gold);Text("Your first day starts here").font(.headline);Text("Complete a daily puzzle to begin your history.").font(.subheadline).foregroundStyle(Neon.muted) }.frame(maxWidth:.infinity,alignment:.leading).panel()
                    } else {
                        ForEach(history,id:\.self) { key in
                            Button { router.puzzle=Puzzle.daily(String(key.dropFirst(6))) } label: {
                                HStack { VStack(alignment:.leading,spacing:8) { Text(String(key.dropFirst(6))).font(.headline);Text("\(store.data.records[key]!.moves) \(store.data.records[key]!.moves == 1 ? "move" : "moves") · Tap to replay").font(.caption).foregroundStyle(Neon.muted) };Spacer();Stars(count:store.data.records[key]!.stars) }.panel()
                            }.buttonStyle(.plain)
                        }
                    }
                }.page().padding(.top,16)
            }
        }.navigationTitle("Daily").navigationBarTitleDisplayMode(.inline)
            .onChange(of:phase) { _, new in if new == .active { day=Puzzle.dayKey() } }
            .task { while !Task.isCancelled { try? await Task.sleep(for:.seconds(30)); day=Puzzle.dayKey() } }
    }
}
struct AlbumView: View {
    @EnvironmentObject private var store: GameStore
    @State private var selected: Int?
    #if DEBUG && targetEnvironment(simulator)
    @State private var capturePresented = false
    #endif
    private let requirements = [0,1,5,15,30]
    private let descriptions = ["The original bright spark. A pair of ruby cherries, always ready for a fresh start.","A golden reminder that the shortest route begins with one thoughtful move.","A little celebration of a plan coming together, one turn at a time.","The energy of connected reels. See the link, then make it work for you.","Clarity under pressure. A cool blue gem for a growing collection of clever solutions."]
    var body: some View {
        ZStack {
            NeonBackground()
            ScrollView {
                VStack(alignment:.leading,spacing:24) {
                    Eyebrow(text:"Small icons. Bright milestones.")
                    Text("The symbol album").font(.system(size:34,weight:.heavy,design:.rounded))
                    Text("\((0..<5).filter { store.unlocked($0) }.count) of 5 collected").font(.headline).foregroundStyle(Neon.gold)
                    Text("Your collection grows as you complete different levels. Every symbol is available on the reels from the start.").font(.subheadline).foregroundStyle(Neon.muted)
                    LazyVGrid(columns:[GridItem(.adaptive(minimum:150),spacing:16)],spacing:16) {
                        ForEach(0..<5) { i in
                            Button { selected=i } label: {
                                VStack(spacing:16) {
                                    SymbolArt(index:i,size:82).saturation(store.unlocked(i) ? 1 : 0.1).opacity(store.unlocked(i) ? 1 : 0.45).padding(.top,12)
                                    Text(Puzzle.symbols[i]).font(.system(.title3,design:.rounded,weight:.bold))
                                    Label(store.unlocked(i) ? "Collected" : "\(requirements[i]) \(requirements[i] == 1 ? "level" : "levels")",systemImage:store.unlocked(i) ? "checkmark.seal.fill" : "lock.fill").font(.caption).foregroundStyle(store.unlocked(i) ? Neon.gold : Neon.muted)
                                }.frame(maxWidth:.infinity).frame(minHeight:180).panel(i == 0 ? Neon.pink : Neon.purple)
                            }.buttonStyle(.plain).accessibilityIdentifier("album-\(i)")
                        }
                    }
                }.page().padding(.top,16)
            }
        }.navigationTitle("Album").navigationBarTitleDisplayMode(.inline)
            #if DEBUG && targetEnvironment(simulator)
            .onAppear {
                if !capturePresented, ScreenshotLaunch.key == "symbol-detail" {
                    capturePresented = true
                    selected = 1
                }
            }
            #endif
            .sheet(item:Binding(get:{ selected.map { SymbolSelection(id:$0) } },set:{ selected=$0?.id })) { selection in
                let i=selection.id
                ZStack {
                    NeonBackground()
                    VStack(spacing:24) {
                        Eyebrow(text:store.unlocked(i) ? "In your collection" : "A milestone ahead")
                        SymbolArt(index:i,size:170)
                        Text(Puzzle.symbols[i]).font(.system(size:36,weight:.heavy,design:.rounded))
                        Text(descriptions[i]).font(.body).foregroundStyle(Neon.muted).multilineTextAlignment(.center)
                        if !store.unlocked(i) { Text("Complete \(requirements[i]) \(requirements[i] == 1 ? "level" : "different levels") to collect.\nYour progress: \(store.data.completed)/\(requirements[i]).").font(.headline).foregroundStyle(Neon.gold).multilineTextAlignment(.center) }
                        Button("Back to album") { selected=nil }.buttonStyle(NeonButton(secondary:true))
                    }.padding(32).frame(maxWidth:550)
                }.presentationDetents([.large]).presentationDragIndicator(.visible)
            }
    }
}
private struct SymbolSelection: Identifiable { let id:Int }
struct SettingsView: View {
    @EnvironmentObject private var store: GameStore
    @State private var reset = false
    var body: some View {
        ZStack {
            NeonBackground()
            ScrollView {
                VStack(alignment:.leading,spacing:24) {
                    Text("Make it your rhythm.").font(.system(size:34,weight:.heavy,design:.rounded))
                    VStack(spacing:20) {
                        Toggle("Haptic feedback",isOn:$store.data.haptics).onChange(of:store.data.haptics) { _,_ in store.save() }
                        Divider()
                        Toggle("Reduce animation",isOn:$store.data.reducedMotion).onChange(of:store.data.reducedMotion) { _,_ in store.save() }
                        Text("Your device's Reduce Motion setting is always respected.").font(.footnote).foregroundStyle(Neon.muted)
                    }.tint(Neon.purple).panel()
                    VStack(alignment:.leading,spacing:12) {
                        Label("On this device",systemImage:"internaldrive").font(.headline)
                        Text("Every move, best result and collected symbol is saved automatically. Neon Reels works entirely offline.").font(.subheadline).foregroundStyle(Neon.muted)
                        if let error=store.error { Text(error).font(.subheadline).foregroundStyle(Neon.gold);Button("Retry save") { store.retry() }.buttonStyle(NeonButton()) }
                        Text("Levels complete: \(store.data.completed) · Stars earned: \(store.data.records.values.reduce(0) { $0+$1.stars })").font(.subheadline).monospacedDigit()
                    }.panel()
                    VStack(alignment:.leading,spacing:12) {
                        Text("How to play").font(.title2.bold())
                        Text("1. Look at the target row.\n2. Swipe a reel or tap its arrows to move one step.\n3. Tap Check when the centre row matches.").font(.body).lineSpacing(6)
                        Text("Undo refunds one move. Restart gives you the same puzzle and a fresh move limit. Hints explain the next move on the shortest path and do not affect your stars.").font(.subheadline).foregroundStyle(Neon.muted)
                        Text("The daily puzzle changes at midnight UTC. Its history stays on this device. No account or connection is needed.").font(.subheadline).foregroundStyle(Neon.muted)
                    }.panel()
                    Button("Reset local progress",role:.destructive) { reset=true }.frame(minHeight:44).foregroundStyle(Neon.pink)
                    Text("NEON REELS  /  1.0\nDesigned for a brighter train of thought.").font(.caption).foregroundStyle(Neon.muted).lineSpacing(6)
                }.page().padding(.top,16)
            }
        }.navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Reset all local progress?",isPresented:$reset,titleVisibility:.visible) { Button("Reset progress",role:.destructive) { store.reset() } } message: { Text("This clears attempts, best results, daily history and collection milestones. A backup of the previous save is kept on this device.") }
    }
}
