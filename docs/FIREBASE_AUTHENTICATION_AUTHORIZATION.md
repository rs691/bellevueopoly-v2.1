# Firebase Authentication & Authorization for Image Uploads

## How Firebase Knows Users Are Authorized

Firebase uses **authentication tokens** and **security rules** to verify user authorization automatically. This document explains the complete flow.

---

## Authentication Flow

### 1. User Logs In
When a user signs in through your app:

```dart
// From login_screen.dart
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

### 2. Firebase Auth Creates JWT Token
- Firebase Auth automatically generates a **JWT (JSON Web Token)**
- This token contains:
  - User ID (`uid`)
  - Email address
  - Expiration time
  - Custom claims (if any)
- The token is stored locally and **automatically attached to ALL Firebase requests**

### 3. Storage Upload Request
When uploading an image:

```dart
// From storage_service.dart
final user = _auth.currentUser;  // ← Has the auth token
final ref = _storage.ref().child('profile_pictures/${user.uid}/image.jpg');
await ref.putFile(file);  // ← Token is sent automatically by Firebase SDK
```

**Important:** You never manually send the token - the Firebase SDK does it for you!

### 4. Firebase Storage Validates Request
Firebase Storage checks the security rules in [storage.rules](storage.rules):

```javascript
// Profile Pictures - users can only upload/delete their own
match /profile_pictures/{userId}/{fileName} {
  allow read: if true;  // Anyone can view profile pictures
  allow write: if isOwner(userId) && isValidImage();
  allow delete: if isOwner(userId);
}

function isOwner(userId) {
  return isAuthenticated() && request.auth.uid == userId;
  //     ↑ Token exists         ↑ Token's user ID matches path
}

function isValidImage() {
  return request.resource.size < 5 * 1024 * 1024  // Max 5MB
      && request.resource.contentType.matches('image/.*');
}
```

---

## The Security Check Process

When a user uploads to `profile_pictures/abc123/photo.jpg`, Firebase validates:

| Check | Rule | What It Does |
|-------|------|--------------|
| 1️⃣ Authentication | `isAuthenticated()` | Verifies `request.auth` exists (valid token) |
| 2️⃣ Authorization | `request.auth.uid == userId` | Confirms `abc123` matches the token's user ID |
| 3️⃣ File Validation | `isValidImage()` | Checks file size (<5MB) and type (image/*) |

**If ANY check fails → 403 Forbidden Error**

---

## Why This Is Secure

### ❌ Users Cannot Fake Uploads to Other Folders

```dart
// Attempting to upload to someone else's folder:
_storage.ref()
  .child('profile_pictures/SOMEONE_ELSE_UID/hack.jpg')
  .putFile(file);

// ❌ BLOCKED by Firebase
// Reason: request.auth.uid != "SOMEONE_ELSE_UID"
```

### ✅ Users Can Only Upload to Their Own Folder

```dart
// Using current user's ID:
final user = FirebaseAuth.instance.currentUser;
_storage.ref()
  .child('profile_pictures/${user.uid}/photo.jpg')
  .putFile(file);

// ✅ ALLOWED by Firebase
// Reason: request.auth.uid == user.uid
```

---

## Storage Rules Breakdown

### Profile Pictures
```javascript
match /profile_pictures/{userId}/{fileName} {
  allow read: if true;  // Public read access
  allow write: if isOwner(userId) && isValidImage();
  allow delete: if isOwner(userId);
}
```

- **Path:** `profile_pictures/{userId}/{fileName}`
- **Read:** Anyone (for displaying profile pictures)
- **Write:** Only the user whose `uid` matches `{userId}`
- **Delete:** Only the owner

### User Uploads
```javascript
match /user_uploads/{userId}/{category}/{fileName} {
  allow read: if true;
  allow write: if isOwner(userId) && isValidImage();
  allow delete: if isOwner(userId);
}
```

- **Path:** `user_uploads/{userId}/{category}/{fileName}`
- **Categories:** general, review, checkin, event
- **Same permissions as profile pictures**

---

## Firestore Authorization (Same Concept)

Our [firestore.rules](firestore.rules) use the same authentication mechanism:

```javascript
// Images collection
match /images/{imageId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null 
               && request.resource.data.userId == request.auth.uid;
  allow update, delete: if request.auth != null 
                       && resource.data.userId == request.auth.uid;
}
```

**Key Points:**
- `request.auth` - Contains the authentication token data
- `request.auth.uid` - The authenticated user's ID
- `request.resource.data` - The document being created/updated
- `resource.data` - The existing document data

### Example: Creating an Image Document

```dart
// From storage_service.dart
await _firestore.collection('images').add({
  'userId': user.uid,  // ← Must match request.auth.uid
  'imageUrl': downloadUrl,
  'category': category,
  'uploadedAt': FieldValue.serverTimestamp(),
});
```

**Security Check:**
```javascript
request.resource.data.userId == request.auth.uid
// ↑ userId in new doc must match token's uid
```

---

## The Token Is Automatic

You **never** manually pass authentication tokens. The Firebase SDK handles everything:

```dart
// ✅ This is all you need
final user = FirebaseAuth.instance.currentUser;

