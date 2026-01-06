# Authentication Flow Diagrams

## Complete Authentication System Architecture

---

## 1. Registration & Email Verification Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER REGISTRATION FLOW                      │
└─────────────────────────────────────────────────────────────────┘

                           Landing Screen
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │  "Create Account" Button │
                    └──────────────┬──────────┘
                                   │
                                   ▼
                        RegistrationScreen
                    (Email, Password, Username)
                                   │
                    ┌──────────────┴──────────────┐
                    │  Validation Checks          │
                    │  • Email format valid       │
                    │  • Password ≥ 6 chars       │
                    │  • Username provided        │
                    └──────────────┬──────────────┘
                                   │
                            ✓ If all valid
                                   │
                                   ▼
                    ┌──────────────────────────────┐
                    │  1. Create User in Firebase  │
                    │  2. Add User to Firestore    │
                    │  3. Send Verification Email  │
                    └──────────────┬───────────────┘
                                   │
                                   ▼
                      ┌─────────────────────────────────┐
                      │  EmailVerificationScreen        │
                      │  ┌────────────────────────────┐ │
                      │  │ • Display email address    │ │
                      │  │ • Animated email icon      │ │
                      │  │ • Instructions             │ │
                      │  │ • Resend Email button      │ │
                      │  │ • Check verification btn   │ │
                      │  └────────────────────────────┘ │
                      └─────────────┬──────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
              ┌─────▼─────┐            ┌──────────▼──────┐
              │ Manual     │            │ Auto Check      │
              │ Check      │            │ Every 3 Seconds │
              └─────┬──────┘            └──────────┬──────┘
                    │                              │
         ┌──────────┴──────────────────────────────┘
         │
         ▼
    ┌────────────────────────────────────┐
    │ Reload User & Check emailVerified  │
    └────────────────────┬───────────────┘
         │
         ├─ If NOT Verified ─────────────────┐
         │   • Show error message             │
         │   • Stay on verification screen    │
         │                                    │
         └─ If VERIFIED ──────────────────┐
                                          │
                                   ┌──────▼──────┐
                                   │ Firebase    │
                                   │ Auto        │
                                   │ Authenticates
                                   └──────┬──────┘
                                          │
                                          ▼
                        ┌──────────────────────────┐
                        │ Success Toast/Notification│
                        │ "Email verified!"         │
                        └──────────────┬────────────┘
                                       │
                              (500ms delay)
                                       │
                                       ▼
                            ┌──────────────────┐
                            │  Home Screen     │
                            │  (Authenticated) │
                            └──────────────────┘
```

---

## 2. Password Reset Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     PASSWORD RESET FLOW                          │
└─────────────────────────────────────────────────────────────────┘

                           LoginScreen
                                 │
                                 ▼
                  ┌───────────────────────────┐
                  │ "Forgot password?" Link    │
                  └──────────────┬─────────────┘
                                 │
                                 ▼
                      PasswordResetScreen
                                 │
                    ┌────────────┴────────────┐
                    │ Email Input Field        │
                    │ • Validation (required)  │
                    │ • Email format check     │
                    └────────────┬────────────┘
                                 │
                            ✓ Valid
                                 │
                    ┌────────────┴────────────┐
                    │ Send Password Reset      │
                    │ Email via Firebase       │
                    └────────────┬────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │ Firebase Handles:        │
                    │ • Generate reset link    │
                    │ • Send email             │
                    │ • Link expires in 1 hour │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │  Success Screen          │
                    │  ┌────────────────────┐  │
                    │  │ ✓ Email Sent       │  │
                    │  │ • Email displayed  │  │
                    │  │ • Check inbox      │  │
                    │  │ • Check spam       │  │
                    │  │ • Back to Login    │  │
                    │  └────────────────────┘  │
                    └──────────────┬───────────┘
                                   │
                                   ▼
                        ┌──────────────────────┐
                        │ User Clicks Email    │
                        │ Reset Link           │
                        └──────────────┬───────┘
                                       │
                                       ▼
                        ┌──────────────────────────┐
                        │ Browser Opens            │
                        │ Firebase Password Reset  │
                        │ (User sets new password) │
                        └──────────────┬───────────┘
                                       │
                                       ▼
                        ┌──────────────────────────┐
                        │ Password Changed         │
                        │ (in Firebase)            │
                        └──────────────┬───────────┘
                                       │
                                       ▼
                            ┌──────────────────┐
                            │ Return to App    │
                            └────────────┬─────┘
                                        │
                                        ▼
                            ┌──────────────────┐
                            │ LoginScreen      │
                            │ • Email          │
                            │ • New Password   │
                            │ • Login Button   │
                            └────────────┬─────┘
                                        │
                                        ▼
                            ┌──────────────────┐
                            │ HomeScreen       │
                            │ (Authenticated)  │
                            └──────────────────┘
```

