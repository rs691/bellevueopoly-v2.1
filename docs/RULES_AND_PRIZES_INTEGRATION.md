# Rules & Prizes System - Integration Guide

## Overview
A complete, reusable rules and prizes system for your games. Works with any game type using a simple data model.

## Components

### 1. **GameRules Model** (`lib/models/game_rules.dart`)
Data structure for organizing game information:
- `gameName` - Game title
- `gameDescription` - Short description
- `quickRules` - 2-3 bullet points for quick preview
- `fullRules` - Detailed rule sections with examples
- `prizes` - Win conditions and point rewards
- `faqs` - Frequently asked questions

### 2. **Rules & Prizes Screen** (`lib/screens/rules_and_prizes_screen.dart`)
Full screen with tabbed interface:
- **Quick Rules Tab** - Fast overview + link to full rules
- **Full Rules Tab** - Detailed game mechanics with sections and examples
- **Prizes Tab** - Reward structure with point values
- **FAQs Tab** - Expandable Q&A section

### 3. **Rules Preview Sheet** (`lib/screens/rules_preview_sheet.dart`)
Modal bottom sheet shown before game starts:
- Quick rules summary
- "View Full Rules" button
- "Start Game" button
- Draggable/scrollable interface

## Quick Start

### Step 1: Define Your Game Rules
```dart
// In lib/models/game_rules.dart or a separate file
final myGameRules = GameRules(
  gameName: 'My Game',
  gameDescription: 'Description here',
  quickRules: [
    'Rule 1',
    'Rule 2',
    'Rule 3',
  ],
  fullRules: [
    RuleSection(
      title: 'Setup',
      description: 'How to set up the game',
      bulletPoints: ['Point 1', 'Point 2'],
      example: 'Example here',
    ),
  ],
  prizes: [
    Prize(
      title: '1st Place',
      description: 'Win the game',
      points: 100,
      icon: '🏆',
    ),
  ],
  faqs: [
    FAQ(
      question: 'How do you win?',
      answer: 'By being awesome!',
    ),
  ],
);
```

### Step 2: Show Preview Before Game
```dart
// In your game start button handler
onPressed: () {
  showRulesPreviewSheet(
    context,
    myGameRules,
    onStartGame: () {
      // Start your game
      context.push(AppRoutes.monopolyBoard);
    },
  );
}
```

### Step 3: Add Help Button During Game
```dart
// In your game screen AppBar
AppBar(
  actions: [
    IconButton(
      icon: const Icon(Icons.help_outline),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RulesAndPrizesScreen(gameRules: myGameRules),
          ),
        );
      },
    ),
  ],
)
```

## Features

✅ **Responsive Design**
- Works on mobile and tablet
- Scrollable content with pinned header
- Draggable bottom sheet

✅ **Material 3 Design**
- Follows 2026 Flutter standards
- Tab-based navigation
- Smooth animations

✅ **Reusable**
- Works with any game type
- Data-driven approach
- Easy to customize

✅ **User-Friendly**
- Quick rules preview
- Detailed reference
- FAQs with expand/collapse
- Prizes with point values

## Customization

### Change Colors
Edit the gradient colors in `RulesAndPrizesScreen`:
```dart
gradient: LinearGradient(
  colors: [
    Colors.blue.shade600,    // Change these
    Colors.purple.shade600,
  ],
)
```

### Change Icons
Pass different icons to `RuleSection` and `Prize`:
```dart
Prize(
  icon: '⭐',  // Change emoji/icon
)
```

### Add Images
Extend GameRules model with image paths:
```dart
class GameRules {
  final String? backgroundImage;
  final List<String> stepImages;
}
```

## Routes

The system includes a route for easy navigation:

```dart
// Navigate to rules screen from anywhere
context.push(
  AppRoutes.rulesAndPrizes,
  extra: myGameRules,
);
```

## Examples

See `RULES_AND_PRIZES_USAGE.dart` for:
- Showing preview before game start
- Navigating to full rules
- Creating custom game rules
- Integration patterns
- Tips and best practices

## For Monopoly Board Game

The system already includes `monopolyGameRules` configured with:
- Quick rules (buy properties, collect rent, win)
- Full rules (setup, taking turns, properties, winning)
- Prizes (1st place, 2nd place, 3rd place, bonuses)
- FAQs (parking, trading, bankruptcy, duration)

Use it immediately:
```dart
showRulesPreviewSheet(context, monopolyGameRules);
```

## Browser/Platform Support

Works on:
- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## Performance

- Uses const constructors for efficiency
- Lazy-loaded tab content
- Minimal rebuilds with StatefulWidget controller
- Suitable for low-end devices

## Future Enhancements

- [ ] Video tutorials in rules
- [ ] Animated examples
- [ ] Screenshots/diagrams
- [ ] Multiple language support
- [ ] Share rules as PDF
- [ ] In-game rules overlay
- [ ] AI-powered rule suggestions
- [ ] Player-generated custom rules

## Troubleshooting

**Q: Bottom sheet doesn't appear?**
A: Make sure you're calling `showRulesPreviewSheet()` from a context with a Navigator.

**Q: Tabs don't work?**
A: Ensure `TabController` is properly initialized in `initState()`.

**Q: Content overflows?**
A: The widget uses `ListView` for scrollable content. Adjust padding if needed.

## Support

For issues or questions, refer to the usage examples in `RULES_AND_PRIZES_USAGE.dart` or check the Flutter documentation on:
- Bottom sheets: https://api.flutter.dev/flutter/material/showModalBottomSheet.html
- Tab bars: https://api.flutter.dev/flutter/material/TabBar-class.html
- Material 3: https://m3.material.io/
