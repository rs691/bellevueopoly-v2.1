# Bellevue Monopoly v2.1 - Features Overview

## Summary

Bellevue Monopoly is a location-based Monopoly game for the Bellevue area. Recent updates have added comprehensive admin functionality, rules/prizes systems, and Firebase integration for image storage and user management.

---

## Core Features by Category

### 1. Authentication & Authorization

#### Login Screen (`lib/screens/login_screen.dart`)
- **Purpose**: User sign-in and account creation
- **Features**:
  - Email/password authentication (Firebase Auth)
  - "Create Account" button for new users
  - "Forgot Password" link for password recovery
  - Anonymous user option (auto-grants admin privileges for testing)
  - Glassmorphic design with gradient background
  - Responsive form layout
- **Why**: Secures user accounts and game progress; anonymous login enables quick testing
- **Route**: `/login`

#### Registration Screen (`lib/screens/registration_screen.dart`)
- **Purpose**: New user account creation
- **Features**:
  - Email and password validation
  - Confirm password field
  - Integration with Firebase Auth
  - Form validation with error messages
  - Responsive design
- **Why**: Allows new players to create accounts securely
- **Route**: `/register`

#### Password Reset Screen (`lib/screens/password_reset_screen.dart`)
- **Purpose**: Account password recovery
- **Features**:
  - Email-based password reset
  - Firebase Auth integration
  - Confirmation messaging
- **Why**: Helps users recover forgotten passwords
- **Route**: `/password-reset`

#### Email Verification Screen (`lib/screens/email_verification_screen.dart`)
- **Purpose**: Email verification workflow
- **Features**:
  - Email verification prompts
  - Resend verification email
  - Firebase Auth integration
- **Why**: Ensures valid user emails for account security
- **Route**: `/email-verification`

#### Welcome & Landing Screens
- **Welcome Screen** (`welcome_screen.dart`): Initial app greeting
- **Landing Screen** (`landing_screen.dart`): Pre-auth landing page
- **Splash Screen** (`splash_screen.dart`): App startup screen
- **Purpose**: Guide new users through onboarding
- **Routes**: `/welcome`, `/landing`, `/splash`

---

### 2. Admin System ⭐ NEW

#### Admin Screen (`lib/screens/admin_screen.dart`)
- **Purpose**: Administrative control panel for game management
- **Features**:
  - View and manage user admin status
  - Grant/revoke admin privileges
  - User management interface
  - Admin-only actions
- **Why**: Allows super-admins to manage other administrators
- **Route**: `/admin`
- **Access**: Admin users only

#### Admin Test Screen (`lib/screens/admin_test_screen.dart`)
- **Purpose**: Verify admin status and test admin privileges
- **Features**:
  - Display current user's admin status
  - Show admin badge if user is admin
  - Test admin functionality
  - Troubleshooting tool
- **Why**: Helps developers test admin system during development
- **Route**: `/admin-test`

#### Admin Provider (`lib/providers/admin_provider.dart`)
- **Purpose**: Riverpod state management for admin data
- **Features**:
  - Stream-based admin status tracking
  - Real-time admin privilege updates
  - Cached admin data
- **Why**: Efficiently manages admin state across the app

#### Admin Service (`lib/services/admin_service.dart`)
- **Purpose**: Backend logic for admin operations
- **Features**:
  - Grant admin privileges via Firestore
  - Revoke admin privileges
  - Check admin status
  - Firestore integration
- **Why**: Single source of truth for admin operations

#### Admin Badge
- **Where**: Profile screen
- **Features**:
  - Golden badge with verified icon
  - Shows admin status visually
  - Only displays for admin users
- **Why**: Quick visual indicator of admin privilege level

---

### 3. Rules & Prizes System ⭐ NEW

#### Rules & Prizes Screen (`lib/screens/rules_and_prizes_screen.dart`)
- **Purpose**: Full-screen detailed game rules reference
- **Features**:
  - 4-tab navigation:
    1. **Quick Rules**: Bullet-point summary
    2. **Full Rules**: Detailed rule sections with examples
    3. **Prizes**: Available rewards and point values
    4. **FAQs**: Frequently asked questions
  - Pinned header with game name
  - Gradient background (Material 3)
  - Searchable content
  - Smooth tab transitions
- **Why**: Provides comprehensive rules reference accessible anytime
- **Route**: `/rules-and-prizes`
- **Generic Design**: Works with any game type by passing different `GameRules`

