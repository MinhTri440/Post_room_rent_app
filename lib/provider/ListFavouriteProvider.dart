import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';

class FavoritePostProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favoritePosts = [];

  List<Map<String, dynamic>> get favoritePosts => _favoritePosts;
  FavoritePostProvider() {
    _fetchFavoritePosts();
  }

  Future<void> _fetchFavoritePosts() async {
    String? email = await _getUserEmail(); // Example function to get user email
    if (email != null) {
      String? userId = await MongoDatabase.get_IdfromUser(email);
      if (userId != null) {
        List<Map<String, dynamic>> favouriteList =
            await MongoDatabase.getListFavorite(userId);
        _favoritePosts = await MongoDatabase.getFavouritePosts(favouriteList);
        notifyListeners();
      }
    }
  }

  // Example function to get user email (replace with your own logic)
  Future<String?> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Function to refresh favorite posts
  Future<void> refreshFavoritePosts() async {
    notifyListeners();
    await _fetchFavoritePosts();
  }
}
