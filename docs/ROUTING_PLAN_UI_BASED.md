# Routing Plan (Based on UI Design)

## Bottom Navigation Structure (5 tabs)
Based on the UI mockups, the app has these bottom nav tabs:

1. **HOME** (top hat icon) → Welcome Back landing page
2. **STOPS** (star icon) → Stop Hub with business categories
3. **QR Scanner** (center diamond icon) → Modal overlay for check-in
4. **PRIZES** (medal icon) → Prize tiers and rewards info
5. **NEAR ME** (location pin icon) → Map with nearby rewards

---

## Route Definitions

### Public Routes
- `/splash` — App startup screen
- `/landing` — Pre-auth landing page
- `/welcome` — Welcome/onboarding intro
- `/login` — User sign-in
- `/register` — "Create Your Account" registration form
- `/password-reset` — Password recovery
- `/email-verification` — Email verification flow

---

### Authenticated Routes (Bottom Nav)

#### Tab 1: HOME → `/`
**Screen**: "Welcome Back <NAME>" landing page

**Features**:
- Quick action cards:
  - Stop Hub
  - Near Me
  - Prizes
  - FAQs
  - My Account
- Time remaining countdown
- Chamber branding at bottom

**Navigation from this screen**:
- Stop Hub card → `/stop-hub`
- Near Me card → `/near-me`
- Prizes card → `/prizes`
- FAQs card → `/faqs`
- My Account card → `/profile`

---

#### Tab 2: STOPS → `/stop-hub`
**Screen**: "STOP HUB" - Main business discovery hub

**Features**:
- Search bar at top
- Business category cards:
  - Boulevard Partners
  - Patriotic Partners
  - Merch Partners
  - Giving Partners
  - Community Chest
  - Wild Cards
  - Fun House
- Bottom nav visible

**Navigation**:
- Each category → `/businesses?category=<category>`
- Individual business card → `/business/:id` (modal on root navigator)

---

#### Sub-route: `/businesses`
**Screen**: "BOULEVARD PARTNERS" (or other category list)

**Features**:
- "Back to Stop Hub" link → `/stop-hub`
- Search bar
- Filter dropdown (Near Me, Show Available, Reset Filters)
- List of business cards with icons and "offer details"

**Navigation**:
- Business card tap → `/business/:id` (modal)
- Back to Stop Hub → `/stop-hub`

---

#### Tab 3: QR SCANNER (Center Button)
**Behavior**: Opens modal/overlay (no route change)

**Features**:
- Full-screen QR scanner camera view
- Shows "CHECK IN AVAILABLE" card when business detected
- Shows "CHECK IN COMPLETED" confirmation after successful scan
- Modal dismisses back to previous screen

---

#### Tab 4: PRIZES → `/prizes`
**Screen**: "CHECK IN TO WIN"

**Features**:
- Prize Parkway section (high-value sponsors)
- Tier 1 prizes ($750-$1500+)
- Tier 2 prizes ($600-$800)
- Tier 3 prizes ($500)
- "Rules" link at bottom → `/rules`

**Navigation**:
- Rules link → `/rules`

---

#### Tab 5: NEAR ME → `/near-me`
**Screen**: "AVAILABLE REWARDS NEARBY"

**Features**:
- Embedded map with:
  - User current location pin
  - Business location pins
  - Route preview
  - Travel time estimates
- List of nearby businesses below map:
  - Distance and time to each
  - "Get directions" buttons

**Navigation**:
- Business card tap → `/business/:id` (modal)

---

### Additional Authenticated Routes (Not in Bottom Nav)

#### `/profile`
**Screen**: "USERNAME" (My Account)

**Features**:
- Profile picture with upload button
- Username display
- Masked phone number
- Contact info card (Name, Email, Phone)
- "Logout" link in top-right
- Action buttons:
  - Check-in History
  - Edit Account
  - Rules
- Chamber branding at bottom

**Navigation**:
- Check-in History → `/checkin-history`
- Edit Account → `/profile/edit` or modal
- Rules → `/rules`
- Logout → Back to `/landing`

---

#### `/checkin-history`
**Screen**: "CHECK-IN HISTORY"

**Features**:
- Bankroll display (total points earned)
- Chronological list of check-ins:
  - Business icon
  - Business name
  - Check-in date (mm/dd/yyyy)
- Bottom nav visible

**Navigation**:
- Business entry tap → `/business/:id` (modal)

---

#### `/rules`
**Screen**: "RULES"

**Features**:
- Scrollable rules content (Lorem ipsum placeholder)
- "Terms and Conditions" link at bottom → `/terms`
- Bottom nav visible

**Navigation**:
- Terms and Conditions → `/terms`

---

#### `/terms`
**Screen**: "TERMS & CONDITIONS"

**Features**:
- Scrollable legal content
- "Back to Rules" link at bottom → `/rules`
- Bottom nav visible

---

#### `/faqs`
**Screen**: "FAQs"

**Features**:
- Search bar at top
- "RULES" link in top-right → `/rules`
- Expandable FAQ accordion items
- Organized by most commonly searched
- Bottom nav visible

**Navigation**:
- Rules link → `/rules`

---

