import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/follower_model.dart';
import 'package:project/Models/post_model.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/follower_provider.dart';
import 'package:project/Providers/post_provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/util/data.dart';
import 'package:project/views/screens/posts/create_posts.dart';
import 'package:project/views/screens/profile/edit_profile.dart';

class ProfileDetailScreen extends StatefulWidget {
  String id;
  Function openChatTab;
  ProfileDetailScreen({this.id, this.openChatTab});
  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  double w, h;
  UserProvider userProvider;
  PostProvider postProvider;
  UserModel usr;
  bool loading = true;
  List<PostModel> allPosts = [];
  bool following = false;

  getUserData() async {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);

    var posts = await postProvider.getAllIdPosts(widget.id);
    UserModel u = await userProvider.getCurrentUserById(widget.id);
    for (FollowerModel fm in userProvider.userModel.following) {
      if (fm.uid == widget.id) {
        setState(() {
          following = true;
        });
      }
    }

    setState(() {
      usr = u;
      allPosts = posts;
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
                    !following
                        ? FlatButton(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Follow",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                )
                              ],
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              FollowerProvider followProvider =
                                  Provider.of<FollowerProvider>(context,
                                      listen: false);
                              FollowerModel flw = new FollowerModel(
                                  uid: usr.email,
                                  userName: usr.name,
                                  userAvatar: usr.avatar,
                                  userStatus: usr.status);
                              bool follow = await followProvider.followUser(
                                  flw,
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .userModel);
                              if (follow) {
                                setState(() {
                                  usr.followers.add(flw);
                                  following = true;
                                });
                              }
                            },
                          )
                        : FlatButton(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Message",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.message_outlined,
                                  color: Colors.white,
                                  size: 20,
                                )
                              ],
                            ),
                            color: Color(0xff3E236E),
                            onPressed: () {
                              widget.openChatTab(context, usr);
                            },
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
                      itemCount: allPosts.length,
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
                              allPosts[index].postImg,
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
          activeColor: Color(0xff3E236E).withOpacity(.6),
          inactiveColor: Color(0xff3E236E).withOpacity(.2),
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
