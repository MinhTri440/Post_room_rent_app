import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:post_house_rent_app/MongoDb_Connect.dart';
import 'package:post_house_rent_app/env.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:post_house_rent_app/Widget/LoginScreen.dart';

import '../provider/ShowListPostProvider.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  BookingScreen({required this.post});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = true; // Biến để quản lý trạng thái vòng xoay
  String? UserName = '';
  String? UserEmail = '';
  String? UserPhone = '';
  final TextEditingController _NoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id_person_booking =
        await MongoDatabase.get_IdfromUser(prefs.getString('email'));
    Map<String, dynamic>? user =
        await MongoDatabase.getUserById(id_person_booking);
    if (mounted) {
      setState(() {
        UserName = user?['username'];
        UserEmail = user?['email'];
        UserPhone = user?['phone'];
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  void _confirmBooking() async {
    setState(() {
      isLoading = true; // Bắt đầu hiển thị vòng xoay
    });

    String? mailOwner = widget.post['ownerId'];
    mailOwner = await MongoDatabase.getEmailfrom_Id(mailOwner);

    if (selectedDate != null && selectedTime != null) {
      // Luu database
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id_person_booking =
          await MongoDatabase.get_IdfromUser(prefs.getString('email'));
      String? IdPost = widget.post['_id'].toString();
      Map<String, dynamic>? user =
          await MongoDatabase.getUserById(id_person_booking);
      IdPost =
          IdPost?.substring(IdPost.indexOf('"') + 1, IdPost.lastIndexOf('"'));
      bool createBooking = await MongoDatabase.create_Room_Viewing_Appointment(
          widget.post['ownerId'],
          UserName!,
          UserEmail!,
          UserPhone!,
          "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
          "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
          IdPost!,
          _NoteController.text);
      await Provider.of<ShowListPostProvider>(context, listen: false)
          .refreshListBooking();
      if (createBooking == true) {
        // Xử lí gửi email
        String username = 'tri6561@gmail.com';
        String password = PASSMAIL;

        final smtpServer = gmail(username, password);

        final message = Message()
          ..from = Address(username, 'App cho thuê phòng')
          ..recipients.add(mailOwner)
          ..subject = 'Lịch hẹn đặt phòng'
          ..text =
              'Bạn có lịch hẹn xem phòng vào ngày ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} lúc ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')} với người dùng ${(UserName)}. Vui lòng xác nhận hoặc từ chối trong ứng dụng để phản hồi cho người xem phòng.';

        try {
          final sendReport = await send(message, smtpServer);
          print('Message sent: ' + sendReport.toString());
          // Hoàn thành gửi email, hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đặt lịch thành công')),
          );
        } on MailerException catch (e) {
          print('Message not sent. \n' + e.toString());
          for (var p in e.problems) {
            print('Problem: ${p.code}: ${p.msg}');
          }
          // Hiển thị thông báo khi gửi email thất bại
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Đặt lịch không thành công. Vui lòng thử lại sau')),
          );
        } finally {
          setState(() {
            isLoading = false; // Ẩn vòng xoay khi hoàn thành
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt lịch lỗi vui lòng thử lại')),
        );
        setState(() {
          isLoading = false; // Ẩn vòng xoay nếu có lỗi
        });
      }
    } else {
      // Hiển thị thông báo cho người dùng nếu chưa chọn ngày giờ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ngày và giờ')),
      );
      setState(() {
        isLoading = false; // Ẩn vòng xoay nếu có lỗi
      });
    }
  }

  String getFormattedDate() {
    if (selectedDate == null) return 'Chưa chọn ngày';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  String getFormattedTime() {
    if (selectedTime == null) return 'Chưa chọn giờ';
    return '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đặt lịch xem phòng',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child:
                isLoading // Kiểm tra isLoading để hiển thị vòng xoay hoặc nút xác nhận
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ) // Nếu isLoading true thì hiển thị vòng xoay
                    : SingleChildScrollView(
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            color:
                                Colors.grey[800], // Đặt màu nền cho container
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Icon(Icons.account_circle_rounded,
                                          color: Colors.blue),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        "UserName:        ${(UserName)}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily:
                                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                                          fontWeight: FontWeight
                                              .bold, // hoặc chọn kiểu chữ phù hợp
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.0),
                                  Row(
                                    children: [
                                      Icon(Icons.phone, color: Colors.blue),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        "Số điện thoại:   ${(UserPhone)}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily:
                                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                                          fontWeight: FontWeight
                                              .bold, // hoặc chọn kiểu chữ phù hợp
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.0),
                                  Row(
                                    children: [
                                      Text(
                                        "Thời gian *",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily:
                                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                                          fontWeight: FontWeight
                                              .bold, // hoặc chọn kiểu chữ phù hợp
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: () => _selectDate(context),
                                    child: Row(
                                      //mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: Colors
                                                .white), // Biểu tượng lịch
                                        SizedBox(
                                            width:
                                                8.0), // Khoảng cách giữa biểu tượng và văn bản
                                        Text(
                                          'Chọn ngày *',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 32.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Text(
                                    getFormattedDate(),
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: () => _selectTime(context),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            color: Colors
                                                .white), // Biểu tượng lịch
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Chọn giờ *',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 32.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Text(
                                    getFormattedTime(),
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Ghi chú :",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily:
                                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                                          fontWeight: FontWeight
                                              .bold, // hoặc chọn kiểu chữ phù hợp
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    cursorColor: Colors.blue,
                                    decoration: InputDecoration(
                                      hintText: 'Nhập ghi chú (nếu muốn)',
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontFamily:
                                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                                        fontWeight: FontWeight.bold,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[600],
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors
                                                .blue), // Border when focused
                                      ),
                                      prefixIcon: Icon(
                                        Icons.topic,
                                        color: Colors
                                            .blue, // Color of the email icon
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                      fontWeight: FontWeight.bold,
                                    ),
                                    controller: _NoteController,
                                    onChanged: (value) {
                                      _NoteController.text = value;
                                    },
                                  ),
                                  SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: _confirmBooking,
                                    child: Text(
                                      'Xác nhận lịch hẹn',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 32.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
      ),
      backgroundColor: Colors.black,
    );
  }
}