---

## 3. Login with Email Verification Check

```
┌─────────────────────────────────────────────────────────────────┐
│                      LOGIN VERIFICATION FLOW                     │
└─────────────────────────────────────────────────────────────────┘

                           LoginScreen
                                 │
                    ┌────────────┴────────────┐
                    │ Email & Password Input   │
                    │ • Email validation       │
                    │ • Password validation    │
                    │ • Forgot password? link  │
                    └────────────┬────────────┘
                                 │
                            ✓ Valid
                                 │
                    ┌────────────┴────────────┐
                    │ Firebase SignIn          │
                    │ signInWithEmailPassword  │
                    └────────────┬────────────┘
                                 │
                ┌────────────────┴────────────────┐
                │ Check user.emailVerified        │
                └────────────────┬────────────────┘
                                 │
                ┌────────────────┴────────────────┐
                │                                 │
         ┌──────▼──────┐               ┌──────────▼────────┐
         │  Verified   │               │   Not Verified    │
         │     ✓       │               │        ✗          │
         └──────┬──────┘               └──────────┬────────┘
                │                                 │
                │                    ┌────────────┴────────────┐
                │                    │ Show Error Message:     │
                │                    │ "Please verify email    │
                │                    │ before logging in."     │
                │                    └────────────┬────────────┘
                │                                 │
                │                                 ▼
                │                    ┌────────────────────────┐
                │                    │ Redirect to Email      │
                │                    │ Verification Screen    │
                │                    └────────────┬───────────┘
                │                                 │
                │                                 ▼
                │                    ┌────────────────────────┐
                │                    │ User verifies email    │
                │                    │ (resend or check)      │
                │                    └────────────┬───────────┘
                │                                 │
                │                                 ▼
                │                    ┌────────────────────────┐
                │                    │ Try login again        │
                │                    └────────────┬───────────┘
                │                                 │
                │                    ┌────────────┘
                │                    │ (Verified now)
                │                    │
                └────────────────────┴────────────┐
                                                  │
                                                  ▼
                                    ┌─────────────────────┐
                                    │ Navigation to Home  │
                                    │ context.go('/')     │
                                    └─────────────────────┘
                                                  │
                                                  ▼
                                    ┌─────────────────────┐
                                    │  HomeScreen         │
                                    │ (Fully Authenticated)
                                    └─────────────────────┘
```

---

## 4. Resend Email Verification with Cooldown

