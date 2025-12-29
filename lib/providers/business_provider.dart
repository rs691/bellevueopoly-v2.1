import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_model.dart';
import 'firestore_provider.dart';
// Provider to get all businesses from the Firestore Stream
final businessListProvider = StreamProvider<List<Business>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getBusinessesStream();
});

// Provider to get a single business by ID
// Provider to get a single business by ID from Firestore
final businessByIdProvider = FutureProvider.family<Business?, String>((ref, id) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  // We can fetch the list and find it, or filter the stream. 
  // For simplicity and realtime updates, we could stream it, but FutureProvider is easier for now.
  // Ideally, valid businesses are already loaded. 
  // Let's use the stream to ensure we have the latest data if we are already subscribed.
  
  // OPTION A: Fetch fresh once
  final businesses = await firestoreService.getBusinesses();
  try {
     return businesses.firstWhere((b) => b.id == id);
  } catch (e) {
    return null;
  }
});