#### Rules Preview Sheet (`lib/screens/rules_preview_sheet.dart`)
- **Purpose**: Quick bottom-sheet preview shown before game starts
- **Features**:
  - Draggable bottom sheet
  - Quick rules summary
  - "View Full Rules" button (navigates to full screen)
  - "Start Game" callback button
  - Dismissible design
- **Why**: Quick onboarding without overwhelming players
- **Usage**: `showRulesPreviewSheet(context, gameRules, onStartGame: callback)`

#### Game Rules Model (`lib/models/game_rules.dart`)
- **Purpose**: Data structure for any game's rules
- **Classes**:
  - `GameRules`: Main container with game metadata
  - `RuleSection`: Structured rules with title, description, bullets, examples
  - `Prize`: Reward definition with points and icons
  - `FAQ`: Question/answer pairs
- **Why**: Reusable, generic structure for any game type
- **Pre-configured**: `monopolyGameRules` with complete Monopoly rules

#### Integration Points
- **Monopoly Board**: Shows preview on game start
- **Game Lobby**: Access full rules before playing
- **Game Help Menu**: "?" icon for mid-game access
- **Why**: Rules always accessible when players need them

---

### 4. Image Management & Firebase Storage ⭐ NEW

#### Storage Service (`lib/services/storage_service.dart`)
- **Purpose**: Firebase Storage integration for image uploads
- **Features**:
  - Upload profile pictures: `uploadProfilePicture()`
  - Upload multiple images: `uploadMultipleImages()`
  - Delete images: `deleteImage()`
  - Error handling with detailed messages
  - Web and mobile compatibility
  - 5MB file size limit
- **Why**: Centralized image handling across app
- **Bucket**: `roberts-web-apps.firebasestorage.app`

#### Image Upload Screen (`lib/screens/image_upload_screen.dart`)
- **Purpose**: Upload multiple images from camera/gallery
- **Features**:
  - Gallery picker (multiple images)
  - Image preview before upload
  - Category selection (general, review, checkin, event)
  - Progress feedback
  - Error messages
  - Delete uploaded images
- **Why**: Lets users share photos related to businesses
- **Route**: `/upload`

#### Profile Picture Uploader Widget (`lib/widgets/profile_picture_uploader.dart`)
- **Purpose**: Dedicated component for profile picture management
- **Features**:
  - Display current profile picture or initial
  - Upload new profile picture
  - Replace existing photo
  - Loading state feedback
- **Why**: Consistent profile picture handling across app

#### Profile Screen Updates (`lib/screens/profile_screen.dart`)
- **Purpose**: User profile display and management
- **Features**:
  - Profile picture (uploaded or initial)
  - User information display
  - Admin badge (if user is admin)
  - "My Images" section with gallery
  - Upload new images button
  - Delete image functionality
- **Why**: Central hub for user profile and photos
- **Route**: `/profile`

#### Firestore Storage Integration
- **Collection**: `users/{uid}/images/`
- **Metadata Stored**:
  - Image URL
  - Upload timestamp
  - Category
  - File size
- **Why**: Tracks images and associates with users

---

### 5. Game Modes

#### Monopoly Board Screen (`lib/screens/monopoly_board_screen.dart`)
- **Purpose**: Main Monopoly game experience
- **Features**:
  - Monopoly board visualization
  - Business properties from Bellevue area
  - Player tracking
  - QR scanner for location validation
  - Rules and prizes access
- **Why**: Core gameplay mechanics
- **Route**: `/monopolyBoard`

#### Casual Games Lobby (`lib/screens/casual_games_lobby_screen.dart`)
- **Purpose**: Selection screen for casual game modes
- **Features**:
  - Browse available games
  - Game descriptions
  - Difficulty levels
  - Quick start buttons
- **Why**: Entry point for non-Monopoly games
- **Route**: `/CasualGamesLobbyScreen`

#### Play Session Screen (`lib/screens/play_session_screen.dart`)
- **Purpose**: Active game session management
- **Features**:
  - Current game state
  - Player scores
  - Turn management
  - Real-time updates
- **Why**: Tracks ongoing game progress

#### Instructions Screen (`lib/screens/instructions_screen.dart`)
- **Purpose**: Game tutorials and how-to guides
- **Features**:
  - Step-by-step instructions
  - Visual guidance
  - Game mechanics explanation
- **Why**: Helps new players learn gameplay
- **Route**: `/instructions`

---

### 6. Location & Business Features

