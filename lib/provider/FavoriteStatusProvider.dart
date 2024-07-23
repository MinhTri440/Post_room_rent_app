import 'package:flutter/foundation.dart';

import '../MongoDb_Connect.dart';

class FavoriteStatusProvider with ChangeNotifier {
  bool _isFavorite = false;

  bool get isFavorite => _isFavorite;

  Future<void> setFavourite(String idUser, String postId) async {
    bool getcheck = await MongoDatabase.setFavouriteIcon(idUser, postId);
    updateFavoriteStatus(getcheck);
  }

  void updateFavoriteStatus(bool newStatus) {
    _isFavorite = newStatus;
    notifyListeners();
  }
}
