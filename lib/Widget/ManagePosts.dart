import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/Widget/LoginScreen.dart';
import 'package:post_house_rent_app/provider/ShowListPostProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';
import 'CreatePost.dart';
import 'package:intl/intl.dart';
import 'package:post_house_rent_app/Widget/DetailPage.dart';
import 'package:post_house_rent_app/Widget/AllPosts.dart';
import 'package:post_house_rent_app/Widget/AllSharePosts.dart';

import 'EditPost.dart';

class Manageposts extends StatefulWidget {
  @override
  _ShowManagePostState createState() => _ShowManagePostState();
}

class _ShowManagePostState extends State<Manageposts> {
  late String email = 'nologin';
  late String OwnerId = 'noId';
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _DeletePost(String _id) async {
    bool delete = await MongoDatabase.DeletePost(_id);
    Provider.of<ShowListPostProvider>(context, listen: false)
        .refreshShowListUserAndListPostPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tin đã đăng',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: Consumer<ShowListPostProvider>(
        builder: (context, provider, child) {
          if (provider.postofUserRoomList.isEmpty) {
            return Center(child: Text("No post found"));
          } else {
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2.9 / 1.5,
              ),
              itemCount: provider.postofUserRoomList.length,
              padding: EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                var post = provider.postofUserRoomList[index];
                DateTime now = DateTime.now();
                DateTime postCreatedAt = DateTime.parse(post['createdAt']);
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
                                  height:
                                      double.infinity, // Chiều cao của hình ảnh
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
                                      text:
                                          " " + post['area'].toString() + " m²",
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
                                '                                               ' +
                                    formattedTime,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              // SizedBox(height: 10),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
// Hành động khi nút đầu tiên được nhấn
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditPost(post: post)),
                                        );
                                      },
                                      child: Text(
                                        'Sửa',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily:
                                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                                          fontWeight: FontWeight
                                              .bold, // hoặc chọn kiểu chữ phù hợp
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.grey[800],
                                              title: Text(
                                                'Xác nhận',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                  fontWeight: FontWeight
                                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                                ),
                                              ),
                                              content: Text(
                                                'Bạn có chắc muốn xóa không?',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                  fontWeight: FontWeight
                                                      .bold, // hoặc chọn kiểu chữ phù hợp
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Đóng hộp thoại
                                                  },
                                                  child: Text(
                                                    'Hủy',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context)
                                                        .pop(); // Đóng hộp thoại xác nhận

// Thực hiện hành động xóa
                                                    await _DeletePost(
                                                        post['_id'].toString());

// Đóng hộp thoại tiến trình
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'Xóa',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.red), // Màu nền nút xóa
                                      ),
                                      child: Text(
                                        'Xóa',
                                        style: TextStyle(
                                          color:
                                              Colors.white, // Màu chữ nút xóa
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ]),
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
