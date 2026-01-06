# Admin System Setup Guide

## Overview
The admin system allows designated users to perform privileged operations like managing businesses and uploading business images. Anonymous/developer bypass users are automatically granted admin privileges for testing purposes.

## Auto-Admin for Anonymous Users
When a user signs in anonymously (developer bypass), they are automatically granted admin privileges:

```dart
// In FirestoreService.addUser()
if (user.isAnonymous) {
  await _db.collection('users').doc(user.uid).set({
    'email': 'anonymous@example.com',
    'username': 'Developer',
    'isAdmin': true,        // Auto-granted
    'isAnonymous': true,
    'createdAt': FieldValue.serverTimestamp(),
    // ... other fields
  });
}
```

## Admin Capabilities

### Firestore Rules
Admins have special permissions defined in `firestore.rules`:

```javascript
function isAdmin() {
  return request.auth != null && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}

// Business management (CRUD operations)
match /businesses/{businessId} {
  allow read: if true;
  allow write: if isAdmin();  // Only admins can create/update/delete
}
```

### Storage Rules
Admins can upload business images defined in `storage.rules`:

```javascript
function isAdmin() {
  return request.auth != null && 
         firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}

// Business images
match /business_images/{allPaths=**} {
  allow read: if true;
  allow write, delete: if isAdmin();  // Only admins can manage business images
}
```

## UI Indicators

### Profile Screen Admin Badge
The profile screen displays a prominent admin badge for admin users:

```dart
if (isAdmin) {
  Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.amber.withOpacity(0.2),
      border: Border.all(color: Colors.amber, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.verified_user, color: Colors.amber, size: 16),
        Text('ADMIN', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
      ],
    ),
  )
}
```

## Admin Service API

### Check Admin Status
```dart
final adminService = ref.read(adminServiceProvider);
final isAdmin = await adminService.isAdmin();
```

### Watch Admin Status (Stream)
```dart
final isAdmin = ref.watch(isAdminProvider);
isAdmin.when(
  data: (isAdmin) => isAdmin ? Text('You are admin') : Text('Regular user'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

### Grant Admin to User
```dart
await adminService.grantAdmin(userId);
```

### Revoke Admin from User
```dart
await adminService.revokeAdmin(userId);
```

### Get All Admins
```dart
final admins = await adminService.getAllAdmins();
```

## Testing Admin Features

### 1. Sign In Anonymously
1. Launch the app
2. Click "Developer Bypass" on the login screen
3. You will be automatically signed in as an anonymous user with admin privileges

### 2. Verify Admin Status
1. Navigate to the Profile screen
2. You should see the golden "ADMIN" badge next to your username
3. Check Firestore console to verify `isAdmin: true` in your user document

### 3. Test Business Management
As an admin, you can:
- Create new businesses
- Edit existing businesses
- Delete businesses
- Upload business images to `business_images/` folder

### 4. Test Image Upload
1. Navigate to the image upload screen
2. Select "Business" category (admin-only)
3. Upload images - they will be stored in `business_images/`
4. Regular users cannot upload to this category

## Security Considerations

### Firestore Security
- All admin checks use the `isAdmin()` helper function
- Admin status is stored in the user document and queried on every request
- Changing a user's admin status requires manual Firestore update or using AdminService

### Storage Security
- Business images path requires admin privileges
- User uploads (`user_uploads/`, `profile_pictures/`) don't require admin
- Cross-service rules allow Storage to query Firestore for admin status

### Revoking Admin
To revoke admin access:
```dart
final adminService = ref.read(adminServiceProvider);
await adminService.revokeAdmin(userId);
```

Or manually in Firestore console:
1. Open `users` collection
2. Find the user document
3. Set `isAdmin: false` or delete the field

## Deployment

### Deploy Rules
```bash
npx firebase deploy --only firestore,storage
```

### Verify Deployment
1. Check Firebase Console > Firestore > Rules
2. Verify `isAdmin()` helper function exists
3. Check Storage > Rules for similar verification

## Troubleshooting

### Admin Badge Not Showing
- Check Firestore: user document should have `isAdmin: true`
- Verify you're signed in (not signed out)
- Refresh the profile screen

### Can't Upload Business Images
- Verify admin status in Firestore
- Check Storage rules are deployed: `npx firebase deploy --only storage`
- Check browser console for specific error messages

### Anonymous User Not Auto-Admin
- Check FirestoreService.addUser() implementation
- Verify the user is signing in with anonymous auth
- Check Firestore console for `isAnonymous: true` field

## Future Enhancements
- Admin panel screen for managing users
- Bulk admin operations
- Admin activity logging
- Role-based permissions (super admin, moderator, etc.)
- Admin-only navigation items
