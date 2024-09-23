import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteNotifier extends StateNotifier<List<Map<String, String>>> {
  FavoriteNotifier(List<Map<String, String>> state) : super(state);

  void addFavorite(Map<String, String> favorite) {
    state.add(favorite);
  }

  void removeFavorite(Map<String, String> favorite) {
    state.remove(favorite);
  }
}

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, List<Map<String, String>>>((ref) {
  return FavoriteNotifier([]);
});
