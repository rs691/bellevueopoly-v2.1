import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/storage_service.dart';
import '../providers/user_data_provider.dart';

/// Reusable widget for uploading and displaying profile pictures
class ProfilePictureUploader extends ConsumerStatefulWidget {
  final String? currentPhotoUrl;
  final String userName;
  final VoidCallback? onUploadComplete;

  const ProfilePictureUploader({
    super.key,
    this.currentPhotoUrl,
    required this.userName,
    this.onUploadComplete,
  });

  @override
  ConsumerState<ProfilePictureUploader> createState() =>
      _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState
    extends ConsumerState<ProfilePictureUploader> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  bool _isUploading = false;
  File? _localFile;
  Uint8List? _localBytes;

  Future<void> _pickAndUploadImage() async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // Optimistic updat: Show local image immediately
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _localBytes = bytes;
          _isUploading = true;
        });
        await _storageService.uploadProfilePicture(bytes);
      } else {
        final file = File(image.path);
        setState(() {
          _localFile = file;
          _isUploading = true;
        });
        await _storageService.uploadProfilePicture(file);
      }

      // Clean up old profile pictures
      await _storageService.deleteOldProfilePictures();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh user data to show new profile picture
        ref.invalidate(userDataProvider);
        widget.onUploadComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        // Revert local optimistic update on error
        setState(() {
          _localFile = null;
          _localBytes = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initial = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'U';

    Widget buildImageContent() {
      // 1. Show local file if available (Optimistic UI)
      if (!kIsWeb && _localFile != null) {
        return Image.file(
          _localFile!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }
      
      // 2. Show local bytes if available (Web)
      if (kIsWeb && _localBytes != null) {
        return Image.memory(
          _localBytes!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }

      // 3. Show remote URL if available
      if (widget.currentPhotoUrl != null) {
        return CachedNetworkImage(
          imageUrl: widget.currentPhotoUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Theme.of(context).colorScheme.primary,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            // Log error to console for debugging
            debugPrint('Error loading profile image: $error');
            return Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      }

      // 4. Fallback to initials
      return Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 48,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Profile picture circle
        CircleAvatar(
          radius: 50,
           backgroundColor: Theme.of(context).colorScheme.primary,
           child: ClipOval(
             child: SizedBox(
               width: 100,
               height: 100,
               child: buildImageContent(),
             ),
           ),
        ),

        // Upload overlay when uploading
        if (_isUploading)
          Positioned.fill(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black54,
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // Camera icon button
        if (!_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 18),
                color: Colors.white,
                padding: EdgeInsets.zero,
                onPressed: _pickAndUploadImage,
              ),
            ),
          ),
      ],
    );
  }
}
