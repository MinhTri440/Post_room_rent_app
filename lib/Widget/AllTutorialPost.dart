import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../MongoDb_Connect.dart';
import '../provider/ShowListPostProvider.dart';
import '../provider/TurorialPostProvider.dart';
import 'DetailPage.dart';

class AllTutorialposts extends StatefulWidget {
  const AllTutorialposts({super.key});

  @override
  State<AllTutorialposts> createState() => _AllTutorialpostsState();
}

class _AllTutorialpostsState extends State<AllTutorialposts> {
  @override
  void initState() {
    super.initState();
    //_loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bài đăng cho thuê',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      itemCount: provider.tutorialPosts.length,
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
          // Add the second column here with similar structure as above
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
