import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:post_house_rent_app/Widget/ForgotPassword.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/provider/ListFavouriteProvider.dart';
import 'package:provider/provider.dart';
import '../MongoDb_Connect.dart';
import '../provider/ShowListPostProvider.dart';
import 'Register.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đăng nhập',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // or choose another appropriate font
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[800], // Dark grey color for appbar
      ),
      backgroundColor: Colors.black, // Black color for Scaffold body
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _isLoading = false;
  String? _loginError;
  late SharedPreferences prefs;
  bool _disposed = false; // Variable to check if widget has been disposed

  @override
  void dispose() {
    _disposed = true; // Mark widget as disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50.0), // Add some space at the top
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
            controller: _emailController,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white, // Text color when not focused
            ),
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              labelText: 'Nhập email *',
              errorText: _emailErrorText,
              labelStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                // Border when focused
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.grey), // Border when not focused
              ),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.grey, // Color of the email icon
              ),
            ),
          ),
          SizedBox(height: 20.0),
          TextField(
            controller: _passwordController,
            style: TextStyle(
              fontFamily: 'Roboto', // Font set to Roboto
              color: Colors.white,
            ),
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              labelText: 'Nhập mật khẩu *',
              errorText: _passwordErrorText,
              labelStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blue), // Border when focused
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.grey), // Border when not focused
              ),
              prefixIcon: Icon(
                Icons.password,
                color: Colors.grey, // Color of the email icon
              ),
            ),
            obscureText: true,
          ),
          SizedBox(height: 20.0),
          Container(
            width: MediaQuery.of(context).size.width, // Screen width
            child: ElevatedButton(
              onPressed: _isLoading || _disposed
                  ? null
                  : _login, // Check conditions to enable/disable button
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white)) // Chỉnh màu ở đây),
                  : Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold, // Font set to Roboto
                      ),
                    ),
            ),
          ),

          if (_loginError != null) ...[
            SizedBox(height: 20.0),
            Text(
              _loginError!,
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Roboto',
              ),
            ),
          ],
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RegisterPage()));
                  print('Navigate to register page');
                },
                child: Text(
                  'Đăng kí',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage()));
                  print('Navigate to forgot password page');
                },
                child: Text(
                  'Quên mật khẩu ?',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Hoặc',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.0),
          OutlinedButton.icon(
            onPressed: () {
              signInWithGoogle();
              print('Login with Gmail');
            },
            style: ButtonStyle(
              side: MaterialStateProperty.all<BorderSide>(
                BorderSide(color: Colors.blue), // Blue border color
              ),
            ),
            icon: Icon(Icons.mail, color: Colors.blue),
            label: Text(
              'Login with Gmail',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(height: 50.0), // Add some space at the bottom
        ],
      ),
    );
  }

  void _login() async {
    if (_disposed) return; // Check if widget has been disposed
    String email = _emailController.text;
    String password = _passwordController.text;

    bool emailValid = EmailValidator.validate(email);
    bool passwordValid = password.isNotEmpty && password.length >= 6;

    setState(() {
      _emailErrorText = emailValid ? null : 'Email sai hoặc chưa nhập email';
      _passwordErrorText =
          passwordValid ? null : 'Mật khẩu không được để trống và từ 6 kí tự';
      _loginError = null;
    });

    if (emailValid && passwordValid) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          bool updatepass =
              await MongoDatabase.updatePasswordUser(email, password);
          print("Dang nhap thanh cong");
          prefs = await SharedPreferences.getInstance();
          prefs.setBool('login', false);
          Map<String, dynamic>? user = await MongoDatabase.getUser(email);
          String userEmail = user?['email'];
          String username = user?['username'];
          String userImage = user?['image'];
          prefs.setString('username', username);
          prefs.setString('email', userEmail);
          prefs.setString('image', userImage);
          prefs.setString('type', 'system');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
          Provider.of<ShowListPostProvider>(context, listen: false)
              .refreshShowListUserAndListPostPost();
          Provider.of<FavoritePostProvider>(context, listen: false)
              .refreshFavoritePosts();
        } else {
          setState(() {
            _loginError = "Account or password is incorrect";
          });
        }
      } catch (e) {
        setState(() {
          _loginError = "Account or password is incorrect";
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  signInWithGoogle() async {
    if (_disposed) return; // Check if widget has been disposed
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(googleUser!.displayName);
      await user.updatePhotoURL(googleUser!.photoUrl);
      await user.reload();
      bool checkAccount = await MongoDatabase.checkGmailtoCreate(
          user.email, user.displayName, user.phoneNumber, user.photoURL);
      print("Dang nhap thanh cong");
      prefs = await SharedPreferences.getInstance();
      prefs.setBool('login', false);
      Map<String, dynamic>? search = await MongoDatabase.getUser(user.email);
      String userEmail = search?['email'];
      String username = search?['username'];
      String userImage = search?['image'];
      prefs.setString('username', username);
      prefs.setString('email', userEmail);
      prefs.setString('image', userImage);
      prefs.setString('type', 'gmail');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
      Provider.of<ShowListPostProvider>(context, listen: false)
          .refreshShowListUserAndListPostPost();
      Provider.of<FavoritePostProvider>(context, listen: false)
          .refreshFavoritePosts();
    }
  }
}
