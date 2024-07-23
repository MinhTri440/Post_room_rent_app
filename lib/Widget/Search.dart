import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:post_house_rent_app/MongoDb_Connect.dart';

import 'DetailPage.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool showList = false;
  late Future<List<Map<String, dynamic>>> _SearchList;
  late Future<List<Map<String, dynamic>>> _ListForFillter;
  String _selectedType = 'Cho thuê';
  String _selectedTypeRoom = 'Phòng';
  String _selectedSort = "Mới nhất"; // Khai báo _selectedType ở đây
  RangeValues _currentRangeValues = RangeValues(500, 20000);
  RangeValues _currentAreaRangeValues = RangeValues(10, 100);

  List<String> allSuggestions = [
    "Thành phố Hà Nội",
    "Thành phố Hồ Chí Minh",
    "Thành phố Hải Phòng",
    "Thành phố Đà Nẵng",
    "Thành phố Cần Thơ",
    "Tỉnh Hà Giang",
    "Tỉnh Cao Bằng",
    "Tỉnh Bắc Kạn",
    "Tỉnh Tuyên Quang",
    "Tỉnh Lào Cai",
    "Tỉnh Điện Biên",
    "Tỉnh Lai Châu",
    "Tỉnh Sơn La",
    "Tỉnh Yên Bái",
    "Tỉnh Hoà Bình",
    "Tỉnh Thái Nguyên",
    "Tỉnh Lạng Sơn",
    "Tỉnh Quảng Ninh",
    "Tỉnh Bắc Giang",
    "Tỉnh Phú Thọ",
    "Tỉnh Vĩnh Phúc",
    "Tỉnh Bắc Ninh",
    "Tỉnh Hải Dương",
    "Tỉnh Hưng Yên",
    "Tỉnh Thái Bình",
    "Tỉnh Hà Nam",
    "Tỉnh Nam Định",
    "Tỉnh Ninh Bình",
    "Tỉnh Thanh Hóa",
    "Tỉnh Nghệ An",
    "Tỉnh Hà Tĩnh",
    "Tỉnh Quảng Bình",
    "Tỉnh Quảng Trị",
    "Tỉnh Thừa Thiên Huế",
    "Tỉnh Quảng Nam",
    "Tỉnh Quảng Ngãi",
    "Tỉnh Bình Định",
    "Tỉnh Phú Yên",
    "Tỉnh Khánh Hòa",
    "Tỉnh Ninh Thuận",
    "Tỉnh Bình Thuận",
    "Tỉnh Kon Tum",
    "Tỉnh Gia Lai",
    "Tỉnh Đắk Lắk",
    "Tỉnh Đắk Nông",
    "Tỉnh Lâm Đồng",
    "Tỉnh Bình Phước",
    "Tỉnh Tây Ninh",
    "Tỉnh Bình Dương",
    "Tỉnh Đồng Nai",
    "Tỉnh Bà Rịa - Vũng Tàu",
    "Tỉnh Long An",
    "Tỉnh Tiền Giang",
    "Tỉnh Bến Tre",
    "Tỉnh Trà Vinh",
    "Tỉnh Vĩnh Long",
    "Tỉnh Đồng Tháp",
    "Tỉnh An Giang",
    "Tỉnh Kiên Giang",
    "Tỉnh Hậu Giang",
    "Tỉnh Sóc Trăng",
    "Tỉnh Bạc Liêu",
    "Tỉnh Cà Mau",
    "Quận 1, Thành phố Hồ Chí Minh",
    "Quận 12, Thành phố Hồ Chí Minh",
    "Quận Gò Vấp, Thành phố Hồ Chí Minh",
    "Quận Bình Thạnh, Thành phố Hồ Chí Minh",
    "Quận Tân Bình, Thành phố Hồ Chí Minh",
    "Quận Tân Phú, Thành phố Hồ Chí Minh",
    "Quận Phú Nhuận, Thành phố Hồ Chí Minh",
    "Thành phố Thủ Đức, Thành phố Hồ Chí Minh",
    "Quận 3, Thành phố Hồ Chí Minh",
    "Quận 10, Thành phố Hồ Chí Minh",
    "Quận 11, Thành phố Hồ Chí Minh",
    "Quận 4, Thành phố Hồ Chí Minh",
    "Quận 5, Thành phố Hồ Chí Minh",
    "Quận 6, Thành phố Hồ Chí Minh",
    "Quận 8, Thành phố Hồ Chí Minh",
    "Quận Bình Tân, Thành phố Hồ Chí Minh",
    "Quận 7, Thành phố Hồ Chí Minh",
    "Huyện Củ Chi, Thành phố Hồ Chí Minh",
    "Huyện Hóc Môn, Thành phố Hồ Chí Minh",
    "Huyện Bình Chánh, Thành phố Hồ Chí Minh",
    "Huyện Nhà Bè, Thành phố Hồ Chí Minh",
    "Quận Ba Đình, Thành phố Hà Nội",
    "Quận Hoàn Kiếm, Thành phố Hà Nội",
    "Quận Tây Hồ, Thành phố Hà Nội",
    "Quận Long Biên, Thành phố Hà Nội",
    "Quận Cầu Giấy, Thành phố Hà Nội",
    "Quận Đống Đa, Thành phố Hà Nội",
    "Quận Hai Bà Trưng, Thành phố Hà Nội",
    "Quận Hoàng Mai, Thành phố Hà Nội",
    "Quận Thanh Xuân, Thành phố Hà Nội",
    "Huyện Sóc Sơn, Thành phố Hà Nội",
    "Huyện Đông Anh, Thành phố Hà Nội",
    "Huyện Gia Lâm, Thành phố Hà Nội",
    "Quận Nam Từ Liêm, Thành phố Hà Nội",
    "Huyện Thanh Trì, Thành phố Hà Nội",
    "Quận Bắc Từ Liêm, Thành phố Hà Nội",
    "Huyện Mê Linh, Thành phố Hà Nội",
    "Quận Hà Đông, Thành phố Hà Nội",
    "Thị xã Sơn Tây, Thành phố Hà Nội",
    "Huyện Ba Vì, Thành phố Hà Nội",
    "Huyện Phúc Thọ, Thành phố Hà Nội",
    "Huyện Đan Phượng, Thành phố Hà Nội",
    "Huyện Hoài Đức, Thành phố Hà Nội",
    "Huyện Quốc Oai, Thành phố Hà Nội",
    "Huyện Thạch Thất, Thành phố Hà Nội",
    "Huyện Chương Mỹ, Thành phố Hà Nội",
    "Huyện Thanh Oai, Thành phố Hà Nội",
    "Huyện Thường Tín, Thành phố Hà Nội",
    "Huyện Phú Xuyên, Thành phố Hà Nội",
    "Huyện Ứng Hòa, Thành phố Hà Nội",
    "Huyện Mỹ Đức, Thành phố Hà Nội",
  ];

  List<String> filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    //fetchProvinces();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void filter_treatment(
      String selectedType,
      String _selectedTypeRoom,
      String _selectedSort,
      RangeValues _currentRangeValues,
      RangeValues _currentAreaRangeValues) {
    setState(() {
      _SearchList = _ListForFillter;
      _SearchList = _SearchList.then((list) => list.where((item) {
            final bool matchesType = item['selectedType'] == selectedType;
            final bool matchesRoomType =
                item['selectedRoomType'] == _selectedTypeRoom;
            final bool matchesPrice =
                item['price'] >= _currentRangeValues.start * 1000 &&
                    item['price'] <= _currentRangeValues.end * 1000;
            final bool matchesArea =
                item['area'] >= _currentAreaRangeValues.start &&
                    item['area'] <= _currentAreaRangeValues.end;
            return matchesType &&
                matchesRoomType &&
                matchesPrice &&
                matchesArea;
          }).toList());

      // Sắp xếp danh sách dựa trên _selectedSort
      _SearchList = _SearchList.then((list) {
        if (_selectedSort == 'Mới nhất') {
          list.sort((a, b) => DateTime.parse(b['createdAt'])
              .compareTo(DateTime.parse(a['createdAt'])));
        } else if (_selectedSort == 'Giá tăng dần') {
          list.sort((a, b) => a['price'].compareTo(b['price']));
        } else if (_selectedSort == 'Giá giảm dần') {
          list.sort((a, b) => b['price'].compareTo(a['price']));
        }
        return list;
      });
    });
  }

  String _formatPrice(double value) {
    if (value < 1000) {
      return '${(value / 100).round()} trăm';
    } else {
      double millionValue = value / 1000;
      return millionValue % 1 == 0
          ? '${millionValue.toInt()} triệu'
          : '${millionValue.toStringAsFixed(1)} triệu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tìm kiếm',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800], // Màu xám đậm cho appbar
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return allSuggestions.where((String item) {
                  return item
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String item) {
                // Perform your search and state update
                // _SearchList = MongoDatabase.search_address_post(item);
                // setState(() {
                //   showList = true;
                //   _ListForFillter = _SearchList;
                //   _selectedType = "Cho thuê";
                //   _selectedTypeRoom = "Phòng";
                //   _selectedSort = "Mới nhất";
                //   _currentRangeValues = RangeValues(500, 20000);
                //   _currentAreaRangeValues = RangeValues(10, 100);
                // }); // Clear the text field
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        cursorColor: Colors.blue,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nhập từ khóa tìm kiếm',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[800],
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          //cursorColor: Colors.blue,
                        ),
                        onSubmitted: (String value) {
                          _SearchList =
                              MongoDatabase.search_address_post(value);
                          setState(() {
                            showList = true;
                            _ListForFillter = _SearchList;
                            _selectedType = "Cho thuê";
                            _selectedTypeRoom = "Phòng";
                            _selectedSort = "Mới nhất";
                            _currentRangeValues = RangeValues(500, 20000);
                            _currentAreaRangeValues = RangeValues(10, 100);
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
              optionsViewBuilder:
                  (context, onSelected, Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors
                        .grey[800], // Background color for the suggestion list
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 200.0),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(
                              option,
                              style:
                                  TextStyle(color: Colors.white), // Text color
                            ),
                            onTap: () {
                              onSelected(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            //SizedBox(height: 1),
            SizedBox(height: 20),
            if (showList)
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      children: [
                        Column(children: [
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _SearchList,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ));
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text("Error: ${snapshot.error}"));
                              } else if (snapshot.data != null &&
                                  snapshot.data!.isNotEmpty) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 2.9 / 1.3,
                                  ),
                                  itemCount: snapshot.data!.length,
                                  padding: EdgeInsets.all(8.0),
                                  // Khoảng cách giữa các mục
                                  itemBuilder: (context, index) {
                                    var post = snapshot.data![index];
                                    DateTime now = DateTime.now();
                                    DateTime postCreatedAt =
                                        DateTime.parse(post['createdAt']);
                                    Duration difference =
                                        now.difference(postCreatedAt);
                                    String formattedTime;
                                    if (difference.inMinutes < 60) {
                                      formattedTime =
                                          "${difference.inMinutes} phút trước";
                                    } else if (difference.inHours < 24) {
                                      formattedTime =
                                          "${difference.inHours} giờ trước";
                                    } else if (difference.inDays < 7) {
                                      formattedTime =
                                          "${difference.inDays} ngày trước";
                                    } else {
                                      formattedTime = DateFormat('dd/MM/yyyy')
                                          .format(postCreatedAt);
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
                                        // Action when a user card is tapped
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailPage(post: post)),
                                        );
                                      },
                                      child: Card(
                                        color: Colors.grey[800],
                                        margin: EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Stack(
                                                alignment: Alignment.bottomLeft,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
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
                                                        color: Colors
                                                            .blue, // Màu nền xanh
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10), // Độ bo góc nếu cần
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8.0,
                                                              vertical: 4.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.attach_money,
                                                            size: 15,
                                                            color: Colors
                                                                .white, // Màu icon
                                                          ),
                                                          SizedBox(width: 4.0),
                                                          Text(
                                                            gia,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: " " +
                                                              post['topic'],
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontFamily:
                                                                'Roboto',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 20),
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
                                                          text: " " +
                                                              post['address'],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Roboto',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 20),
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
                                                              post['area']
                                                                  .toString() +
                                                              " m²",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontFamily:
                                                                'Roboto',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 20),
                                                  Text(
                                                    '                                      ' +
                                                        formattedTime,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              } else {
                                return Center(
                                    child: Text(
                                  "No post found",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'Roboto', // hoặc chọn một font chữ khác phù hợp
                                    fontWeight: FontWeight
                                        .bold, // hoặc chọn kiểu chữ phù hợp
                                  ),
                                ));
                              }
                            },
                          ),
                        ]),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.grey[800],
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Loại tin:',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedType = 'Cho thuê';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedType ==
                                                                'Cho thuê'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Cho thuê',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedType =
                                                        'Tìm người ở ghép';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedType ==
                                                                'Tìm người ở ghép'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Tìm người ở ghép',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Loại cho thuê',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedTypeRoom = 'Phòng';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            _selectedTypeRoom ==
                                                                    'Phòng'
                                                                ? Colors.blue
                                                                : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Phòng',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedTypeRoom =
                                                        'Căn hộ';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            _selectedTypeRoom ==
                                                                    'Căn hộ'
                                                                ? Colors.blue
                                                                : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Căn hộ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedTypeRoom = 'Nhà';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            _selectedTypeRoom ==
                                                                    'Nhà'
                                                                ? Colors.blue
                                                                : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Nhà',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Sắp xếp theo',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedSort = 'Mới nhất';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedSort ==
                                                                'Mới nhất'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Mới nhất',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedSort =
                                                        'Giá tăng dần';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedSort ==
                                                                'Giá tăng dần'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Giá tăng dần',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedSort =
                                                        'Giá giảm dần';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedSort ==
                                                                'Giá giảm dần'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Giá giảm dần',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Giá',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          ),
                                        ),
                                        SliderTheme(
                                          data: SliderThemeData(
                                            thumbColor: Colors
                                                .blue, // Màu của con trượt (thumb)
                                            activeTrackColor: Colors
                                                .blue, // Màu của thanh đang được kéo
                                            inactiveTrackColor: Colors
                                                .grey, // Màu của thanh chưa được kéo
                                            overlayColor: Colors.blue.withOpacity(
                                                0.3), // Màu của lớp phủ khi kéo
                                            trackHeight:
                                                8.0, // Độ dày của thanh trượt
                                            thumbShape: RoundSliderThumbShape(
                                                enabledThumbRadius:
                                                    10.0), // Hình dạng của con trượt
                                            overlayShape: RoundSliderOverlayShape(
                                                overlayRadius:
                                                    20.0), // Hình dạng của lớp phủ
                                          ),
                                          child: RangeSlider(
                                            values: _currentRangeValues,
                                            min: 500,
                                            max: 20000,
                                            divisions: 39,
                                            onChanged: (RangeValues values) {
                                              setState(() {
                                                _currentRangeValues = values;
                                              });
                                            },
                                          ),
                                        ),

                                        // Hiển thị giá trị hiện tại
                                        if (_currentRangeValues.end < 20000)
                                          Text(
                                            'Giá từ ${_formatPrice(_currentRangeValues.start)} đến ${_formatPrice(_currentRangeValues.end)}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          )
                                        else
                                          Text(
                                            'Giá từ ${_formatPrice(_currentRangeValues.start)} đến ${_formatPrice(_currentRangeValues.end)}+',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Diện tích',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          ),
                                        ),
                                        SliderTheme(
                                          data: SliderThemeData(
                                            thumbColor: Colors
                                                .blue, // Màu của con trượt (thumb)
                                            activeTrackColor: Colors
                                                .blue, // Màu của thanh đang được kéo
                                            inactiveTrackColor: Colors
                                                .grey, // Màu của thanh chưa được kéo
                                            overlayColor: Colors.blue.withOpacity(
                                                0.3), // Màu của lớp phủ khi kéo
                                            trackHeight:
                                                8.0, // Độ dày của thanh trượt
                                            thumbShape: RoundSliderThumbShape(
                                                enabledThumbRadius:
                                                    10.0), // Hình dạng của con trượt
                                            overlayShape: RoundSliderOverlayShape(
                                                overlayRadius:
                                                    20.0), // Hình dạng của lớp phủ
                                          ),
                                          child: RangeSlider(
                                            values: _currentAreaRangeValues,
                                            min: 10,
                                            max: 100,
                                            divisions: 9,
                                            onChanged: (RangeValues values) {
                                              setState(() {
                                                _currentAreaRangeValues =
                                                    values;
                                              });
                                            },
                                          ),
                                        ),

                                        if (_currentAreaRangeValues.end < 100)
                                          Text(
                                            'Giá từ ${_currentAreaRangeValues.start} m2 đến ${_currentAreaRangeValues.end} m2',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          )
                                        else
                                          Text(
                                            'Giá từ ${_currentAreaRangeValues.start} m2 đến ${_currentAreaRangeValues.end} m2+',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          ),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .all<Color>(Colors
                                                        .blue), // Màu nền xanh
                                          ),
                                          onPressed: () {
                                            filter_treatment(
                                                _selectedType,
                                                _selectedTypeRoom,
                                                _selectedSort,
                                                _currentRangeValues,
                                                _currentAreaRangeValues);
                                            Navigator.pop(
                                                context); // Đóng bottom sheet sau khi áp dụng
                                          },
                                          child: Text(
                                            'Áp dụng',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          ),
                                        ),
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
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
