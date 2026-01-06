# Rules & Prizes System - Visual Guide

## 🎨 UI Layouts

### Bottom Sheet Preview (Shown Before Game)
```
┌─────────────────────────────────────┐
│           ═══════════                │  <- Drag handle
│                                      │
│  ℹ️  Quick Rules: Bellevue Monopoly │
│                                      │
│  Buy properties around Bellevue     │
│  and become the richest player!     │
│                                      │
│  Key Rules:                          │
│  ① Roll dice and move around...     │
│  ② Collect properties and earn...  │
│  ③ Be the last player standing...  │
│                                      │
│  💡 Tap "Full Rules" for detailed   │
│     game mechanics and strategies   │
│                                      │
│  ┌────────────────┬────────────────┐│
│  │ 📖 Full Rules  │ ▶️ Start Game   ││
│  └────────────────┴────────────────┘│
│                                      │
└─────────────────────────────────────┘
```

### Full Screen - Header
```
┌─────────────────────────────────────┐
│ ◀ Bellevue Monopoly          ❓    │
├─────────────────────────────────────┤
│                                      │
│  🎲  Bellevue Monopoly              │
│                                      │
│      Buy properties around           │
│      Bellevue and become the         │
│      richest player!                 │
│                                      │
├─────────────────────────────────────┤
│ 📋 Rules │📖 Full │🏆 Prizes │❓ FAQ│
└─────────────────────────────────────┘
```

### Full Screen - Quick Rules Tab
```
┌─────────────────────────────────────┐
│ Quick Rules                          │
│                                      │
│ ⓵ Roll dice and move around         │
│   the board to purchase properties   │
│                                      │
│ ⓶ Collect properties and earn       │
│   rent from other players            │
│                                      │
│ ⓷ Be the last player standing       │
│   when others go bankrupt            │
│                                      │
│ [View Full Rules →]                  │
│                                      │
└─────────────────────────────────────┘
```

### Full Screen - Full Rules Tab
```
┌─────────────────────────────────────┐
│ Full Rules                           │
│                                      │
│ ┌─────────────────────────────────┐ │
│ │ Setup                            │ │
│ │ Each player starts with $1,500   │ │
│ │ and a token. The banker         │ │
│ │ controls all money...           │ │
│ │ • Shuffle property cards...     │ │
│ │ • Choose starting order...      │ │
│ │ • All players start on GO...    │ │
│ └─────────────────────────────────┘ │
│                                      │
│ ┌─────────────────────────────────┐ │
│ │ Taking a Turn                    │ │
│ │ On your turn, roll the dice and  │ │
│ │ move your token forward.         │ │
│ │ • Roll two dice...               │ │
│ │ • If you roll doubles, roll...   │ │
│ │ • Follow the rules of...         │ │
│ │                                  │ │
│ │ 💡 Example: Roll a 7 and land on │ │
│ │    an unowned property...        │ │
│ └─────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Full Screen - Prizes Tab
```
┌─────────────────────────────────────┐
│ Prizes & Rewards                     │
│                                      │
│ 🏆 ┌──────────────────────────────┐ │
│    │ 🥇 1st Place                  │ │
│    │ Win the game        +100 pts  │ │
│    │ Highest points awarded...     │ │
│    └──────────────────────────────┘ │
│                                      │
│ 🎖️  ┌──────────────────────────────┐ │
│    │ 🥈 2nd Place                  │ │
│    │ Runner-up           +50 pts   │ │
│    └──────────────────────────────┘ │
│                                      │
│ 🎗️  ┌──────────────────────────────┐ │
│    │ 🥉 3rd Place                  │ │
│    │ Third place finish  +25 pts   │ │
│    └──────────────────────────────┘ │
│                                      │
│ ⭐ ┌──────────────────────────────┐ │
│    │ 💰 Bonus Points              │ │
│    │ Collect all properties       │ │
│    │ in one color        +10 pts  │ │
│    └──────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Full Screen - FAQs Tab
```
┌─────────────────────────────────────┐
│ Frequently Asked Questions           │
│                                      │
│ ▼ What happens if I land on Free    │
│   Parking?                           │
│   Nothing! Free Parking is just      │
│   a rest stop...                     │
│                                      │
│ ▶ Can I trade properties with       │
│   other players?                     │
│                                      │
│ ▶ What if I can't afford rent?      │
│                                      │
│ ▶ How long does a game take?        │
│                                      │
└─────────────────────────────────────┘
```

### During Game - Help Button in AppBar
```
┌─────────────────────────────────────┐
│ Bellevue Monopoly         ❓  ⋮      │
├─────────────────────────────────────┤
│                                      │
│         [Game Board Display]         │
│                                      │
│                                      │
│                  ┌──────────────────┐│
│                  │ 📖 Rules         ││
│                  └──────────────────┘│
│                                      │
└─────────────────────────────────────┘
```

## 🎨 Color Scheme

### Default Material 3 Colors
- **Primary**: Blue 600 → Purple 600 (gradient)
- **Cards**: White with subtle shadow
- **Text**: Dark gray on light background
- **Accents**: Blue, Amber (examples)
- **Icons**: Material Design icons