#### `/instructions`
**Screen**: Tutorial overlay

**Features**:
- White overlay card explaining check-in process
- "Build an instructional video that walks the user through the check in process after the screens are built" note
- Can be triggered on first app use or from help menu

---

#### `/business/:id`
**Screen**: Business check-in card (modal)

**Features**:
- Opened via root navigator for modal effect
- Company name and logo
- "CHECK IN AVAILABLE" or "CHECK IN COMPLETED" status
- Call to action: "Check In" button
- Description/promo message
- Sponsor info (optional ad space)
- Rules link
- "More info" link at bottom

**Navigation**:
- Check In button → Triggers QR scan or geofence
- Rules link → `/rules`
- More info → Expands details or links to external site
- Close/dismiss → Returns to previous screen

---

### Other Routes (Lower Priority)

#### `/upload`
**Screen**: Image upload

**Features**:
- Camera/gallery picker
- Category selection
- Upload progress

---

#### `/leaderboard`
**Screen**: Player rankings

**Features**:
- Top players by score
- Time period filters

---

#### `/monopoly-board`
**Screen**: Full Monopoly board game

**Features**:
- Interactive board
- Player pieces
- Dice roll

---

#### `/casual-games`
**Screen**: Casual games lobby

**Features**:
- Game selection cards
- Quick start buttons

---

#### `/game`
**Screen**: Active game session

**Features**:
- Current game state
- Turn management

---

#### `/admin`
**Screen**: Admin console (admin-only)

**Features**:
- User management
- Admin privileges

---

#### `/admin-test`
**Screen**: Admin diagnostics (dev-only)

**Features**:
- Admin status check
- Testing tools

---

## Navigation Flow Summary

### Bottom Nav Tab Mapping
```
Tab 0 (HOME) → `/`
Tab 1 (STOPS) → `/stop-hub`
Tab 2 (QR) → Modal trigger (no route)
Tab 3 (PRIZES) → `/prizes`
Tab 4 (NEAR ME) → `/near-me`
```

### Quick Action Cards on Home (/)
```
Stop Hub → `/stop-hub`
Near Me → `/near-me`
Prizes → `/prizes`
FAQs → `/faqs`
My Account → `/profile`
```

### Cross-Screen Navigation
```
Profile → Check-in History → `/checkin-history`
Profile → Edit Account → Modal or `/profile/edit`
Profile → Rules → `/rules`

Prizes → Rules → `/rules`
FAQs → Rules → `/rules`
Business → Rules → `/rules`

Rules → Terms → `/terms`
Terms → Back to Rules → `/rules`

Stop Hub → Category List → `/businesses?category=X`
Business List → Back to Stop Hub → `/stop-hub`
Business List → Business Detail → `/business/:id`

Near Me → Business Detail → `/business/:id`
Check-in History → Business Detail → `/business/:id`
```

---

## Changes Needed from Current Implementation

### Route Renames
1. `/map` → `/stop-hub` (current map screen is actually Stop Hub)
2. `/rewards-nearby` → `/near-me` (match bottom nav label)
3. Keep `/businesses` for filtered category lists
4. Keep `/business/:id` for business detail modal

### Bottom Nav Updates
1. Tab 0: HOME → `/` ✅ (already correct)
2. Tab 1: STOPS → `/stop-hub` (rename from `/map`)
3. Tab 2: QR Scanner → Modal (not a route)
4. Tab 3: PRIZES → `/prizes` ✅ (already added)
5. Tab 4: NEAR ME → `/near-me` (rename from `/rewards-nearby`)

### Clean Up Mobile Landing (Home)
Current home has too many duplicate nav boxes:
- Remove: "Stop Hub" (duplicate of Tab 1)
- Remove: "Game" (if not primary flow)
- Remove: "Casual Game" (if not primary flow)
- Remove: "Upload Images" (move to profile or drawer)
- Remove: "Admin Panel" (move to profile menu or hidden)

Keep only:
- Stop Hub
- Near Me
- Prizes
- FAQs
- My Account

### Profile Screen Updates
Add buttons for:
- Check-in History
- Edit Account
- Rules
- Admin Panel (if user is admin)

---

## Transition Animations

### Standard Page Transitions
- Bottom nav tab switches: Crossfade (150ms)
- Standard push navigation: Shared axis horizontal slide (250ms)

### Modal Transitions
- Business detail card: Fade + scale from center (200ms)
- QR scanner: Slide up from bottom (300ms)
- Tutorial overlay: Fade in (200ms)

### Special Effects
- Check-in success: Celebration animation (confetti/sparkles)
- Points earned: Counter animation
- Reduce motion: Respect accessibility settings (fallback to fade)

---

## Route Guards

### Public Only (Redirect authenticated users to `/`)
- `/landing`
- `/welcome`
- `/login`
- `/register`

### Authenticated Only (Redirect to `/landing`)
- All routes in authenticated shell
- `/profile`, `/checkin-history`, `/prizes`, `/near-me`, etc.

### Admin Only
- `/admin`
- Business management features

### Dev Only (Feature Flag)
- `/admin-test`

---

**Last Updated**: January 6, 2026  
**Status**: Ready for implementation
