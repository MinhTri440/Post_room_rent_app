import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/Widget/LoginScreen.dart';
import 'package:post_house_rent_app/Widget/MyBannerAdWidget.dart';
import 'package:post_house_rent_app/provider/TurorialPostProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../MongoDb_Connect.dart';
import '../provider/ListFavouriteProvider.dart';
import '../provider/ShowListPostProvider.dart';
import 'AllTutorialPost.dart';
import 'CreatePost.dart';
import 'package:intl/intl.dart';
import 'package:post_house_rent_app/Widget/DetailPage.dart';
import 'package:post_house_rent_app/Widget/AllPosts.dart';
import 'package:post_house_rent_app/Widget/AllSharePosts.dart';

class ShowPost extends StatefulWidget {
  @override
  _ShowPostState createState() => _ShowPostState();
}

class _ShowPostState extends State<ShowPost> {
  late String username = 'nologin';
  late String imageUrl = 'nologin';

  @override
  void initState() {
    super.initState();
    loadAd();
    check_if_already_login();
    //_loadPosts();
  }

  void loadAd() {
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-3940256099942544/4411468910';
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          // Ad successfully loaded
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          // Handle the error
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void check_if_already_login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var checklogin = (prefs.getBool('login') ?? true);
    if (checklogin == false) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      imageUrl = prefs.getString('image')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WantRoom',
          style: TextStyle(
            fontSize: 28.0,
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        leading: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/assets%2Fhome.png?alt=media&token=910915c9-9227-4d6c-b23a-11d3b6975e2b',
        ),
        backgroundColor: Colors.grey[800], // màu xám đậm
        actions: [
          username == "nologin" || imageUrl == "noimage"
              ? IconButton(
                  icon: Icon(
                    Icons.account_circle,
                    color: Colors.white, // đổi màu icon thành màu trắng
                    size: 35,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                )
              : Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl),
                      radius: 20.0,
                    ),
                    SizedBox(width: 10),
                  ],
                ),
          IconButton(
            icon: Icon(
              Icons.post_add,
              color: Colors.white, // đổi màu icon thành màu trắng
              size: 40,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpPost()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Colors.blue, // Màu nền của CircleAvatar là trắng
                          radius: 10.0, // Đường kính của CircleAvatar
                          child: Icon(
                            Icons.circle, // Icon "new"
                            color: Colors.black, // Màu của icon
                            size: 15.0, // Kích thước của icon
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Phòng, căn hộ mới',
                          style: TextStyle(
                            fontSize:
                                20.0, // Đổi kích thước nét chữ lớn hơn từ 18 thành 20
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        // Khoảng cách giữa text và icon
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Allposts()),
                        );
                        // Action when the view more button is pressed
                      },
                      child: Text(
                        'Xem thêm',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ),
              Consumer<ShowListPostProvider>(
                builder: (context, provider, child) {
                  if (provider.postList.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors
                              .white)), // Hiển thị loading indicator thay vì chỉ dòng "Loading..."
                    );
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.9 / 3.5,
                      ),
                      itemCount: provider.postList.length >= 7
                          ? 6
                          : provider.postList.length,
                      padding: EdgeInsets.all(1.0),
                      itemBuilder: (context, index) {
                        var post = provider.postList[index];
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
                                builder: (context) => DetailPage(post: post),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.grey[800],
                            margin: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.network(
                                        post['imageUrls'][0],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 150, // Chiều cao của hình ảnh
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 2.0,
                                      right: 2.0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue, // Màu nền xanh
                                            borderRadius: BorderRadius.circular(
                                                10), // Độ bo góc nếu cần
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Icon(
                                                    Icons.attach_money,
                                                    size: 20,
                                                    color: Colors
                                                        .white, // Màu icon
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: " " + gia,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                      SizedBox(height: 8),
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
                                      SizedBox(height: 4),
                                      Text(
                                        '                           ' +
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
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Colors.blue, // Màu nền của CircleAvatar là trắng
                          radius: 10.0, // Đường kính của CircleAvatar
                          child: Icon(
                            Icons.circle, // Icon "new"
                            color: Colors.black, // Màu của icon
                            size: 15.0, // Kích thước của icon
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Tin ở ghép mới',
                          style: TextStyle(
                            fontSize:
                                20.0, // Đổi kích thước nét chữ lớn hơn từ 18 thành 20
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        // Khoảng cách giữa text và icon
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllSharePosts()),
                        );
                        // Action when the view more button is pressed
                      },
                      child: Text(
                        'Xem thêm',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ),
              Consumer<ShowListPostProvider>(
                builder: (context, provider, child) {
                  if (provider.postShareRoomList.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors
                              .white)), // Hiển thị loading indicator thay vì chỉ dòng "Loading..."
                    );
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.9 / 3.5,
                      ),
                      itemCount: provider.postShareRoomList.length >= 7
                          ? 6
                          : provider.postShareRoomList.length,
                      padding: EdgeInsets.all(1.0),
                      itemBuilder: (context, index) {
                        var post = provider.postShareRoomList[index];
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
                                builder: (context) => DetailPage(post: post),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.grey[800],
                            margin: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.network(
                                        post['imageUrls'][0],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 150, // Chiều cao của hình ảnh
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 2.0,
                                      right: 2.0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue, // Màu nền xanh
                                            borderRadius: BorderRadius.circular(
                                                10), // Độ bo góc nếu cần
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Icon(
                                                    Icons.attach_money,
                                                    size: 20,
                                                    color: Colors
                                                        .white, // Màu icon
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: " " + gia,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                      SizedBox(height: 8),
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
                                      SizedBox(height: 4),
                                      Text(
                                        '                           ' +
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
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 10.0,
                          child: Icon(
                            Icons.circle,
                            color: Colors.black,
                            size: 15.0,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Bài Viết',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllTutorialposts()),
                        );
                        // Action when the view more button is pressed
                      },
                      child: Text(
                        'Xem thêm',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ),
              Consumer<TutorialPostProvider>(
                builder: (context, provider, child) {
                  if (provider.tutorialPosts.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 2.9 / 2.5,
                      ),
                      itemCount: provider.tutorialPosts.length >= 4
                          ? 3
                          : provider.tutorialPosts.length,
                      padding: EdgeInsets.all(8.0),
                      itemBuilder: (context, index) {
                        var post = provider.tutorialPosts[index];
                        return InkWell(
                          onTap: () async {
                            String? url = post['link'];
                            if (await canLaunch(url!)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Card(
                            color: Colors.grey[800],
                            margin: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.network(
                                        post['image']!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 200,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: " " + post['title']!,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        //overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 12),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: post['description']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        //overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
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
            ],
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