```
┌──────────────────────────────────────────────────────────┐
│         RESEND VERIFICATION EMAIL FLOW                    │
└──────────────────────────────────────────────────────────┘

        EmailVerificationScreen
                  │
                  ▼
    ┌────────────────────────────┐
    │ "Resend Verification Email" │
    │ Button                       │
    └────────────┬────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
   ┌────▼────┐      ┌─────▼──────┐
   │ Cooldown │      │ Not on      │
   │ Active   │      │ Cooldown    │
   │ (>0 sec) │      │ (0 sec)     │
   └────┬────┘      └─────┬──────┘
        │                  │
   ┌────▼────────┐   ┌─────▼──────────────┐
   │ Button:     │   │ Send Email via     │
   │ "Resend     │   │ Firebase           │
   │ (60s)"      │   │ user.sendEmailVer..│
   │ Disabled    │   └──────────┬─────────┘
   └────┬────────┘              │
        │              ┌────────┴────────┐
   ┌────▼────────────┐ │ Start 60-Second │
   │ Countdown:      │ │ Cooldown Timer  │
   │ 60 → 59 → ...   │ │ (Decrementing)  │
   │ every 1 second  │ └────────────┬────┘
   └────┬────────────┘              │
        │                    ┌──────┴─────┐
        │                    │ Show: "Re- │
        │                    │ send (58s)"│
        │                    └──────┬─────┘
        │                    (repeats every 1s)
        │                           │
        │              ┌────────────┴──────┐
        │              │ Countdown reaches │
        │              │ 0 seconds         │
        │              └────────────┬──────┘
        │                           │
        └───────────────────────────┴──────┐
                                           │
                                           ▼
                           ┌───────────────────────┐
                           │ Button Enabled Again  │
                           │ "Resend Email"        │
                           └───────────────────────┘
```

---

## 5. Auto-Check Email Verification Loop

```
┌────────────────────────────────────────────────────────┐
│    AUTO-CHECK EMAIL VERIFICATION (Every 3 Seconds)      │
└────────────────────────────────────────────────────────┘

        EmailVerificationScreen
             Initialized
                  │
                  ▼
    ┌─────────────────────────────┐
    │ Start Auto-Check Loop       │
    │ while (mounted &&            │
    │   !emailVerified)            │
    └─────────────┬───────────────┘
                  │
                  ▼
    ┌──────────────────────────┐
    │ Wait 3 Seconds           │
    │ Future.delayed(3 seconds)│
    └─────────────┬────────────┘
                  │
                  ▼
    ┌──────────────────────────────────┐
    │ If mounted (screen still visible)│
    └─────────────┬────────────────────┘
                  │
                  ▼
    ┌──────────────────────────────────┐
    │ Reload User from Firebase        │
    │ user.reload()                    │
    └─────────────┬────────────────────┘
                  │
        ┌─────────┴──────────┐
        │                    │
   ┌────▼─────┐        ┌─────▼────────┐
   │ EmailVerified     │ Not Verified  │
   │ = true            │ = false       │
   │                   │               │
   │ ✓ BREAK LOOP      │ Continue Loop │
   │   Verified!       │ (Wait 3s, try │
   └────┬──────┘       │ again)        │
        │              └─────┬────────┘
        │                    │
        │              (repeats until
        │               verified or
        │               user leaves)
        │
        ▼
    ┌────────────────────────────────┐
    │ Show Success Toast             │
    │ "✓ Email verified!"            │
    └─────────────┬──────────────────┘
                  │
         (500ms delay)
                  │
                  ▼
    ┌────────────────────────────────┐
    │ Auto-Navigate to Home          │
    │ context.go('/')                │
    └────────────────────────────────┘
```

---

## 6. State Management & Navigation

```
┌──────────────────────────────────────────────────────────┐
│           AUTHENTICATION STATE FLOW (GoRouter)            │
└──────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────┐
    │ authStateProvider (Riverpod)    │
    │ ┌───────────────────────────┐   │
    │ │ watch authStateProvider   │   │
    │ │ = Firebase.authStateChanges   │
    │ │ Emits: User? (null when out)  │
    │ └───────────────────────────┘   │
    └────────────┬────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
   ┌────▼────┐      ┌─────▼──────┐
   │ user ≠  │      │ user == null│
   │  null   │      │             │
   │ LOGGED  │      │ LOGGED OUT  │
   │  IN     │      │             │
   └────┬────┘      └─────┬──────┘
        │                 │
   ┌────▼────────┐   ┌─────▼────────────┐
   │ Check email │   │ Redirect to:     │
   │ verified?   │   │ • Landing        │
   │             │   │ • Login          │
   └────┬────────┘   │ • Register       │
        │            │ • Splash         │
   ┌────┴────────┐   └──────────────────┘
   │             │
   │ ✓ Yes       │ ✗ No
   │             │
 ┌─▼────┐   ┌────▼──────────┐
 │ Home │   │ Email Verifi- │
 │      │   │ cation Screen  │
 └──────┘   └────────────────┘

GoRouter Redirect Logic:
┌─────────────────────────────────────────────────┐
│ if (isAuthenticated) {                          │
│   if (onLoginPage || onRegisterPage)            │
│     redirect to HOME                            │
│   else                                          │
│     allow current route                         │
│ } else {                                        │
│   if (onPublicRoute)                            │
│     allow current route                         │
│   else                                          │
│     redirect to LANDING                         │
│ }                                               │
└─────────────────────────────────────────────────┘
```

