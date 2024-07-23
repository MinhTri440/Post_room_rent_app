import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/ListFavouriteProvider.dart';
import 'DetailPage.dart';
import 'LoginScreen.dart';

class FavoritePost extends StatefulWidget {
  const FavoritePost({super.key});

  @override
  State<FavoritePost> createState() => _FavoritePostState();
}

class _FavoritePostState extends State<FavoritePost> {
  String idUser = 'noemail';
  String postId = '';
  bool checklogin = false;

  @override
  void initState() {
    super.initState();
    check_if_already_login();
  }

  void check_if_already_login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var check = prefs.getBool('login');
    setState(() {
      if (check == null) {
      } else {
        checklogin = check;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bài đăng đã thích',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: checklogin == true
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Yêu cầu đăng nhập để sử dụng chức năng này.',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                    fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily:
                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                        fontWeight:
                            FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            )
          : Consumer<FavoritePostProvider>(
              builder: (context, provider, child) {
                if (provider.favoritePosts.isEmpty) {
                  return Center(child: Text("No post found"));
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 2.9 / 1.3,
                    ),
                    itemCount: provider.favoritePosts.length,
                    padding: EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      var post = provider.favoritePosts[index];
                      DateTime now = DateTime.now();
                      DateTime postCreatedAt =
                          DateTime.parse(post['createdAt']);
                      Duration difference = now.difference(postCreatedAt);
                      String formattedTime;
                      if (difference.inMinutes < 60) {
                        formattedTime = "${difference.inMinutes} phút trước";
                      } else if (difference.inHours < 24) {
                        formattedTime = "${difference.inHours} giờ trước";
                      } else if (difference.inDays < 7) {
                        formattedTime = "${difference.inDays} ngày trước";
                      } else {
                        formattedTime =
                            DateFormat('dd/MM/yyyy').format(postCreatedAt);
                      }
                      var price = post['price'] / 100000;
                      String gia = '';
                      if (price < 10) {
                        price = price * 100;
                        gia = price.toString() + ' K';
                      } else {
                        price = price / 10;
                        gia = price.toString() + ' Triệu';
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(post: post)),
                          );
                        },
                        child: Card(
                          color: Colors.grey[800],
                          margin: EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.network(
                                        post['imageUrls'][0],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double
                                            .infinity, // Chiều cao của hình ảnh
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8.0,
                                      right: 8.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue, // Màu nền xanh
                                          borderRadius: BorderRadius.circular(
                                              10), // Độ bo góc nếu cần
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 15,
                                              color: Colors.white, // Màu icon
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              gia,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: " " + post['topic'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 25),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          TextSpan(
                                            text: " " + post['address'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 25),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: Icon(
                                              Icons.square_foot,
                                              size: 16,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          TextSpan(
                                            text: " " +
                                                post['area'].toString() +
                                                " m²",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 25),
                                    Text(
                                      '                                                   ' +
                                          formattedTime,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
      backgroundColor: Colors.black,
    );
  }
}
