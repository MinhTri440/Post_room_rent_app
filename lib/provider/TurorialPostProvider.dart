import 'package:flutter/material.dart';

import '../MongoDb_Connect.dart';

class TutorialPostProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _tutorialPosts = [];
  List<Map<String, dynamic>> get tutorialPosts => _tutorialPosts;
  TutorialPostProvider() {
    _fetchTutorialPostPosts();
  }

  Future<void> _fetchTutorialPostPosts() async {
    _tutorialPosts = await MongoDatabase.list_tutorialPost();
    notifyListeners();
  }

  Future<void> refreshTutorialPost() async {
    notifyListeners();
    await _fetchTutorialPostPosts();
  }
}
