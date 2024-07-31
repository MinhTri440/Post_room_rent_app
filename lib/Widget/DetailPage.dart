import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:post_house_rent_app/Widget/BookingScreen.dart';
import 'package:provider/provider.dart';

import '../MongoDb_Connect.dart';

import '../provider/ListFavouriteProvider.dart';
import '../provider/ReviewProvider.dart';
import 'ChatPage.dart';
import 'LoginScreen.dart';

List<Map<String, dynamic>> amenities = [
  {'name': 'Wifi', 'icon': Icons.wifi},
  {'name': 'WC riêng', 'icon': Icons.bathtub},
  {'name': 'Giữ xe', 'icon': Icons.local_parking},
  {'name': 'Tự do', 'icon': Icons.accessibility},
  {'name': 'Bếp', 'icon': Icons.kitchen},
  {'name': 'Điều hòa', 'icon': Icons.ac_unit},
  {'name': 'Tủ lạnh', 'icon': Icons.kitchen_outlined},
  {'name': 'Máy giặt', 'icon': Icons.local_laundry_service},
  {'name': 'Nội thất', 'icon': Icons.weekend},
];

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  DetailPage({required this.post});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  PageController _pageController = PageController();
  VideoPlayerController? _videoPlayerController;
  int _currentPage = 0;
  late List<Map<String, dynamic>> selectedAmenities;
  String idUser = 'noemail';
  String postId = '';
  late bool isFavorite = false;
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 1;
  List<Map<String, dynamic>> listReview = [];

  // Danh sách tiện ích

  // Lọc tiện ích đã chọn

  @override
  void initState() {
    super.initState();
    _initializeData();
    //_checkFavoriteStatus();
    if (widget.post['videoURL'] != null) {
      _videoPlayerController =
          VideoPlayerController.network(widget.post['videoURL'])
            ..initialize().then((_) {
              setState(() {});
            });
    }
    selectedAmenities = amenities.where((amenity) {
      return widget.post['selectedAmenitiesNames'].contains(amenity['name']);
    }).toList();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? search =
        await MongoDatabase.get_IdfromUser(prefs.getString('email'));
    if (mounted) {
      setState(() {
        idUser = search!;
        postId = widget.post['_id'].toString();
        postId =
            postId!.substring(postId.indexOf('"') + 1, postId.lastIndexOf('"'));
      });
    }
  }

  Future<void> setFavourite() async {
    print(idUser);
    print(postId);
    bool getcheck = await MongoDatabase.setFavouriteIcon(idUser, postId);
    if (mounted) {
      setState(() {
        isFavorite = getcheck;
      });
    }

    print(isFavorite);
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await setFavourite();
    if (mounted) {
      final reviewProvider =
          Provider.of<ReviewListProvider>(context, listen: false);
      await reviewProvider.fetchReview(postId);

      setState(() {
        listReview = reviewProvider.ListReviewPosts;
      });
    }
    print(listReview);
  }

  Future<void> addFavourite() async {
    if (await _isnotLoggedIn() == true) {
      return _showLoginDialog();
    } else {
      if (isFavorite == true) {
        setState(() {
          isFavorite = false;
        });
        bool check = await MongoDatabase.removeFavorite(idUser, postId);
        Provider.of<FavoritePostProvider>(context, listen: false)
            .refreshFavoritePosts();
      } else {
        print("Chua yeu thic");
        setState(() {
          isFavorite = true;
        });
        bool check = await MongoDatabase.addFavorite(idUser, postId);
        Provider.of<FavoritePostProvider>(context, listen: false)
            .refreshFavoritePosts();
      }
    }
  }

  Future<bool?> _isnotLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getBool('login').toString());
    return prefs.getBool('login');
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text(
          'Yêu cầu đăng nhập',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        content: Text(
          'Bạn cần đăng nhập để sử dụng chức năng này.',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text(
              'Đăng nhập',
              style: TextStyle(
                color: Colors.blue,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Hủy PageController nếu cần
    _pageController.dispose();

    // Giải phóng VideoPlayerController nếu có
    _videoPlayerController?.dispose();

    // Giải phóng TextEditingController
    _reviewController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });

    if (_videoPlayerController != null) {
      if (index == widget.post['imageUrls'].length) {
        _videoPlayerController!.play();
      } else {
        _videoPlayerController?.pause();
      }
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (_currentPage < widget.post['imageUrls'].length) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _fixAddress(String address) {
    // Đếm số dấu phẩy trong chuỗi
    int commaCount = address.split(',').length - 1;

    // Kiểm tra nếu có ít hơn 4 dấu phẩy thì trả về nguyên bản
    if (commaCount < 4) {
      return address;
    }

    // Tách chuỗi và chỉ giữ lại phần sau dấu phẩy đầu tiên
    List<String> parts = address.split(',');
    return parts.sublist(1).join(',');
  }

  Future<void> _getLocationFromAddress(String address) async {
    address = _fixAddress(address);
    print(address);
    String _latitude = '';
    String _longitude = '';
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        print(locations[0].latitude.toString());
        print(locations[0].longitude.toString());

        _latitude = locations[0].latitude.toString();
        _longitude = locations[0].longitude.toString();
      } else {
        _latitude = 'Not found';
        _longitude = 'Not found';
      }
      final url =
          "https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _submitReview() async {
    if (await _isnotLoggedIn() == true) {
      return _showLoginDialog();
    } else {
      String reviewText = _reviewController.text;
      int rate = _rating;
      setState(() {
        _rating = 1;
      });
      _reviewController.clear();
      await MongoDatabase.addReview(idUser, postId, rate, reviewText);
      final reviewProvider =
          Provider.of<ReviewListProvider>(context, listen: false);
      await reviewProvider.fetchReview(postId);
      setState(() {
        listReview = reviewProvider.ListReviewPosts;
      });
      print(listReview);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime postCreatedAt = DateTime.parse(widget.post['createdAt']);
    String formattedDate = DateFormat('dd/MM/yyyy').format(postCreatedAt);
    var price = widget.post['price'] / 100000;
    String gia = '';
    if (price < 10) {
      price = price * 100;
      gia = price.toString() + ' K';
    } else {
      price = price / 10;
      gia = price.toString() + ' Triệu';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi Tiết Bài Viết',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: addFavourite,
          ),
        ],
        backgroundColor: Colors.grey[800],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.post['imageUrls'] != null &&
                      widget.post['imageUrls'].isNotEmpty)
                    SizedBox(
                      height: 300.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: _onPageChanged,
                            itemCount: widget.post['imageUrls'].length +
                                (widget.post['videoURL'] != null ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < widget.post['imageUrls'].length) {
                                return Image.network(
                                  widget.post['imageUrls'][index],
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return _videoPlayerController != null &&
                                        _videoPlayerController!
                                            .value.isInitialized
                                    ? AspectRatio(
                                        aspectRatio: _videoPlayerController!
                                            .value.aspectRatio,
                                        child: VideoPlayer(
                                            _videoPlayerController!),
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      );
                              }
                            },
                          ),
                          Positioned(
                            left: 16.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onPressed: _goToPreviousPage,
                            ),
                          ),
                          Positioned(
                            right: 16.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onPressed: _goToNextPage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    widget.post['topic'],
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.attach_money, color: Colors.blue),
                        const SizedBox(width: 4.0),
                        Text(
                          '$gia/1 tháng',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.white),
                        ),
                      ]),
                      Text(
                        'Ngày đăng: $formattedDate',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.square_foot, color: Colors.blue),
                          const SizedBox(width: 4.0),
                          Text(
                            "Diện tích: ${widget.post['area']} m²",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.type_specimen_outlined,
                              color: Colors.blue),
                          const SizedBox(width: 4.0),
                          Text(
                            'Loại hình: ${widget.post['selectedRoomType']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _getLocationFromAddress(widget.post['address']);
                          },
                          child: Text(
                            widget.post['address'],
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.blue),
                      const SizedBox(width: 4.0),
                      Text(
                        "${widget.post['phone']}",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (selectedAmenities.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_tree, color: Colors.blue),
                            const SizedBox(width: 4.0),
                            Text(
                              "Tiện ích:",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: selectedAmenities.map((amenity) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  amenity['icon'],
                                  size: 30,
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 4),
                                Text(amenity['name'],
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontFamily: 'Roboto')),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  if (widget.post['description'] != null)
                    Text(
                      "Mô tả chi tiết:",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.white),
                    ),
                  if (widget.post['description'] != null) SizedBox(height: 10),
                  if (widget.post['description'] != null)
                    Text(
                      widget.post['description'],
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Roboto'),
                    ),
                  SizedBox(height: 16),
                  Text(
                    "Đánh giá:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        color: Colors.white),
                  ),
                  listReview.length > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: listReview.length,
                          itemBuilder: (context, index) {
                            var review = listReview[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(review['imageUser']),
                                    radius: 25,
                                  ),
                                  title: Text(
                                    review['UserName'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            index < review['Rating']
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: index < review['Rating']
                                                ? Colors.blue
                                                : Colors.grey,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        review['Review'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Đã đăng vào: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(review['createdAt']))}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "Chưa có đánh giá",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                                color: Colors.white),
                          ),
                        ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Đánh giá bài viết',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        DropdownButtonFormField<int>(
                          value: _rating,
                          onChanged: (value) {
                            setState(() {
                              _rating = value!;
                            });
                          },
                          items: List.generate(5, (index) => index + 1)
                              .map((rating) => DropdownMenuItem<int>(
                                    value: rating,
                                    child: Row(
                                      children: List.generate(
                                          rating,
                                          (index) => Icon(Icons.star,
                                              color: Colors.blue)),
                                    ),
                                  ))
                              .toList(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[700],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _reviewController,
                          maxLines: 3,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Nhập đánh giá của bạn...',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[700],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            _submitReview();
                          },
                          child: Text(
                            'Gửi đánh giá',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: Colors.white,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ])
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.grey[800],
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Loại tin:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final Uri url = Uri(
                                    scheme: 'tel',
                                    path: "${widget.post['phone']}",
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    print('cannot launch this url');
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue), // Blue background
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.call,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Gọi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  _getLocationFromAddress(
                                      widget.post['address']);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.map,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Chỉ đường',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue), // Blue background
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Adjust the radius to make the corners more square
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.post['zalophone'] != "")
                                ElevatedButton(
                                  onPressed: () async {
                                    final url =
                                        "https://zalo.me/${widget.post['zalophone']}";
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Liên hệ zalo',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue), // Blue background
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Adjust the radius to make the corners more square
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.post['facebookLink'] != "")
                                ElevatedButton(
                                  onPressed: () async {
                                    final url =
                                        "${widget.post['facebookLink']}";
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.facebook,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Liên hệ facebook',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue), // Blue background
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Adjust the radius to make the corners more square
                                      ),
                                    ),
                                  ),
                                ),
                              ElevatedButton(
                                onPressed: () async {
                                  //checkLogin();
                                  if (await _isnotLoggedIn() == true) {
                                    return _showLoginDialog();
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BookingScreen(post: widget.post)),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.bookmark_add_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Đặt lịch xem phòng',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue), // Blue background
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Adjust the radius to make the corners more square
                                    ),
                                  ),
                                ),
                              ),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => ChatPage(
                              //             userID: idUser,
                              //             ownerId: widget.post['ownerId']),
                              //       ),
                              //     );
                              //   },
                              //   child:
                              //   Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [
                              //       Icon(
                              //         Icons.chat,
                              //         color: Colors.white,
                              //       ),
                              //       SizedBox(width: 8.0),
                              //       Text(
                              //         'Nhắn tin với chủ phòng',
                              //         style: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           fontFamily: 'Roboto',
                              //           color: Colors.white,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              //   style: ButtonStyle(
                              //     backgroundColor:
                              //         MaterialStateProperty.all<Color>(
                              //             Colors.blue), // Blue background
                              //     shape: MaterialStateProperty.all<
                              //         RoundedRectangleBorder>(
                              //       RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(
                              //             8.0), // Adjust the radius to make the corners more square
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Icon(
                Icons.filter_list,
                color: Colors.white,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.blue), // Blue background
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0), // Hình tròn
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