---

## 7. Error Handling Flows

```
┌───────────────────────────────────────────────────────┐
│        ERROR HANDLING IN AUTHENTICATION                │
└───────────────────────────────────────────────────────┘

        FirebaseAuthException
             Caught
                │
                ▼
    ┌───────────────────────────┐
    │ Get Error Code            │
    │ e.code (Firebase enum)    │
    └─────────────┬─────────────┘
                  │
        ┌─────────┴────────────┬──────────┬──────────┐
        │                      │          │          │
   ┌────▼──────┐       ┌───────▼──┐ ┌────▼────┐ ┌──▼──┐
   │ user-not  │       │ wrong-   │ │ weak-   │ │ too-│
   │ found     │       │ password │ │ password│ │many │
   │           │       │          │ │         │ │req. │
   │ "No user  │       │ "Incor-  │ │ "Pass-  │ │"Too │
   │ found"    │       │ rect     │ │ word    │ │many │
   │           │       │ password"│ │ weak"   │ │ atts"
   └───────────┘       └──────────┘ └─────────┘ └─────┘

                Display User-Friendly Error Message
                     in SnackBar
                     Duration: 3-5 seconds
                     Background Color: Red


                    ┌────────────────────┐
                    │ User can retry     │
                    │ or take alternative│
                    │ action (e.g.,      │
                    │ forgot password?)  │
                    └────────────────────┘
```

---

## 8. Complete App Entry Flow

```
┌────────────────────────────────────────────────────────────┐
│             COMPLETE APPLICATION ENTRY                      │
└────────────────────────────────────────────────────────────┘

        App Starts (main.dart)
               │
               ▼
    ┌─────────────────────┐
    │ Firebase Initialize │
    │ ConfigService Init  │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │ ProviderScope       │
    │ Riverpod setup      │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │ MaterialApp.router  │
    │ with GoRouter       │
    └──────────┬──────────┘
               │
               ▼
    ┌──────────────────────────┐
    │ appRouterProvider        │
    │ ┌──────────────────────┐ │
    │ │ watch authStateProvider
    │ │ isAuthenticated?      │ │
    │ └────┬──────────────────┘ │
    │      │                    │
    │  ┌───┴────┐               │
    │  │         │               │
    │ YES      NO                │
    │  │         │               │
    │  ▼         ▼               │
    │ Home    Landing            │
    │  │         │               │
    │  ▼         ▼               │
    │ Shell  Public Routes       │
    │ Nav    (Login, Register)   │
    └────────────────────────────┘
               │
               ▼
        SplashScreen
        (Default route)
               │
        (Auto-checks auth
         after splash delay)
               │
        ┌──────┴──────┐
        │             │
      YES           NO
        │             │
    ┌───▼──┐      ┌───▼─────┐
    │ Home │      │ Landing  │
    └──────┘      └──────────┘
                        │
                        ▼
                  ┌──────────────┐
                  │ Welcome or   │
                  │ Login/Register
                  └──────────────┘
```

---

## Summary

These diagrams show the complete flow of:
1. **Registration** → Email Verification
2. **Password Reset** → Email Link → New Password
3. **Login** → Email Check → Home or Verification
4. **Verification Loop** → Auto-check every 3 seconds
5. **Resend Email** → 60-second cooldown
6. **Error Handling** → User-friendly messages
7. **Navigation** → GoRouter state management
8. **App Entry** → Complete initialization flow

All flows are now fully implemented and production-ready! ✅