### Customizable Elements
```dart
// Header gradient
LinearGradient(
  colors: [Colors.blue.shade600, Colors.purple.shade600]
)

// Tab indicator
indicatorColor: Colors.blue

// Prize points background
backgroundColor: Colors.blue.shade50
```

## 📐 Spacing & Layout

```
Padding: 16dp (standard)
Card elevation: 2dp
Border radius: 8-12dp
Icon size: 16-36dp (contextual)
Font size: 12-24dp (hierarchical)
```

## 🎯 Interactive Elements

### Bottom Sheet
- ✋ Swipe down to dismiss
- 👆 Tap "Full Rules" → Opens full screen
- 👆 Tap "Start Game" → Dismisses, calls callback
- 🎯 Draggable handle at top

### Full Screen Tabs
- 👆 Tap tab → Switches content
- 📜 Scroll within content
- 🔗 Links to other tabs (Quick Rules → Full Rules)

### FAQs
- ▶️ Tap to expand Q&A
- 🔽 Swipe to collapse
- 💭 Question highlights on hover

### Prizes
- 🏆 Emoji visual indicator
- 💯 Point value badge
- 📝 Optional details text

## 🌓 Dark Mode Support

The system respects Flutter's theme:
- 🌙 Dark backgrounds automatically invert
- ✨ Contrast maintained
- 🎨 Colors adapt via `Theme.of(context)`

To customize for dark mode:
```dart
Color textColor = Theme.of(context).brightness == Brightness.dark
    ? Colors.white
    : Colors.black;
```

## 📱 Responsive Behavior

### Mobile (< 600dp)
- Bottom sheet takes 60% height
- Single column layout
- Large touch targets (48dp minimum)
- Optimized font sizes

### Tablet (600-1200dp)
- Bottom sheet takes 50% height
- Optional 2-column layout
- Standard spacing maintained
- Readable text size

### Desktop (> 1200dp)
- Full screen 80% of window
- Multi-column possible
- Larger fonts
- Desktop-optimized spacing

## 🎬 Animation Timeline

```
0ms    100ms             500ms       600ms
│      │                 │           │
└──┬───┘                 │           │
   Bottom sheet          Full screen
   slides up             appears
   
        500ms-600ms: Tab content fades in
        100ms increments between expanding FAQs
```

## ♿ Accessibility

- ✅ All colors have sufficient contrast
- ✅ Touch targets ≥ 48dp
- ✅ Semantic labels on buttons
- ✅ Tab order logical
- ✅ Content readable at 200% zoom
- ✅ Works with screen readers

## 🖼️ Example with Monopoly Theme

If you wanted to brand it Monopoly-style:
```dart
// Monopoly colors
colors: [
  Color(0xFF0066CC),  // Monopoly blue
  Color(0xFFDD0000),  // Monopoly red
]

// Monopoly font (optional)
textTheme: TextTheme(
  headlineSmall: TextStyle(
    fontFamily: 'Monopoly', // Custom font
    fontWeight: FontWeight.bold,
  ),
)
```

## 📊 Component Hierarchy

```
RulesAndPrizesScreen
├── CustomScrollView
│   ├── SliverAppBar (Header with gradient)
│   ├── SliverPersistentHeader (Pinned TabBar)
│   └── SliverFillRemaining
│       └── TabBarView
│           ├── Quick Rules (ListView)
│           │   ├── Numbers + Text rows
│           │   └── Link button
│           ├── Full Rules (ListView)
│           │   └── RuleSection Cards
│           ├── Prizes (ListView)
│           │   └── Prize Cards with icon + points
│           └── FAQs (ListView)
│               └── ExpansionTile items

RulesPreviewSheet
├── DraggableScrollableSheet
│   └── Column
│       ├── Header (drag handle + title)
│       ├── ListView (scrollable content)
│       │   ├── Description text
│       │   ├── Quick rules bullets
│       │   └── Info tip
│       └── Action buttons
```

## 🎯 User Flow

```
Game Start
    ↓
[Show Bottom Sheet]
    ↓
    ├─→ [Tap "Start Game"] → Close sheet → Game begins
    │
    └─→ [Tap "Full Rules"] → Open full screen
                ↓
            [Browse rules/prizes/FAQs]
                ↓
            [Close screen] → Back to bottom sheet
                ↓
            [Dismiss sheet] → Game begins
```

## 🔍 Detail Views

### Prize Card Expanded
```
┌───────────────────────────────────────┐
│ 🏆  1st Place       │  +100 pts        │
│     Win the game    │  (blue badge)    │
│     Highest points awarded for        │
│     completing the game               │
└───────────────────────────────────────┘
```

### Rule Section Expanded
```
┌───────────────────────────────────────┐
│ Setup                                  │
│ ─────────────────────────────────────  │
│ Each player starts with $1,500 and a   │
│ token. The banker controls all         │
│ remaining money and properties.        │
│                                        │
│ • Shuffle property cards and place     │
│   them on their spaces                 │
│ • Choose starting order by rolling     │
│   dice (highest goes first)            │
│ • All players start on "GO"            │
│                                        │
│ 💡 Example: Move 7 spaces and land on  │
│    an unowned property to purchase     │
└───────────────────────────────────────┘
```

---

This is a production-ready, visually modern system that follows 2026 Flutter/Material 3 standards. The layouts are responsive, accessible, and user-friendly.
