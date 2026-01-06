# Routing Update Summary

## Date: January 2025

## Overview
Updated the app's routing structure to match the UI designs provided. The changes align the navigation with the 5-tab bottom nav: **HOME | STOPS | QR | PRIZES | NEAR ME**.

---

## Routes Renamed

### 1. `/map` → `/stop-hub`
- **Constant**: `AppRoutes.map` → `AppRoutes.stopHub`
- **Screen**: HomeScreen (business categories hub)
- **Why**: Matches the "STOPS" tab label and shows business category cards (Boulevard Partners, Patriotic Partners, etc.)

### 2. `/rewards-nearby` → `/near-me`
- **Constant**: `AppRoutes.rewardsNearby` → `AppRoutes.nearMe`
- **Screen**: RewardsNearbyScreen (map with nearby businesses)
- **Why**: Matches the "NEAR ME" tab label in bottom nav

---

## New Routes Added

### `/terms`
- **Constant**: `AppRoutes.terms`
- **Screen**: TermsScreen (new)
- **Purpose**: Displays Terms & Conditions with "Back to Rules" link
- **Navigation**: Linked from Rules screen, part of Rules ↔ Terms cross-linking

---

## Bottom Navigation Updated

### Old Structure (5 tabs)
```
0. Home     → /
1. Map      → /map
2. Business → /businesses
3. Profile  → /profile
4. Game     → /game
```

### New Structure (5 tabs)
```
0. HOME     → /                (Welcome Back screen)
1. STOPS    → /stop-hub        (Business categories hub)
2. QR       → Modal trigger    (QR scanner overlay)
3. PRIZES   → /prizes          (Prize tiers)
4. NEAR ME  → /near-me         (Map with nearby rewards)
```

### Changes:
- **Tab labels**: Updated to match UI design (all caps)
- **Icons**: Updated to match design (star, qr_code_scanner, emoji_events, location_on)
- **Tab 2 (QR)**: Shows snackbar "QR Scanner coming soon!" (TODO: implement modal)
- **Routing**: Removed /businesses and /profile from bottom nav; accessible from HOME screen

---

## Home Screen (Welcome Back) Updated

### Old Navigation Boxes (8 items)
- Stop Hub (→ /map)
- Boulevard Partners (→ /businesses)
- Upload Images (→ /upload)
- Leaderboard (→ /leaderboard)
- Admin Panel (→ /admin)
- My Account (→ /profile)
- Game (→ /game)
- Casual Game (→ /casual-games)

### New Navigation Boxes (5 items)
- **Stop Hub** (→ /stop-hub) - Star icon
- **Near Me** (→ /near-me) - Location pin icon
- **Prizes** (→ /prizes) - Trophy icon
- **FAQs** (→ /rules-and-prizes) - Help icon
- **My Account** (→ /profile) - Person icon

### Why:
- Matches UI design mockup
- Removed duplicate navigation (Stop Hub and Boulevard Partners went to same place)
- Removed admin/debug features from main nav (accessible elsewhere)
- Cleaner, more focused navigation aligned with bottom nav tabs

---

## Files Modified

### Router Files
1. **lib/router/app_router.dart**
   - Renamed `AppRoutes.map` → `AppRoutes.stopHub`
   - Renamed `AppRoutes.rewardsNearby` → `AppRoutes.nearMe`
   - Added `AppRoutes.terms`
   - Added TermsScreen route to shell
   - Updated route comments

2. **lib/widgets/main_scaffold.dart**
   - Updated `_calculateCurrentIndex()` to match new tab structure
   - Updated `_onItemTapped()` to handle new routes
   - Added QR scanner snackbar placeholder (tab 2)
   - Fixed tab index calculation for /stop-hub, /prizes, /near-me

3. **lib/widgets/bottom_nav_bar.dart**
   - Updated tab labels: HOME, STOPS, QR, PRIZES, NEAR ME
   - Updated icons to match UI design
   - Reordered tabs to match mockup

### Screen Files
4. **lib/screens/mobile_landing_screen.dart**
   - Updated title: "Welcome" → "Welcome Back"
   - Reduced nav boxes from 8 to 5
   - Updated nav box icons and labels
   - Fixed route references to use new constants

5. **lib/screens/terms_screen.dart** (NEW)
   - Created Terms & Conditions screen
   - 10 sections with placeholder content
   - "Back to Rules" link
   - Proper formatting and structure

### Files with Route Reference Updates
6. **lib/screens/checkin_history_screen.dart**
   - Fixed: `AppRoutes.map` → `AppRoutes.stopHub`

