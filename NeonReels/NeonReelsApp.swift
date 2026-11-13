import SwiftUI

#if DEBUG && targetEnvironment(simulator)
// Capture routes are opt-in and use the same views and navigation as normal play.
enum ScreenshotLaunch {
    static let keys = ["puzzle-hall", "room-levels", "linked-reel-puzzle", "puzzle-result", "daily-puzzle", "symbol-album", "symbol-detail", "basic-puzzle"]
    static let key: String? = {
        let process = ProcessInfo.processInfo
        let args = process.arguments
        func value(after flag: String) -> String? {
            guard let i = args.firstIndex(of: flag), args.indices.contains(i + 1) else { return nil }
            return args[i + 1]
        }
        if let review = value(after: "-ReviewScreen"), keys.contains(review) { return review }
        let environmentFlag = process.environment["APPSTORE_SCREENSHOTS"]?.lowercased()
        let enabled = args.contains("-AppStoreScreenshots") || (environmentFlag != nil && !["", "0", "false", "no"].contains(environmentFlag!))
        guard enabled,
              let rawIndex = value(after: "-AppStoreScreenshotScreen") ?? process.environment["APPSTORE_SCREENSHOT_SCREEN"],
              let index = Int(rawIndex), keys.indices.contains(index) else { return nil }
        return keys[index]
    }()
}
#endif

