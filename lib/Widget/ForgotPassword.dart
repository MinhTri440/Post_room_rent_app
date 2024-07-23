import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'LoginScreen.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailErrorText;
  String? _resetPasswordError;
  bool _isSendingResetEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quên mật khẩu',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/assets%2Fhome.png?alt=media&token=910915c9-9227-4d6c-b23a-11d3b6975e2b',
                fit: BoxFit.cover,
                width: 150.0,
                height: 150.0,
              ),
            ),
            SizedBox(height: 50.0),
            TextField(
              controller: _emailController,
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                labelText: 'Nhập email muốn lấy lại mật khẩu',
                errorText: _emailErrorText,
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                prefixIcon: Icon(
                  Icons.mail,
                  color: Colors.grey, // Color of the email icon
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: _isSendingResetEmail ? null : _sendResetEmail,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: _isSendingResetEmail
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Text(
                        'Gửi email khôi phục',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (_resetPasswordError != null) ...[
              SizedBox(height: 20.0),
              Text(
                _resetPasswordError!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _sendResetEmail() async {
    String email = _emailController.text;
    bool emailValid = _validateEmail(email);

    setState(() {
      _emailErrorText =
          emailValid ? null : 'Vui lòng nhập email và đúng định dạng';
      _resetPasswordError = null;
    });

    if (emailValid) {
      setState(() {
        _isSendingResetEmail = true;
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _showResetEmailSentDialog();
      } catch (e) {
        setState(() {
          _resetPasswordError = 'Gửi không được thử lại sau.';
          _isSendingResetEmail = false;
        });
      }
    }
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showResetEmailSentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Gửi email khôi phục'),
          content: Text('Một email sẽ được gửi để cập nhật mật khẩu của bạn'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
