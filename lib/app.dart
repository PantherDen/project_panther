import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/util/const.dart';
import 'package:project/util/theme_config.dart';
import 'package:project/views/screens/auth/forgot_password.dart';
import 'package:project/views/screens/auth/login.dart';
import 'package:project/views/screens/auth/register.dart';
import 'package:project/views/screens/main_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Color(0xff3E236E)));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: themeData(ThemeConfig.lightTheme),
      // darkTheme: themeData(ThemeConfig.darkTheme),
      home: SplashScreen(),
    );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      appBarTheme: AppBarTheme(color: Color(0xff3E236E)),
      primaryColor: Color(0xff3E236E),
      // textTheme: GoogleFonts.sourceSansProTextTheme(
      //   theme.textTheme,
      // ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  checkUser() async {
    await Future.delayed(Duration(seconds: 1));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => sharedPreferences.containsKey('userEmail')
              ? MainScreen()
              : LoginScreen()),
    );
  }

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xff3E236E),
      body: Container(
        width: w,
        height: h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              '${Constants.appName}',
              style: TextStyle(
                fontSize: 40.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Text(
              "Loading...",
              style: TextStyle(fontSize: 19, color: Colors.grey),
            ),
            SizedBox(
              height: h * .2,
            )
          ],
        ),
      ),
    );
  }
}
