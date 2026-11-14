<!-- gf-brief source=a15a55311649193e7f1ff0b9d09da465e8903f657270eb99d7242a16b1a77a17 written=2026-11-14T12:28:17+03:00 -->
# Neon Reels

## What it is

Neon Reels is an offline logic puzzle game in which players turn three reels to match a target row within a move limit. It is for people who enjoy short, self-paced puzzles and improving their solutions.

## Launch and onboarding

1. A cold launch briefly shows “Opening the puzzle hall…” while progress loads.
2. The app opens on “Play”, showing “NEON REELS”, “Offline ready”, “A LITTLE LOGIC. A LOT OF GLOW.” and “Your next bright idea.”
3. The main card shows “ONE MOVE CLOSER”, the current room and level, its move limit and stars. On a fresh install, “Play your first puzzle” opens Level 1. After a puzzle has been opened, the button reads “Continue puzzle”.
4. Below it, “The puzzle hall” shows progress through 120 levels and the three rooms. The instruction reads “Swipe a reel or tap an arrow. Match the target, then check your combination.”

There is no separate onboarding flow.

## Screens

### “Play” and “Choose a puzzle”

The hall shows “Three rooms. Every move is yours.” and the number completed out of 120. Each room card opens “Choose a puzzle” for that room:

- “Cherry Club” — “Find your rhythm”
- “Electric Night” — “Make the connection”
- “Diamond Room” — “Master the loop”

Each card shows how many of its 40 levels are complete. On “Choose a puzzle”, numbered level buttons select a level and show its stars. The selected level’s rule, target and move limit appear above the grid. “Play level [number]” opens it. “All levels are open. Explore at your own pace.” confirms that no level must be unlocked first. The navigation back control returns to the hall.

### Puzzle

A regular puzzle is headed “Make your move”; a daily puzzle is headed by its date. It shows the room, “Level [number]” or “Daily puzzle”, total levels “completed”, “YOUR TARGET”, “Centre row”, the three reels, moves used and moves “left”.

Swipe a reel vertically or tap its up and down arrow controls to turn it. The accessible labels are “Reel 1 up”, “Reel 1 down”, and the equivalent labels for reels 2 and 3. The reel itself is announced as “Reel [number], [symbol]”.

- “Undo” reverses the last move and restores one move.
- “CHECK”, accessible as “Check combination”, checks the centre row. A matching row opens the result; an unmatched row opens the result only when the move limit has been reached.
- “Hint” gives the next move on a shortest path, explains any linked reel and states the remaining shortest-path length.
- The icon-only “Restart” control opens “Restart this puzzle?” and “Your best result stays saved. This attempt returns to the fixed starting position.” “Restart puzzle” resets the attempt; cancel dismisses the dialog.
- The icon-only “Close” control returns to the screen from which the puzzle was opened.

The rules shown are “Each reel turns independently.” in “Cherry Club”; “Reels 1 and 2 also turn the reel to their right. Reel 3 turns alone.” in “Electric Night”; and “Each reel also turns its neighbour: 1 → 2, 2 → 3, 3 → 1.” in “Diamond Room”. Linked reels are marked “LINK → [number]” or “SOLO”. The screen also explains: “Up brings the symbol below into the centre. Each arrow or swipe uses one move. Undo restores one move.”

### Result

A successful result shows “BEAUTIFULLY ALIGNED” and “Brilliant move.”; an unsuccessful result shows “A NEW ANGLE AWAITS” and “Try a fresh approach.” It displays the final row, “Your moves”, “Optimal”, “Best” and, after a win, stars.

“The shortest route” lists the steps from the original starting row and explains which reels turn together. The rating guide states the move counts for three, two and one stars and says hints do not affect the rating.

“Play again” after a win or “Retry puzzle” after a loss starts the same puzzle from its original position. “Back to the hall” closes a regular puzzle; “Back to daily” closes a daily puzzle.

### “Daily”

“THE DAILY RITUAL” and “One day. One bright puzzle.” introduce the current puzzle. Its card shows the date in “UTC”, target, move limit and room. “Play today's puzzle” opens it; after completion, “Replay today's puzzle” appears along with the best move count and stars.

The screen says: “Available offline. The date sets the puzzle; its starting row and target always stay the same. A new puzzle arrives at 00:00 UTC.”

“Your daily history” lists completed dates, best moves and stars. A date row marked “Tap to replay” opens that day’s puzzle again.

### “Album”

“SMALL ICONS. BRIGHT MILESTONES.” and “The symbol album” introduce the collection. The screen shows the number “of 5 collected” and explains: “Your collection grows as you complete different levels. Every symbol is available on the reels from the start.”

