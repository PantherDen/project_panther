import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/post_provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/util/data.dart';
import 'package:project/views/screens/posts/create_posts.dart';
import 'package:project/views/screens/profile/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static Random random = Random();
  double w, h;
  UserProvider userProvider;
  PostProvider postProvider;
  UserModel usr;
  bool loading = true;

  getUserData() async {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.getAllMyPosts(userProvider.userModel.email);
    userProvider.getCurrentUser();

    setState(() {
      usr = userProvider.userModel;
      loading = false;
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    final ps = context.watch<PostProvider>();
    return Scaffold(
      body: !loading
          ? SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 60),
                    showProfilePic(usr.avatar),
                    SizedBox(height: 10),
                    Text(
                      usr.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      usr.status != null ? usr.status : '',
                      style: TextStyle(),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FlatButton(
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          color: Colors.grey,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfileScreen())).then((value) {
                              setState(() {
                                usr = userProvider.userModel;
                              });
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        // ignore: deprecated_member_use
                        FlatButton(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          color: Color(0xff3E236E),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreatePostsScreen()));
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _buildCategory("Posts",
                              postProvider.myPosts.length.toString(), () {}),
                          _buildCategory("Followers",
                              usr.followers.length.toString(), () {}),
                          _buildCategory("Following",
                              usr.following.length.toString(), () {}),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      primary: false,
                      padding: EdgeInsets.all(5),
                      itemCount: ps.myPosts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 200 / 200,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              ps.myPosts[index].postImg,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : progress(),
    );
  }

  Widget progress() {
    return Center(
      child: NutsActivityIndicator(
          radius: 15,
          activeColor: Color(0xff447727).withOpacity(.6),
          inactiveColor: Color(0xff447727).withOpacity(.2),
          tickCount: 11,
          startRatio: 0.55,
          animationDuration: Duration(milliseconds: 600)),
    );
  }

  Widget _buildCategory(String title, String count, Function callback) {
    return GestureDetector(
      onTap: () {
        callback();
      },
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(),
          ),
        ],
      ),
    );
  }

  Widget showProfilePic(String av) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: h * .1,
      backgroundImage: Image.asset('assets/images/loading.gif').image,
      child: CircleAvatar(
        radius: h * .2,
        backgroundColor: Colors.transparent,
        backgroundImage: av != null && av.isNotEmpty
            ? NetworkImage(av)
            : Image.asset('assets/images/no_profile.png').image,
      ),
    );
  }
}