@MainActor final class GameRouter: ObservableObject {
    @Published var puzzle: Puzzle?
    #if DEBUG && targetEnvironment(simulator)
    @Published var captureTab = 0
    @Published var capturePath: [Int] = []
    init() {
        switch ScreenshotLaunch.key {
        case "room-levels": capturePath = [1]
        case "linked-reel-puzzle": capturePath = [1]; puzzle = Puzzle.levels[40]
        case "basic-puzzle", "puzzle-result": capturePath = [0]; puzzle = Puzzle.levels[0]
        case "daily-puzzle": captureTab = 1
        case "symbol-album", "symbol-detail": captureTab = 2
        default: break
        }
    }
    #endif
}
@main struct NeonReelsApp: App {
    @StateObject private var store: GameStore
    @StateObject private var router = GameRouter()
    init() {
        let store = GameStore()
        #if DEBUG && targetEnvironment(simulator)
        if let key = ScreenshotLaunch.key { store.prepareScreenshot(key) }
        #endif
        _store = StateObject(wrappedValue: store)
    }
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store).environmentObject(router)
                .preferredColorScheme(.dark).tint(Neon.gold)
                .environment(\.locale, Locale(identifier: "en_GB"))
        }
    }
}
struct RootView: View {
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var router: GameRouter
    var body: some View {
        Group {
            if store.loaded {
                #if DEBUG && targetEnvironment(simulator)
                if ScreenshotLaunch.key != nil {
                    TabView(selection: $router.captureTab) {
                        NavigationStack(path: $router.capturePath) { HallView() }.tabItem { Label("Play", systemImage: "square.grid.2x2.fill") }.tag(0)
                        NavigationStack { DailyView() }.tabItem { Label("Daily", systemImage: "calendar") }.tag(1)
                        NavigationStack { AlbumView() }.tabItem { Label("Album", systemImage: "sparkles.rectangle.stack.fill") }.tag(2)
                        NavigationStack { SettingsView() }.tabItem { Label("Settings", systemImage: "slider.horizontal.3") }.tag(3)
                    }.toolbarBackground(Neon.bg, for: .tabBar).toolbarBackground(.visible, for: .tabBar)
                } else {
                    normalTabs
                }
                #else
                normalTabs
                #endif
            } else {
                ZStack { NeonBackground(); ProgressView("Opening the puzzle hall…").tint(Neon.gold).foregroundStyle(Neon.text) }
            }
        }
        .foregroundStyle(Neon.text)
        #if DEBUG && targetEnvironment(simulator)
        .transaction { if ScreenshotLaunch.key != nil { $0.animation = nil; $0.disablesAnimations = true } }
        #endif
        .task {
            guard !store.loaded else { return }
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--uitest-reset") { store.reset() }
            #endif
            store.load()
        }
        .onOpenURL { url in
            guard WidgetIdentity.accepts(url) else { return }
            if !store.loaded { store.load() }
            guard store.error == nil else { return }

                #if DEBUG && targetEnvironment(simulator)
                store.applyWidgetQA(url)
                #endif
            router.puzzle = Puzzle.levels[min(119,max(0,store.data.lastLevel-1))]
        }
        .fullScreenCover(item: $router.puzzle) { p in NavigationStack { PuzzleView(puzzle: p) }.id(p.id) }
    }
    private var normalTabs: some View {
        TabView {
            NavigationStack { HallView() }.tabItem { Label("Play", systemImage: "square.grid.2x2.fill") }
            NavigationStack { DailyView() }.tabItem { Label("Daily", systemImage: "calendar") }
            NavigationStack { AlbumView() }.tabItem { Label("Album", systemImage: "sparkles.rectangle.stack.fill") }
            NavigationStack { SettingsView() }.tabItem { Label("Settings", systemImage: "slider.horizontal.3") }
        }.toolbarBackground(Neon.bg, for: .tabBar).toolbarBackground(.visible, for: .tabBar)
    }
}
struct HallView: View {
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var router: GameRouter
    var body: some View {
        ZStack {
            NeonBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        HStack(spacing: 5) { ForEach(0..<3) { _ in RoundedRectangle(cornerRadius: 3).fill(Neon.gold).frame(width: 5,height: 20) } }
                        Text("NEON REELS").font(.system(size: 15,weight: .black,design: .rounded)).tracking(3)
                        Spacer()
                        Label("Offline ready",systemImage: "checkmark.circle.fill").font(.system(size: 12,weight: .medium)).foregroundStyle(Neon.muted)
                    }.padding(.top, 16)
                    VStack(alignment: .leading, spacing: 8) {
                        Eyebrow(text: "A little logic. A lot of glow.")
                        Text("Your next\nbright idea.").font(.system(size: 40,weight: .heavy,design: .rounded)).tracking(-1)
                    }
                    hero
                    HStack {
                        VStack(alignment: .leading,spacing: 4) {
                            Text("The puzzle hall").font(.system(.title2,design: .rounded,weight: .bold))
                            Text("Three rooms. Every move is yours.").font(.subheadline).foregroundStyle(Neon.muted)
                        }
                        Spacer()
                        Text("\(store.data.completed)/120").font(.system(.headline,design: .rounded)).monospacedDigit().foregroundStyle(Neon.gold)
                    }
                    VStack(spacing: 12) { ForEach(0..<3) { room in
                        NavigationLink(value: room) { roomCard(room) }.buttonStyle(.plain).accessibilityIdentifier("room-\(room)")
                    } }
                    if let error = store.error { Label(error, systemImage: "exclamationmark.triangle").font(.subheadline).foregroundStyle(Neon.gold).panel() }
                    Text("Swipe a reel or tap an arrow. Match the target, then check your combination.").font(.subheadline).foregroundStyle(Neon.muted).padding(.horizontal, 8)
                }.page()
            }
        }.navigationBarHidden(true).navigationDestination(for: Int.self) { LevelsView(room: $0) }
    }
    var hero: some View {
        VStack(spacing: 18) {
            HStack {
                Eyebrow(text: "One move closer")
                Spacer()
                Image(systemName: "sparkle").foregroundStyle(Neon.gold)
            }
            HStack(spacing: 8) {
                ForEach([0,1,4],id: \.self) { symbol in
                    SymbolArt(index:symbol,size:70).frame(maxWidth:.infinity).frame(height:104)
                        .background(LinearGradient(colors:[Color(hex:0x4B2863),Neon.bg],startPoint:.top,endPoint:.bottom),in:RoundedRectangle(cornerRadius:16))
                        .overlay(RoundedRectangle(cornerRadius:16).stroke(Neon.gold.opacity(0.65)))
                }
            }.padding(8).background(Neon.gold.opacity(0.1),in:RoundedRectangle(cornerRadius:23))
            HStack {
                VStack(alignment:.leading,spacing:4) {
                    Text("\(Puzzle.rooms[(store.data.lastLevel-1)/40])").font(.headline)
                    Text("Level \(store.data.lastLevel) · \(Puzzle.levels[store.data.lastLevel-1].limit) moves").font(.subheadline).foregroundStyle(Neon.muted)
                }
                Spacer()
                Stars(count:store.data.records["level-\(store.data.lastLevel)"]?.stars ?? 0)
            }
            Button { router.puzzle = Puzzle.levels[store.data.lastLevel-1] } label: {
                HStack { Text(store.data.attempts.isEmpty ? "Play your first puzzle" : "Continue puzzle"); Image(systemName:"arrow.right") }
            }.buttonStyle(NeonButton()).accessibilityIdentifier("continue-puzzle")
        }.panel(Neon.gold)
    }
    func roomCard(_ room: Int) -> some View {
        HStack(spacing:16) {
            SymbolArt(index:[0,3,4][room],size:54).frame(width:64,height:72)
            VStack(alignment:.leading,spacing:7) {
                Text(Puzzle.rooms[room]).font(.system(.title3,design:.rounded,weight:.bold))
                Text(Puzzle.subtitles[room]).font(.subheadline).foregroundStyle(Neon.muted)
                ProgressView(value:Double(store.roomCount(room)),total:40).tint(Neon.roomColors[room])
                Text("\(store.roomCount(room)) of 40 complete").font(.caption).foregroundStyle(Neon.muted)
            }
            Image(systemName:"chevron.right").foregroundStyle(Neon.roomColors[room])
        }.panel(Neon.roomColors[room])
    }
}

