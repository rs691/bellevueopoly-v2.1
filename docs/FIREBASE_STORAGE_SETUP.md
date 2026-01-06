# Firebase Storage Setup - Image Upload & Profile Pictures

## Overview
This app uses Firebase Storage to store user-uploaded images and profile pictures.

## Storage Structure

### Profile Pictures
**Path:** `profile_pictures/{userId}/{timestamp}.jpg`
- Each user can upload their own profile picture
- Old profile pictures are automatically cleaned up
- Maximum size: 5MB
- Stored in user's personal folder

### User Uploads
**Path:** `user_uploads/{userId}/{category}/{timestamp}_{index}.jpg`
- Categories: `general`, `review`, `checkin`, `event`
- Multiple images supported
- Maximum size: 5MB per image
- Organized by user and category

### Business Images (Future)
**Path:** `business_images/{businessId}/{fileName}`
- For admin-uploaded business photos
- Requires admin permissions

## Components

### 1. StorageService (`lib/services/storage_service.dart`)
Main service for all storage operations:

```dart
final _storageService = StorageService();

// Upload profile picture
await _storageService.uploadProfilePicture(file);

// Upload multiple images
await _storageService.uploadMultipleImages(
  imageFiles: [file1, file2],
  category: 'review',
);

// Delete old profile pictures
await _storageService.deleteOldProfilePictures();
```

### 2. ProfilePictureUploader Widget (`lib/widgets/profile_picture_uploader.dart`)
Drop-in widget for profile picture management:

```dart
ProfilePictureUploader(
  currentPhotoUrl: user['photoURL'],
  userName: user['username'],
  onUploadComplete: () {
    // Refresh UI after upload
  },
)
```

Features:
- ✅ Displays current profile picture or initial
- ✅ Camera icon overlay for easy upload
- ✅ Loading indicator during upload
- ✅ Automatic Firestore update with new URL
- ✅ Updates Firebase Auth profile

### 3. ImageUploadScreen (`lib/screens/image_upload_screen.dart`)
Full screen for uploading multiple images:
- Select multiple images from gallery
- Choose category (general, review, checkin, event)
- Upload to Firebase Storage
- Real implementation (no longer a placeholder!)

## Where Images Are Stored

### Firebase Storage Bucket
```
roberts-web-apps.firebasestorage.app
```

### Firestore References
User document stores profile picture URL:
```json
{
  "users": {
    "{userId}": {
      "username": "PlayerName",
      "email": "player@example.com",
      "photoURL": "https://firebasestorage.googleapis.com/.../profile_pictures/...",
      "photoUpdatedAt": "timestamp"
    }
  }
}
```

## Security Rules (`storage.rules`)

```javascript
// Profile Pictures - users can only upload/delete their own
match /profile_pictures/{userId}/{fileName} {
  allow read: if true;  // Anyone can view
  allow write: if isOwner(userId) && isValidImage();
  allow delete: if isOwner(userId);
}

// User Uploads
match /user_uploads/{userId}/{category}/{fileName} {
  allow read: if true;
  allow write: if isOwner(userId) && isValidImage();
  allow delete: if isOwner(userId);
}
```

**Validations:**
- ✅ Max file size: 5MB
- ✅ Must be image type (`image/*`)
- ✅ User can only write to their own folder
- ✅ Public read access for display

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

Package added: `firebase_storage: ^12.5.0`

### 2. Deploy Storage Rules
```bash
npx firebase use roberts-web-apps
npx firebase deploy --only storage
```

### 3. Verify Storage Bucket
Check [firebase_options.dart](lib/firebase_options.dart):
- Storage bucket: `roberts-web-apps.firebasestorage.app`

### 4. Test Profile Picture Upload
1. Run the app
2. Navigate to Profile screen
3. Click camera icon on profile picture
4. Select an image
5. Image uploads and displays automatically

## Usage Examples

### Profile Screen
Profile picture now has upload capability:
- Tap camera icon to select new photo
- Automatic upload and update
- Old photos cleaned up automatically

### Image Upload Screen
Multiple image upload for reviews/check-ins:
1. Select category from dropdown
2. Pick multiple images
3. Upload all at once
4. Images stored in categorized folders

## File Size Limits
- **Per Image:** 5MB maximum
- **Recommended:** Compress images before upload for faster loading
- **Auto-compression:** Images are resized to 1024x1024 for profile pictures

## Cost Management
Firebase Storage costs are based on:
- **Storage:** $0.026/GB/month
- **Downloads:** $0.12/GB
- **Uploads:** Free

**Optimization:**
- Old profile pictures are automatically deleted
- Images compressed before upload
- Thumbnail generation recommended (future enhancement)

## Future Enhancements
- [ ] Image compression on server
- [ ] Thumbnail generation
- [ ] Image moderation/filtering
- [ ] Business image upload for admins
- [ ] Direct camera capture (not just gallery)
- [ ] Image editing before upload
- [ ] Progress indicators for multi-upload

## Troubleshooting

### "Permission Denied" Error
1. Check user is authenticated
2. Verify storage rules are deployed: `npx firebase deploy --only storage`
3. Ensure user is writing to their own folder

### Images Not Displaying
1. Check photoURL in Firestore user document
2. Verify storage bucket in firebase_options.dart
3. Check network connectivity
4. Verify CORS settings in Firebase Console

### Upload Fails
1. Check file size < 5MB
2. Verify file is image type
3. Check internet connection
4. Review Firebase Storage quota

## Related Files
- [storage_service.dart](lib/services/storage_service.dart) - Main storage logic
- [profile_picture_uploader.dart](lib/widgets/profile_picture_uploader.dart) - Profile pic widget
- [image_upload_screen.dart](lib/screens/image_upload_screen.dart) - Multi-image upload
- [profile_screen.dart](lib/screens/profile_screen.dart) - Uses profile uploader
- [storage.rules](storage.rules) - Security rules
- [firebase.json](firebase.json) - Firebase config
