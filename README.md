# Neon Reels

An offline, deterministic reel puzzle built with SwiftUI for iPhone and iPad. All product text is English (UK).

Open `NeonReels.xcodeproj`, select the NeonReels scheme and an iOS 17+ device. The implementation was built with Xcode 27.2, Swift 6 language mode. There are no package dependencies or API keys. Signing is intentionally not configured for distribution.

## Source map

- `Engine.swift`: fixed levels, date-based daily puzzle, shared move rules, exact breadth-first solver, rating and Codable progress types.
- `Store.swift`: atomic persistence, loading, retry, corrupt-save protection and backup before reset.
- `Design.swift`: palette, native vector symbols, reusable controls and surfaces.
- `NeonReelsApp.swift`: root tabs, puzzle hall and level selection.
- `PuzzleView.swift`: manual gameplay, hint/undo/restart and solution/result sheet.
- `CollectionViews.swift`: album, daily history and settings.
- `NeonReelsTests`: engine, validation and filesystem persistence checks.
- `NeonReelsUITests`: real tap-driven solve/resume/collection/daily/limit journeys.

`SPEC.md` records the full product rules and the user's English-only language instruction.

## Factory integration

Local project: `/Users/belzephyrus/Documents/gambling_factory/ios/apps/NeonReels`

Bundle ID: `com.neonreels.puzzle`. Factory account `373` / `acc_373`. Imported as a manual Scratch project and associated with the uniquely matched SLOTS New app request. Shipping remains off. Cached release localisations are preserved on the factory record; the app itself stays English by explicit user request.

## Build and QA

Use the factory build shim, shared lock and this app's own DerivedData. Simulator work must run through `gf/genesis/simulator_pool.py`; never run tests directly on a shared device. The complete foreground script lives at `/Users/belzephyrus/Documents/gambling_factory/output/NeonReels-implementation/qa-iphone-final.sh`.

All logs, test results, exported screenshot attachments and the import receipt are in `/Users/belzephyrus/Documents/gambling_factory/output/NeonReels-implementation/`.

The stand-alone `LogicCheck.swift` in that evidence directory can also compile with `Engine.swift` using `swiftc -swift-version 6`. It checks every level and all 375 room/state combinations without occupying a simulator.

## Product boundaries

Local progress only, no cloud sync. Daily puzzles are reproducibly selected from the verified 120-level library, so a board can recur on another day. All levels are open from the start. No advertising, purchases, network traffic, analytics or account creation. Production signing and store submission remain separate external work.

Detailed validation: `/Users/belzephyrus/Documents/gambling_factory/output/NeonReels-implementation/QA_REPORT.md`.
