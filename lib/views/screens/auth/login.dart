import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/util/animations.dart';
import 'package:project/util/const.dart';
import 'package:project/util/enum.dart';
import 'package:project/util/router.dart';
import 'package:project/util/validations.dart';
import 'package:project/views/screens/auth/forgot_password.dart';
import 'package:project/views/screens/auth/register.dart';
import 'package:project/views/screens/main_screen.dart';
import 'package:project/views/widgets/custom_button.dart';
import 'package:project/views/widgets/custom_text_field.dart';
import 'package:project/util/extensions.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  login() async {
    if (email.text.isNotEmpty && password.text.isNotEmpty) {
      if (!email.text.endsWith('@pvamu.edu')) {
        Toast.show('Invalid email format!', context);
        return;
      }
      setState(() {
        loading = true;
      });
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      bool login =
          await userProvider.loginUser(email.text, password.text, context);
      setState(() {
        loading = false;
      });
      if (login) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } else {
      Toast.show('All fields are required!', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        width: w,
        height: h,
        child: Row(
          children: [
            buildLottieContainer(),
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: buildForm(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          '${Constants.appName}',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ).fadeInList(0, false),
        SizedBox(height: 30.0),
        textField("Email", email, false, 1),
        SizedBox(
          height: 20,
        ),
        textField("Password", password, true, 2),
        Column(
          children: [
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.centerRight,
              child: FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen()));
                },
                child: Text('Forgot Password?'),
              ),
            ),
          ],
        ).fadeInList(5, false),
        button("Submit", () {
          login();
        }),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Don\'t have an account?'),
            FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text('Register'),
            ),
          ],
        ).fadeInList(6, false)
      ],
    );
  }

  Widget textField(String hintText, var controller, bool paswordField, int id) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: TextField(
        enabled: !loading,
        style: TextStyle(
          fontSize: 15.0,
        ),
        controller: controller,
        obscureText: paswordField,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            border: border(),
            focusedBorder: border(),
            disabledBorder: border()),
      ),
    ).fadeInList(id, false);
  }

  border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
      borderSide: BorderSide(
        color: Color(0xffB3ABAB),
        width: 1.0,
      ),
    );
  }

  Widget button(String text, Function callback) {
    return Container(
      height: 50.0,
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
        onPressed: callback,
        color: Color(0xff3E236E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: !loading
            ? Text(
                "$text",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              )
            : Center(
                child: Container(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )),
      ),
    ).fadeInList(3, false);
  }

  buildLottieContainer() {
    final screenWidth = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      width: screenWidth < 700 ? 0 : screenWidth * 0.5,
      duration: Duration(milliseconds: 500),
      color: Theme.of(context).accentColor.withOpacity(0.3),
      child: Center(
        child: Lottie.asset(
          AppAnimations.chatAnimation,
          height: 400,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