The five tappable cards are “Cherry”, “Star”, “Bell”, “Lightning” and “Diamond”. Each shows “Collected” or the number of levels needed. Tapping a card opens its description and, if it is not yet collected, its required number of different levels and current progress. “Back to album” closes the detail.

### “Settings”

“Make it your rhythm.” heads the settings screen.

- “Haptic feedback” turns move feedback on or off.
- “Reduce animation” turns reel animation reduction on or off. The screen says “Your device's Reduce Motion setting is always respected.”
- “On this device” explains automatic saving and offline play, and shows “Levels complete” and “Stars earned”.
- “Retry save” appears when there is a save or read error and retries the operation.
- “How to play” explains the target, reel controls, checking, undo, restart, hints and the daily puzzle.
- “Reset local progress” opens “Reset all local progress?” with the explanation “This clears attempts, best results, daily history and collection milestones. A backup of the previous save is kept on this device.” “Reset progress” confirms; cancel dismisses the dialog.

The footer reads “NEON REELS  /  1.0” and “Designed for a brighter train of thought.”

### “Next bright idea” widget

The small and medium Home Screen widget shows the current room and level, “continue this level” and progress. The medium version also shows target symbols and “[number] of 120 puzzles solved · [number] moves allowed”. Its footer reads “Target symbols · a logic puzzle”. Tapping the widget opens the current level.

Before widget progress is available, it can show “Open the app to begin”, “Enter the puzzle hall to begin.” and “Your progress will appear here”.

## Features

- 120 open levels across “Cherry Club”, “Electric Night” and “Diamond Room”.
- “Independent reels” and “Linked reels”, with target matching and a move limit.
- “Undo”, “Hint”, “CHECK” and “Restart”.
- One to three stars, best move counts and “The shortest route” after a result.
- A “Daily puzzle” that changes at 00:00 UTC, with replayable “Your daily history”.
- “The symbol album”, with five milestones earned by completing different levels.
- “Haptic feedback” and “Reduce animation” settings.
- “Next bright idea” Home Screen widget.
- Offline play and automatic local progress saving.

## Behaviours that can look like bugs

- “Undo” is disabled until a move has been made. Turn a reel to enable it.
- At the move limit, the arrow buttons are disabled. The message says “Move limit reached. Check your row or undo a move.” Use “CHECK”, “Undo” or “Restart” to continue.
- If the row does not match and moves remain, “CHECK” stays on the puzzle and says “Not matched yet. Compare the centre row with your target, or ask for a hint.” Match the target or use “Hint”.
- If the target already matches, “Hint” says “The target is matched. Tap Check to finish.” Tap “CHECK”.
- A hint can say “Undo or restart to stay within the limit.” when the shortest remaining route exceeds the moves left. Undo moves or restart the puzzle.
- “Your first day starts here” and “Complete a daily puzzle to begin your history.” appear until a daily puzzle is completed. Completed dates then accumulate in “Your daily history”.
- Album cards remain uncollected until the required number of different regular levels is completed: “Star” at 1, “Bell” at 5, “Lightning” at 15 and “Diamond” at 30. “Cherry” is collected from the start; all five symbols can appear on reels immediately.
- Restarting or retrying returns to the same starting row and target. “Reset progress” clears active progress and milestones after confirmation.
- If progress cannot be saved, the app says “Progress could not be saved on this device. Your current session is still available. Free some storage and tap Retry save in Settings.” If saved progress cannot be read, it directs the player to retry in Settings or reset the local save. If a backup cannot be made during reset, reset is cancelled and the app asks the player to free storage and try again.

## Starter content and resume

All 120 fixed levels and all three rooms are available from the start. The album starts with “Cherry” collected; the other symbols are present on the reels.

Unfinished attempts are saved automatically and resume when their puzzle is reopened. “Continue puzzle” opens the most recently visited regular level; after a regular level is completed, it advances to the next level when one exists. Daily attempts can also be resumed by reopening the relevant puzzle.

## Permissions

None.

## Absent

Login or accounts, in-app purchases, ads, analytics, user-generated content, an account deletion flow and an App Tracking Transparency prompt are absent.

## Data and support

Moves, attempts, best results, daily history, settings and collection progress stay on the device. The app says it works entirely offline. A backup of the previous save is kept on the device when progress is reset.

There is no on-screen Contact or Support control.

## Scanning and health

None.

## Platform

The interface uses English and a British English locale. The daily puzzle follows UTC and changes at 00:00 UTC, regardless of the device’s local date.

The app supports iPhone and iPad on iOS 17.0 or later. On iPhone it supports portrait and both landscape orientations; on iPad it also supports upside-down portrait.

## Category

Puzzle game.
