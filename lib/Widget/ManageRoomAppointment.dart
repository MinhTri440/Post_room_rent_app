import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/Widget/InformationAcount.dart';
import 'package:post_house_rent_app/Widget/Search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';
import '../env.dart';
import '../provider/ShowListPostProvider.dart';
import 'DetailPage.dart';
import 'LoginScreen.dart';
import 'ManagePosts.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:provider/provider.dart';

class ManageRoomAppointment extends StatefulWidget {
  @override
  _ManageRoomAppointmentState createState() => _ManageRoomAppointmentState();
}

class _ManageRoomAppointmentState extends State<ManageRoomAppointment> {
  bool _isLoadingAccept = false;
  Map<String, bool> _isLoadingCancelMap = {};

  void _AcceptBooking(String CustomerMail, String idOwner, String id) async {
    setState(() {
      _isLoadingAccept = true;
    });
    String username = 'tri6561@gmail.com';
    String password = PASSMAIL;

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'App cho thuê phòng')
      ..recipients.add(CustomerMail)
      ..subject = 'Lịch hẹn đặt phòng'
      ..text =
          'Lịch hẹn xem phòng của bạn đã được đồng ý. Bạn có thể liên hệ thông tin của chủ bài để trao đổi thêm.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi. Vui lòng thử lại sau')),
      );
    } finally {
      bool delete = await MongoDatabase.DeleteBooking(id);
      await Provider.of<ShowListPostProvider>(context, listen: false)
          .refreshListBooking();
      setState(() {
        _isLoadingAccept = false;
      });
    }
  }

  void _showCancellationDialog(
      String bookingId, String mailBooking, String ownerId) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Lý do từ chối',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: 'Nhập lý do từ chối',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                String reason = reasonController.text;
                if (reason == null || reason == '') {
                  reason = 'Không rõ';
                }
                Navigator.of(context).pop(); // Close the dialog
                _cancelBooking(bookingId, reason, mailBooking, ownerId);
              },
              child: Text(
                'Xác nhận',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cancelBooking(String bookingId, String reason, String mailBooking,
      String ownerId) async {
    setState(() {
      _isLoadingCancelMap[bookingId] = true;
    });
    String username = 'tri6561@gmail.com';
    String password = PASSMAIL;

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'App cho thuê phòng')
      ..recipients.add(mailBooking)
      ..subject = 'Lịch hẹn đặt phòng'
      ..text =
          'Lịch hẹn xem phòng của bạn đã bị từ chối. Lý do: $reason. Bạn có thể liên hệ thông tin của chủ bài để trao đổi thêm.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi. Vui lòng thử lại sau')),
      );
    } finally {
      bool delete = await MongoDatabase.DeleteBooking(bookingId);
      await Provider.of<ShowListPostProvider>(context, listen: false)
          .refreshListBooking();
      setState(() {
        _isLoadingCancelMap[bookingId] = false;
      });
    }
  }

  void openDetailPage(String idPostBooking) async {
    Map<String, dynamic>? getPost =
        await MongoDatabase.getPostById(idPostBooking!);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(post: getPost ?? {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lịch hẹn',
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
          if (provider.listBooking.isEmpty) {
            return Center(child: Text("Không có lịch hẹn"));
          } else {
            return ListView.builder(
              itemCount: provider.listBooking.length,
              itemBuilder: (context, index) {
                var appointment = provider.listBooking[index];
                String bookingId = appointment['_id'].toString();
                return Card(
                  color: Colors.grey[800],
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month, color: Colors.blue),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Ngày: ' + appointment['Day'],
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 20),
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.blue),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Giờ: ' + appointment['Time'],
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                            Icon(Icons.account_circle_rounded,
                                color: Colors.blue),
                            const SizedBox(width: 4.0),
                            Text(
                              'Người dùng: ' +
                                  appointment['username_person_booking'],
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                              'Số điện thoại: ' +
                                  appointment['phone_person_booking'],
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.note, color: Colors.blue),
                            const SizedBox(width: 4.0),
                            Text(
                              'Ghi chú: ' + appointment['Note'],
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.note_alt_rounded, color: Colors.blue),
                            const SizedBox(width: 4.0),
                            TextButton(
                              onPressed: () =>
                                  openDetailPage(appointment['idPost']),
                              child: Text(
                                'bài đăng khách hẹn xem',
                                style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: _isLoadingAccept
                                  ? null
                                  : () {
                                      _AcceptBooking(
                                        appointment['email_person_booking'],
                                        appointment['ownerId'],
                                        bookingId,
                                      );
                                    },
                              child: _isLoadingAccept
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                              // : Text(
                              //     'Đồng ý',
                              //     style: TextStyle(
                              //       fontFamily: 'Roboto',
                              //       color: Colors.white,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isLoadingCancelMap[bookingId] == true
                                  ? null
                                  : () {
                                      _showCancellationDialog(
                                        bookingId,
                                        appointment['email_person_booking'],
                                        appointment['ownerId'],
                                      );
                                    },
                              child: _isLoadingCancelMap[bookingId] == true
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
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