// Token is automatically:
// 1. Generated on sign-in
// 2. Stored securely
// 3. Refreshed before expiration
// 4. Attached to every Firebase request
// 5. Validated by security rules
```

---

## Security Rule Variables

### `request.auth`
Available in all Firebase Security Rules. Contains:

| Property | Description | Example |
|----------|-------------|---------|
| `request.auth.uid` | User's unique ID | `"abc123xyz"` |
| `request.auth.token.email` | User's email | `"user@example.com"` |
| `request.auth.token.email_verified` | Email verified? | `true` / `false` |
| `request.auth.token` | Custom claims | `{ admin: true }` |

### Storage-Specific Variables

| Variable | Description |
|----------|-------------|
| `request.resource` | The resource being uploaded |
| `request.resource.size` | File size in bytes |
| `request.resource.contentType` | MIME type (e.g., "image/jpeg") |

### Firestore-Specific Variables

| Variable | Description |
|----------|-------------|
| `request.resource.data` | Document data being created/updated |
| `resource.data` | Existing document data |

---

## Common Security Patterns

### Pattern 1: User Owns Resource
```javascript
allow write: if request.auth.uid == resource.data.userId;
```

### Pattern 2: Authenticated Users Only
```javascript
allow read, write: if request.auth != null;
```

### Pattern 3: Public Read, Owner Write
```javascript
allow read: if true;
allow write: if request.auth.uid == userId;
```

### Pattern 4: File Size Validation
```javascript
allow write: if request.resource.size < 5 * 1024 * 1024; // 5MB
```

### Pattern 5: Content Type Validation
```javascript
allow write: if request.resource.contentType.matches('image/.*');
```

---

## Testing Authorization

### Test Unauthorized Upload (Should Fail)
```dart
try {
  // Try to upload to someone else's folder
  await _storage.ref()
    .child('profile_pictures/wrong-user-id/hack.jpg')
    .putFile(file);
} catch (e) {
  print('❌ Expected error: $e');
  // Should get: FirebaseException: User does not have permission
}
```

### Test Authorized Upload (Should Succeed)
```dart
try {
  final user = FirebaseAuth.instance.currentUser!;
  await _storage.ref()
    .child('profile_pictures/${user.uid}/photo.jpg')
    .putFile(file);
  print('✅ Upload successful');
} catch (e) {
  print('❌ Unexpected error: $e');
}
```

---

## Debugging Authorization Issues

### Issue: "Permission Denied" Error

**Check List:**
1. ✅ User is authenticated: `FirebaseAuth.instance.currentUser != null`
2. ✅ Rules deployed: `npx firebase deploy --only storage`
3. ✅ Path matches rules: User ID in path matches token
4. ✅ File validation passes: Size < 5MB, is image type

### View Auth Token (for debugging)
```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final token = await user.getIdToken();
  print('Token: $token');
  print('UID: ${user.uid}');
  print('Email: ${user.email}');
}
```

### Test Rules in Firebase Console
1. Go to Firebase Console → Storage → Rules
2. Click "Rules Playground"
3. Test read/write operations with different user IDs

---

## Security Best Practices

### ✅ DO:
- Always use `${user.uid}` in storage paths
- Validate file size and type in rules
- Keep rules deployed: `npx firebase deploy --only storage,firestore`
- Test with different user accounts
- Use `request.auth.uid` for ownership checks

### ❌ DON'T:
- Trust client-side validation only
- Use predictable file names without user IDs
- Allow unlimited file sizes
- Skip contentType validation
- Store sensitive data in public paths

---

## Related Files

- [storage_service.dart](lib/services/storage_service.dart) - Upload logic
- [storage.rules](storage.rules) - Storage security rules
- [firestore.rules](firestore.rules) - Firestore security rules
- [firebase.json](firebase.json) - Firebase configuration
- [profile_picture_uploader.dart](lib/widgets/profile_picture_uploader.dart) - Profile pic upload widget
- [image_upload_screen.dart](lib/screens/image_upload_screen.dart) - Multi-image upload

---

## Summary

🔐 **Firebase Authorization = Authentication Token + Security Rules**

1. User logs in → Firebase creates JWT token
2. Token automatically attached to all requests
3. Security rules validate token and permissions
4. Upload succeeds or fails based on rules

**You write the rules, Firebase enforces them automatically!** 🚀
