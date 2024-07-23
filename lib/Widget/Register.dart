import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:post_house_rent_app/Widget/LoginScreen.dart';
import 'package:post_house_rent_app/model/User.dart';
import '../MongoDb_Connect.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _usernameErrorText;
  String? _emailErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;
  String? _phoneErrorText;
  bool _isLoading = false;
  String _registerError = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          child: Image.network(
            'https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/assets%2Fhome.png?alt=media&token=910915c9-9227-4d6c-b23a-11d3b6975e2b',
            fit: BoxFit.cover,
            width: 180.0,
            height: 180.0,
          ),
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _usernameController,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            labelText: 'Tên đăng nhập *',
            errorText: _usernameErrorText,
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
              Icons.account_circle_rounded,
              color: Colors.grey, // Color of the email icon
            ),
          ),
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _emailController,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            labelText: 'Email của bạn *',
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
        TextField(
          controller: _passwordController,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            labelText: 'Mật khẩu *',
            errorText: _passwordErrorText,
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
              Icons.password,
              color: Colors.grey, // Color of the email icon
            ),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _confirmPasswordController,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu *',
            errorText: _confirmPasswordErrorText,
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
              Icons.password_rounded,
              color: Colors.grey, // Color of the email icon
            ),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _phoneController,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            labelText: 'Số điện thoại *',
            errorText: _phoneErrorText,
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
              Icons.phone,
              color: Colors.grey, // Color of the email icon
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Container(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue), // Blue background
              foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white), // White text color
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      4.0), // Adjust the radius to make the corners more square
                ),
              ),
            ),
            child: _isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : Text(
                    'Đăng kí',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          _registerError,
          style: TextStyle(
              color: _registerError == 'Register successful.'
                  ? Colors.teal
                  : Colors.red),
        ),
      ],
    );
  }

  bool _isPasswordValid(String password) {
    RegExp regex = RegExp(r'^.{6,}$');
    return regex.hasMatch(password);
  }

  bool _isPhoneValid(String phone) {
    RegExp regex = RegExp(r'^\+?[0-9]{10,15}$');
    return regex.hasMatch(phone);
  }

  void _register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String phone = _phoneController.text;

    bool usernameValid = username.isNotEmpty;
    bool emailValid = EmailValidator.validate(email);
    bool passwordValid = _isPasswordValid(password);
    bool confirmPasswordValid = password == confirmPassword;
    bool phoneValid = _isPhoneValid(phone);
    String? imageurl = await getUserImageUrl();

    setState(() {
      _usernameErrorText =
          usernameValid ? null : 'Tên đăng nhập không thể trống';
      _emailErrorText = emailValid ? null : 'Vui lòng nhập email';
      _passwordErrorText =
          passwordValid ? null : 'Mật khẩu phải 6 kí tự trở lên';
      _confirmPasswordErrorText =
          confirmPasswordValid ? null : 'Không giống với mật khẩu';
      _phoneErrorText = phoneValid ? null : 'Không phải số điện thoại';
      _registerError = '';
    });

    if (usernameValid &&
        emailValid &&
        passwordValid &&
        confirmPasswordValid &&
        phoneValid) {
      setState(() {
        _isLoading = true;
      });

      UserMongo newUser = UserMongo(
          username: username,
          email: email,
          password: password,
          phone: phone,
          image: imageurl,
          type: "system",
          createdAt: DateTime.now(),
          updateAt: DateTime.now());

      bool userCreated = await MongoDatabase.createUser(newUser);

      setState(() {
        _isLoading = false;
      });

      if (userCreated) {
        try {
          UserCredential authResult =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          setState(() {
            _registerError = "Đăng kí thành công.";
            _usernameController.text = '';
            _emailController.text = '';
            _passwordController.text = '';
            _confirmPasswordController.text = '';
            _phoneController.text = '';
          });
        } catch (e) {
          setState(() {
            _registerError = "Đăng kí thât bại: $e";
          });
        }
      } else {
        setState(() {
          _registerError =
              "Email này đã được đăng kí tài khoản vui lòng chọn email khác";
        });
      }
    }
  }

  Future<String?> getUserImageUrl() async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('images/user.jpg');
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error getting user image URL: $e');
      return null;
    }
  }
}
