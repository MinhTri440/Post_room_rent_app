import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';

class ShowListPostProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _postList = [];
  List<Map<String, dynamic>> _postShareRoomList = [];
  List<Map<String, dynamic>> _postofUserRoomList = [];
  List<Map<String, dynamic>> _listBooking = [];
  List<Map<String, dynamic>> _allpost = [];
  List<Map<String, dynamic>> get allpost => _allpost;
  List<Map<String, dynamic>> get postList => _postList;
  List<Map<String, dynamic>> get postShareRoomList => _postShareRoomList;
  List<Map<String, dynamic>> get postofUserRoomList => _postofUserRoomList;
  List<Map<String, dynamic>> get listBooking => _listBooking;
  ShowListPostProvider() {
    _loadPosts();
    _fetchListUserData();
    _fetchAppointments();
  }

  Future<void> _loadPosts() async {
    _postList = await MongoDatabase.list_post().then((posts) {
      posts.sort((a, b) {
        DateTime dateTimeA = DateTime.parse(a['createdAt']);
        DateTime dateTimeB = DateTime.parse(b['createdAt']);
        return dateTimeB.compareTo(dateTimeA); // Sắp xếp từ mới đến cũ
      });
      return posts;
    });
    _postShareRoomList =
        await MongoDatabase.list_ShareRoomPost().then((sharePosts) {
      sharePosts.sort((a, b) {
        DateTime dateTimeA = DateTime.parse(a['createdAt']);
        DateTime dateTimeB = DateTime.parse(b['createdAt']);
        return dateTimeB.compareTo(dateTimeA); // Sắp xếp từ mới đến cũ
      });
      return sharePosts;
    });
    _allpost = await MongoDatabase.all_post();
    notifyListeners();
  }

  Future<void> _fetchAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? id = await MongoDatabase.get_IdfromUser(email);

    _listBooking = await MongoDatabase.list_room_appointment_of_owner(id!);
  }

  Future<void> _loadUserPost(String? OwnerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _postofUserRoomList = await MongoDatabase.list_post_owner(OwnerId!);
    _postofUserRoomList.sort((a, b) {
      DateTime dateTimeA = DateTime.parse(a['createdAt']);
      DateTime dateTimeB = DateTime.parse(b['createdAt']);
      return dateTimeB.compareTo(dateTimeA); // Sắp xếp từ mới đến cũ
    });
  }

  Future<void> _fetchListUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email')!;
    String? getOwnerId = await MongoDatabase.get_IdfromUser(email);
    _loadUserPost(getOwnerId);
  }

  // Function to refresh favorite posts
  Future<void> refreshShowListPost() async {
    notifyListeners();
    await _loadPosts();
    await _fetchAppointments();
    await _fetchListUserData();
  }

  Future<void> refreshShowListUserAndListPostPost() async {
    notifyListeners();
    await _fetchListUserData();
    await _loadPosts();
  }

  Future<void> refreshListBooking() async {
    notifyListeners();
    await _fetchAppointments();
  }
}
