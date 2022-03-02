import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/Providers/post_provider.dart';
import 'package:project/views/screens/posts/saved_posts.dart';
import 'package:project/views/widgets/post_item.dart';
import 'package:project/util/data.dart';

import 'auth/login.dart';

class Home extends StatefulWidget {
  Function openProfile;
  Function openChatTab;
  Home({this.openProfile, this.openChatTab});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PostProvider postProvider;

  logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('userEmail');
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  loadFeed() async {
    postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.getAllPosts();
  }

  @override
  void initState() {
    loadFeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ps = context.watch<PostProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Feeds"),
        centerTitle: true,
        leading: Center(
          child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SavedPostScreen(
                              openProfile: widget.openProfile,
                              openChatTab: widget.openChatTab,
                            ))).then((value) {
                  loadFeed();
                });
              },
              child: Icon(Icons.save)),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout,
            ),
            onPressed: () {
              logout();
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemCount: ps.allPosts.length,
        itemBuilder: (BuildContext context, int index) {
          return PostItem(
            postModel: ps.allPosts[index],
            openProfile: widget.openProfile,
            openChat: widget.openChatTab,
          );
        },
      ),
    );
  }
}