#### Home Screen / Map Screen (`lib/screens/home_screen.dart`)
- **Purpose**: Map view of Bellevue area with businesses
- **Features**:
  - Interactive map with business markers
  - Location-based gameplay
  - Real-time location tracking
  - Business filtering
- **Why**: Location is core to the Monopoly experience
- **Route**: `/` (authenticated home)

#### Business List Screen (`lib/screens/business_list_screen.dart`)
- **Purpose**: Browse all businesses in game
- **Features**:
  - Searchable business list
  - Filtering by category
  - Business details preview
  - Sorting options
- **Why**: Alternative to map view for business discovery
- **Route**: `/businesses`

#### Business Detail Screen (`lib/screens/business_detail_screen.dart`)
- **Purpose**: Detailed business information
- **Features**:
  - Business name, address, phone
  - Opening hours
  - Monopoly property details (color, rent, etc.)
  - User reviews and check-ins
  - Business images
  - Location on map
- **Why**: Complete business information for players
- **Route**: `/business/:id`

#### Rewards Nearby Screen (`lib/screens/rewards_nearby_screen.dart`)
- **Purpose**: Display nearby rewards and businesses
- **Features**:
  - Location-based reward discovery
  - Nearby business listings
  - Distance calculations
  - Real-time filtering
- **Why**: Encourages exploration and local business visits
- **Route**: `/rewards-nearby`

#### Boulevard Partners Screen (`lib/screens/boulevard_partners_screen.dart`)
- **Purpose**: Featured business partners
- **Features**:
  - Partner business listings
  - Special offers
  - Partnership benefits
- **Why**: Highlights key business relationships

---

### 7. Player Progression & Engagement

#### Leaderboard Screen (`lib/screens/leaderboard_screen.dart`)
- **Purpose**: Player rankings and statistics
- **Features**:
  - Top players by score
  - Ranking calculation
  - Historical rankings
  - Player statistics
  - Time period filters (daily, weekly, all-time)
- **Why**: Motivates competitive play and engagement
- **Route**: `/leaderboard`

#### Achievements Screen (`lib/screens/achievements_screen.dart`)
- **Purpose**: Track player accomplishments
- **Features**:
  - Achievement badges
  - Progress tracking
  - Unlock conditions
  - Rewards tied to achievements
- **Why**: Gamification element for retention

#### Check-in History Screen (`lib/screens/checkin_history_screen.dart`)
- **Purpose**: View personal location history
- **Features**:
  - List of checked-in businesses
  - Timeline view
  - Business details
  - Statistics (total check-ins, unique businesses)
- **Why**: Helps players track their exploration
- **Route**: `/checkin-history`

#### Prizes Screen (`lib/screens/prizes_screen.dart`)
- **Purpose**: Rewards catalog
- **Features**:
  - Available prizes
  - Point requirements
  - Redemption tracking
  - Category filtering
- **Why**: Shows incentives for gameplay

---

### 8. User Settings & Account

#### Profile Screen (`lib/screens/profile_screen.dart`)
- **Purpose**: User profile management
- **Features**: (see Image Management section)
- **Route**: `/profile`

#### Settings Screen (`lib/screens/settings_screen.dart`)
- **Purpose**: App preferences and configuration
- **Features**:
  - Sound/music toggle (via audio provider)
  - Notification settings
  - Privacy settings
  - App information
  - Help and support links
- **Why**: Customizes user experience

#### My Account Options Screen (`lib/screens/my_account_options_screen.dart`)
- **Purpose**: Account-related actions
- **Features**:
  - Edit profile
  - Change password
  - Privacy settings
  - Delete account option
  - Logout
- **Why**: Central account management hub

#### FAQ Screen (`lib/screens/faq_screen.dart`)
- **Purpose**: App help and common questions
- **Features**:
  - Searchable FAQ
  - Topic categories
  - Helpful links
- **Why**: Self-service support

#### Game Settings Screen (`lib/screens/game_settings_screen.dart`)
- **Purpose**: Game-specific configuration
- **Features**:
  - Difficulty selection
  - Game variant options
  - Time limits
  - House rules toggle
- **Why**: Customizes gameplay experience

---

### 9. QR Code & Validation

#### QR Scanner Overlay (`lib/screens/qr_scanner_overlay.dart`)
- **Purpose**: Scan QR codes for business validation
- **Features**:
  - Camera-based QR scanning
  - Visual scanner frame
  - Validation feedback
  - Error handling
- **Why**: Validates physical business visits in location-based game

---

### 10. Core Infrastructure

