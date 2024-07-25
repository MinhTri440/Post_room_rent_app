import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/AccountManager.dart';
import 'package:post_house_rent_app/Widget/Search.dart';
import 'package:post_house_rent_app/Widget/ShowPost.dart';
import 'package:post_house_rent_app/Widget/TestLayToaDo.dart';
import 'package:post_house_rent_app/Widget/map_page.dart';
import 'package:post_house_rent_app/Widget/ListFavourite.dart';
import 'package:provider/provider.dart';
import '../CheckInternet.dart';
import '../provider/ShowListPostProvider.dart';
import '../provider/TurorialPostProvider.dart';
import 'MyBannerAdWidget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  static final List<Widget> _widgetOptions = <Widget>[
    ShowPostWidget(),
    SearchWidget(),
    TestPageWidget(),
    AccountWidget(),
    MapPageWidget(),
  ];

  Future<void> _refresh() async {
    // Simulate refreshing data
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Update state to refresh the screen
      Provider.of<ShowListPostProvider>(context, listen: false)
          .refreshShowListPost();
      Provider.of<TutorialPostProvider>(context, listen: false)
          .refreshTutorialPost();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConnectivityWidgetWrapper(
          child: RefreshIndicator(
            color: Colors.blue,
            onRefresh: _refresh,
            child: IndexedStack(
              index: _currentIndex,
              children: _widgetOptions,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyBannerAdWidget(),
            BottomAppBar(
              color: Colors.grey[800],
              shape: CircularNotchedRectangle(),
              notchMargin: 8.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                    icon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.home,
                          size: 23,
                          color:
                              _currentIndex == 0 ? Colors.blue : Colors.white,
                        ),
                        Text(
                          'Trang chủ',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color:
                                _currentIndex == 0 ? Colors.blue : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                    icon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.search,
                          size: 23,
                          color:
                              _currentIndex == 1 ? Colors.blue : Colors.white,
                        ),
                        Text(
                          'Tìm kiếm',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            color:
                                _currentIndex == 1 ? Colors.blue : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                      // Action when the favorite button is pressed
                    },
                    icon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.favorite,
                          size: 23,
                          color:
                              _currentIndex == 2 ? Colors.blue : Colors.white,
                        ),
                        Text(
                          'Yêu thích',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            color:
                                _currentIndex == 2 ? Colors.blue : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 3;
                      });
                    },
                    icon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.account_circle,
                          size: 23,
                          color:
                              _currentIndex == 3 ? Colors.blue : Colors.white,
                        ),
                        Text(
                          'Tài khoản',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            color:
                                _currentIndex == 3 ? Colors.blue : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 4;
                      });
                    },
                    icon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.map,
                          size: 23,
                          color:
                              _currentIndex == 4 ? Colors.blue : Colors.white,
                        ),
                        Text(
                          'Bản đồ',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            color:
                                _currentIndex == 4 ? Colors.blue : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class ShowPostWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShowPost(); // Your search screen content here
  }
}

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Search(); // Your search screen content here
  }
}

class AccountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AccountManager(); // Your account screen content here
  }
}

class MapPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MapPage();
  }
}

class TestPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FavoritePost();
  }
}
