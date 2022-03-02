import 'package:flutter/material.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:provider/src/provider.dart';
import 'package:project/Models/follower_model.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/follower_provider.dart';
import 'package:project/Providers/post_provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/util/data.dart';
import 'package:project/views/screens/profile/profile_detail.dart';

class Friends extends StatefulWidget {
  Function openChatTab;
  Friends({this.openChatTab});
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  bool loading = true;
  UserProvider userProvider;
  getAllUsers() async {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    await Provider.of<FollowerProvider>(context, listen: false)
        .getAllUserBase();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    getAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FollowerProvider>();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration.collapsed(
              hintText: 'Search', hintStyle: TextStyle(color: Colors.white)),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.filter_list,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: !loading
          ? ListView.separated(
              padding: EdgeInsets.all(10),
              separatorBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 0.5,
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Divider(),
                  ),
                );
              },
              itemCount: fp.allUsers.length,
              itemBuilder: (BuildContext context, int index) {
                FollowerModel followerModel = fp.allUsers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    leading: showProfilePic(followerModel.userAvatar),
                    contentPadding: EdgeInsets.all(0),
                    title: Text(followerModel.userName),
                    subtitle: Text(followerModel.userStatus),
                    trailing: followerModel.imFollowing
                        ? FlatButton(
                            child: Text(
                              "Unfollow",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            color: Colors.grey,
                            onPressed: () async {
                              bool unfollow = await fp.unfollowUser(
                                  fp.allUsers[index],
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .userModel);
                              if (unfollow) {
                                for (int i = 0;
                                    i < userProvider.userModel.following.length;
                                    i++) {
                                  if (userProvider.userModel.following[i].uid ==
                                      fp.allUsers[index].uid) {
                                    userProvider.userModel.following
                                        .removeAt(i);
                                  }
                                }
                              }
                            },
                          )
                        : FlatButton(
                            child: Text(
                              "Follow",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              bool follow = await fp.followUser(
                                  fp.allUsers[index],
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .userModel);
                              if (follow) {
                                userProvider.userModel.following
                                    .add(fp.allUsers[index]);
                              }
                            },
                          ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileDetailScreen(
                                    id: fp.allUsers[index].uid,
                                    openChatTab:
                                        (contextOfOtherScreen, UserModel usr) {
                                      Navigator.of(contextOfOtherScreen).pop();
                                      widget.openChatTab(usr);
                                    },
                                  )));
                    },
                  ),
                );
              },
            )
          : progress(),
    );
  }

  Widget showProfilePic(String av) {
    double h = MediaQuery.of(context).size.height;
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: h * .03,
      backgroundImage: Image.asset('assets/images/loading.gif').image,
      child: CircleAvatar(
        radius: h * .03,
        backgroundColor: Colors.transparent,
        backgroundImage: av != null && av.isNotEmpty
            ? NetworkImage(av)
            : Image.asset('assets/images/no_profile.png').image,
      ),
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
}