struct LevelsView: View {
    let room: Int
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var router: GameRouter
    @State private var selected: Int = 0
    var puzzle: Puzzle { Puzzle.levels[room*40+selected] }
    var body: some View {
        ZStack {
            NeonBackground()
            ScrollView {
                VStack(alignment:.leading,spacing:24) {
                    Eyebrow(text:"Room 0\(room+1) / 03")
                    Text(Puzzle.rooms[room]).font(.system(size:34,weight:.heavy,design:.rounded))
                    Text(puzzle.rule).font(.body).foregroundStyle(Neon.muted)
                    VStack(spacing:16) {
                        HStack { Text(puzzle.title).font(.title2.bold()); Spacer(); Text("\(puzzle.limit) moves").monospacedDigit().foregroundStyle(Neon.gold) }
                        HStack { Text("Target").foregroundStyle(Neon.muted); Spacer(); TargetRow(state:puzzle.target) }
                        Button("Play level \(puzzle.number)") { router.puzzle = puzzle }.buttonStyle(NeonButton()).accessibilityIdentifier("play-selected")
                    }.panel(Neon.roomColors[room])
                    LazyVGrid(columns:[GridItem(.adaptive(minimum:64),spacing:12)],spacing:12) {
                        ForEach(0..<40) { i in
                            let p = Puzzle.levels[room*40+i]
                            Button { selected = i } label: {
                                VStack(spacing:10) { Text("\(p.number)").font(.system(.title3,design:.rounded,weight:.bold)).monospacedDigit(); Stars(count:store.data.records[p.id]?.stars ?? 0) }
                                    .frame(maxWidth:.infinity).frame(height:76)
                                    .background(selected == i ? Neon.purple.opacity(0.45) : Neon.panel,in:RoundedRectangle(cornerRadius:16))
                                    .overlay(RoundedRectangle(cornerRadius:16).stroke(selected == i ? Neon.gold : .clear,lineWidth:2))
                            }.buttonStyle(.plain).accessibilityLabel("Level \(p.number), \(store.data.records[p.id]?.stars ?? 0) stars").accessibilityAddTraits(selected == i ? .isSelected : [])
                        }
                    }
                    Text("All levels are open. Explore at your own pace.").font(.footnote).foregroundStyle(Neon.muted)
                }.page().padding(.top,16)
            }
        }.navigationTitle("Choose a puzzle").navigationBarTitleDisplayMode(.inline).toolbarBackground(Neon.bg,for:.navigationBar)
    }
}
