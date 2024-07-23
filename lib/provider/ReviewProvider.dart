import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';

class ReviewListProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _ListReviewPosts = [];

  List<Map<String, dynamic>> get ListReviewPosts => _ListReviewPosts;

  Future<void> fetchReview(String postId) async {
    // Example function to get user email
    List<Map<String, dynamic>> ReviewofPost =
        await MongoDatabase.getListReview(postId);

    // Loop through each review in the list
    for (var review in ReviewofPost) {
      // Get user information by user ID
      Map<String, dynamic>? user =
          await MongoDatabase.getUserById(review['userId']);

      if (user != null) {
        // Add user information to the review
        review['imageUser'] = user['image'];
        review['UserName'] = user['username'];
      }
    }
    _ListReviewPosts = ReviewofPost;
    notifyListeners();
  }
}
