import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/views/screens/chat/one_to_one/Chat.dart';
import 'package:project/views/screens/profile/profile.dart';
import 'package:project/views/widgets/icon_badge.dart';
import 'package:project/views/screens/chat/chats.dart';
import 'package:project/views/screens/friends.dart';
import 'package:project/views/screens/home.dart';
import 'package:project/views/screens/notifications.dart';
import 'package:project/views/screens/profile.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController;
  int _page = 0;
  @override
  void initState() {
    User user = FirebaseAuth.instance.currentUser;
    print("user id = ${user.uid}");
    super.initState();
    _pageController = PageController(initialPage: 0);
    Provider.of<UserProvider>(context, listen: false).getCurrentUser();
  }

  openConversation(UserModel usr) {
    navigationTapped(2);
    // open chat screen
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                  peerAvatar: usr.avatar,
                  peerId: usr.id,
                  peerName: usr.name,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          Home(
            openProfile: () {
              navigationTapped(3);
            },
            openChatTab: (UserModel usr) {
              openConversation(usr);
            },
          ),
          Friends(
            openChatTab: (UserModel usr) {
              openConversation(usr);
            },
          ),
          Chats(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Theme.of(context).primaryColor,
          // sets the active color of the `BottomNavigationBar` if `Brightness` is light
          primaryColor: Theme.of(context).accentColor,
          textTheme: Theme.of(context).textTheme.copyWith(
                caption: TextStyle(color: Colors.grey[500]),
              ),
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
              ),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