#### Authentication Service (`lib/services/auth_service.dart`)
- **Purpose**: Firebase Auth wrapper
- **Features**:
  - Login/logout
  - Registration
  - Password reset
  - Email verification
  - Anonymous sign-in
  - Session management
- **Why**: Secure user authentication

#### Firestore Service (`lib/services/firestore_service.dart`)
- **Purpose**: Firestore database operations
- **Features**:
  - User data persistence
  - Real-time updates
  - Query operations
  - Data synchronization
- **Why**: Backend data storage and sync

#### Config Service (`lib/services/config_service.dart`)
- **Purpose**: App configuration management
- **Features**:
  - Load city configurations
  - Business listings
  - Game rules from Firebase
  - Dynamic configuration updates
- **Why**: Centralized configuration source

#### Location Service (`lib/services/location_service.dart`)
- **Purpose**: GPS and location tracking
- **Features**:
  - Get current location
  - Permission handling
  - Location accuracy
  - Background location (if enabled)
- **Why**: Location-based gameplay mechanics

#### Analytics Service (`lib/services/analytics_service.dart`)
- **Purpose**: Track user engagement
- **Features**:
  - Event logging
  - User analytics
  - Gameplay metrics
- **Why**: Understand user behavior

#### Device Service (`lib/services/device_service.dart`)
- **Purpose**: Device-specific operations
- **Features**:
  - Device identification
  - Platform detection
  - System info
- **Why**: Handle platform-specific features

---

## State Management (Riverpod)

### Key Providers

- **authStateProvider**: Current authenticated user
- **authServiceProvider**: Auth service instance
- **userDataProvider**: User profile and settings
- **businessesProvider**: Business listings
- **adminProvider**: Admin status and privileges
- **playerProvider**: Current player state
- **gameStateProvider**: Active game state
- **locationProvider**: Current user location
- **audioProvider**: Audio settings

---

## Security & Permissions

### Firestore Security Rules
- Users can only read/write their own data
- Anonymous users get admin privileges for testing
- Admin-only collections restricted to admins
- Public data (businesses) readable by all

### Required Permissions
- **Android/iOS**:
  - Camera (QR scanning)
  - Location Services (GPS)
  - Storage (image upload)
  - Photos/Gallery (image selection)
- **Web**: Camera and geolocation APIs

### Firebase Configuration
- **Project**: `roberts-web-apps`
- **Auth**: Email/Password + Anonymous
- **Storage Bucket**: `roberts-web-apps.firebasestorage.app`
- **Firestore**: Cloud Firestore database

---

## Design System

### Theme
- **Material 3** design language
- **Glassmorphic** components with frosted glass effect
- **Gradient backgrounds** for visual depth
- **Golden accents** for premium elements (admin badge, highlights)
- **Responsive design** for mobile, tablet, and web

### Key Widgets
- `GlassmorphicCard`: Reusable frosted glass card
- `GradientBackground`: Gradient background wrapper
- `ResponsiveFormContainer`: Mobile-responsive forms
- `MainScaffold`: App structure wrapper

---

## Recent Improvements (This Session)

✅ **Added**:
1. Generic Rules & Prizes system (works with any game)
2. Admin privilege system with anonymous user support
3. Firebase Storage integration for profile/user images
4. Image gallery on profile screen
5. Admin badge visual indicator
6. Rules preview sheet for game start onboarding
7. Comprehensive rules & FAQs system

✅ **Fixed**:
- Removed Google Sign-In
- Fixed type casting issues in routing
- Added proper imports for all services
- Clean build with no critical errors

---

## Future Enhancement Opportunities

- 🔮 Multiplayer real-time gameplay
- 🔮 In-app messaging/chat between players
- 🔮 Customizable game rules (player-created rulesets)
- 🔮 Tournament mode with brackets
- 🔮 Seasonal events and challenges
- 🔮 Business owner dashboard
- 🔮 Push notifications for nearby rewards
- 🔮 Social sharing integration
- 🔮 AR experience for business visits
- 🔮 Video tutorials in rules system

---

## Testing Checklist

- ✅ Admin system works (set user as admin)
- ✅ Rules preview shows on game start
- ✅ Full rules screen tabs navigate correctly
- ✅ Image upload saves to Firebase Storage
- ✅ Profile picture displays correctly
- ✅ Monopoly rules pre-configured
- ✅ Navigation routes all functional
- ✅ Anonymous login grants admin automatically

---

**Last Updated**: January 6, 2026  
**Version**: 2.1  
**Status**: Production Ready
