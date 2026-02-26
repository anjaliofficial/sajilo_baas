// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/services/storage/storage_service.dart';

final savedBookingsProvider =
    StateNotifierProvider<SavedBookingsNotifier, Set<String>>((ref) {
      final storage = ref.read(storageServiceProvider);
      return SavedBookingsNotifier(storage);
    });

class SavedBookingsNotifier extends StateNotifier<Set<String>> {
  final StorageService _storage;
  static const _key = 'saved_bookings';

  SavedBookingsNotifier(this._storage) : super({}) {
    _load();
  }

  void _load() {
    final saved = _storage.getString(_key);
    if (saved != null && saved.isNotEmpty) {
      state = Set<String>.from(saved.split(','));
    }
  }

  void toggle(String bookingId) {
    final updated = Set<String>.from(state);
    if (updated.contains(bookingId)) {
      updated.remove(bookingId);
    } else {
      updated.add(bookingId);
    }
    state = updated;
    _storage.setString(_key, state.join(','));
  }

  bool isSaved(String bookingId) => state.contains(bookingId);
}