7. **lib/screens/casual_games_lobby_screen.dart**
   - Fixed: `AppRoutes.rewardsNearby` → `AppRoutes.nearMe`

8. **lib/screens/instructions_screen.dart**
   - Fixed: `AppRoutes.map` → `AppRoutes.stopHub`

---

## Documentation Created

1. **docs/ROUTING_PLAN_UI_BASED.md**
   - Comprehensive routing plan based on UI mockups
   - Documents all 5 bottom nav tabs
   - Lists all routes with descriptions
   - Navigation flow diagrams
   - Cross-screen linking patterns

---

## Migration Notes

### Breaking Changes
- `AppRoutes.map` no longer exists → use `AppRoutes.stopHub`
- `AppRoutes.rewardsNearby` no longer exists → use `AppRoutes.nearMe`

### Deep Links / External URLs
If any external links or notifications point to:
- `/map` → Update to `/stop-hub`
- `/rewards-nearby` → Update to `/near-me`

### Analytics / Tracking
Update any analytics route tracking to use new route names.

---

## Testing Checklist

### Bottom Nav Tabs
- [ ] Tab 0 (HOME) navigates to "/" (Welcome Back screen)
- [ ] Tab 1 (STOPS) navigates to "/stop-hub" (business categories)
- [ ] Tab 2 (QR) shows "QR Scanner coming soon!" snackbar
- [ ] Tab 3 (PRIZES) navigates to "/prizes"
- [ ] Tab 4 (NEAR ME) navigates to "/near-me" (map)
- [ ] Active tab is highlighted correctly on each screen

### Home Screen Navigation
- [ ] Stop Hub card → /stop-hub
- [ ] Near Me card → /near-me
- [ ] Prizes card → /prizes
- [ ] FAQs card → /rules-and-prizes
- [ ] My Account card → /profile

### Cross-Screen Navigation
- [ ] Stop Hub → Business List works
- [ ] Business List → "Back to Stop Hub" works
- [ ] Rules screen → Terms link works
- [ ] Terms screen → "Back to Rules" works
- [ ] Profile → Check-in History works
- [ ] Check-in History → Business detail works

### Deep Link Testing
- [ ] Direct navigation to /stop-hub works
- [ ] Direct navigation to /near-me works
- [ ] Direct navigation to /terms works

---

## Next Steps / TODOs

1. **QR Scanner Modal** (High Priority)
   - Implement QR scanner overlay/modal
   - Trigger from bottom nav tab 2
   - Show check-in available/completed cards

2. **Profile Screen Enhancements**
   - Add "Check-in History" button
   - Add "Edit Account" button
   - Add "Rules" button (as shown in UI mockup)

3. **Business List "Back to Stop Hub"**
   - Verify link appears on business list screen
   - Test navigation back to /stop-hub

4. **Terms & Conditions Content**
   - Replace placeholder content with actual terms
   - Add contact email
   - Add last updated date
   - Legal review

5. **Analytics Update**
   - Update tracking to use new route names
   - Test route tracking still works

6. **External Links / Deep Links**
   - Audit any external links to /map or /rewards-nearby
   - Update notification deep links

---

## UI Design Alignment Status

✅ **Bottom Nav**: 5 tabs match UI mockup (HOME, STOPS, QR, PRIZES, NEAR ME)  
✅ **Home Screen**: 5 nav cards match UI mockup  
✅ **Route Names**: Aligned with tab labels (/stop-hub, /near-me)  
✅ **Terms Screen**: Created with proper structure  
⚠️ **QR Scanner**: Placeholder (shows snackbar); needs modal implementation  
⚠️ **Profile Buttons**: Need to add Check-in History, Edit Account, Rules buttons  

---

## Questions / Decisions Made

**Q: Why remove /businesses and /profile from bottom nav?**  
A: UI design shows 5 specific tabs. /businesses is accessed via Stop Hub categories. /profile is accessed via HOME → My Account card.

**Q: Why is QR scanner a modal instead of a route?**  
A: UI design shows it as an overlay that appears on top of current screen, not a separate page.

**Q: Where is /upload now?**  
A: Upload functionality moved to Profile screen's image gallery. Not needed on main HOME screen.

**Q: What happened to /game and /casual-games?**  
A: Still accessible via router but removed from HOME screen to match UI design. Can be accessed via other means or added to a drawer menu.

---

**Last Updated**: January 2025  
**Status**: ✅ Routing update complete, all errors fixed
