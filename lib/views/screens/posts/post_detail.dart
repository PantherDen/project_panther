import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/post_model.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/post_provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/views/screens/chat/one_to_one/ColorConstants.dart';
import 'package:project/views/screens/profile/profile_detail.dart';
import 'package:toast/toast.dart';

class PostDetailScreen extends StatefulWidget {
  PostModel postModel;
  Function openProfile;
  Function openChat;
  PostDetailScreen({this.postModel, this.openProfile, this.openChat});

  @override
  _PostDetailScreenState createState() =>
      _PostDetailScreenState(postModel: postModel);
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel postModel;
  UserProvider userProvider;
  double w, h;
  bool liked = false;
  TextEditingController commentController = new TextEditingController();

  checkMyLike() {
    liked = false;
    for (LikeModel likeModel in postModel.likes) {
      if (likeModel.uid == userProvider.userModel.email) {
        setState(() {
          liked = true;
        });
      }
    }
  }

  commentOnPost() async {
    if (commentController.text.isEmpty) {
      Toast.show("Please type comment!", context);
      return;
    }
    setState(() {
      postModel.comments.add(new CommentModel(
          userName: userProvider.userModel.name,
          uid: userProvider.userModel.email,
          userAvatar: userProvider.userModel.avatar,
          comment: commentController.text));
    });
    commentController.text = '';
    await Provider.of<PostProvider>(context, listen: false)
        .updatePost(postModel);
  }

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    checkMyLike();
    super.initState();
  }

  _PostDetailScreenState({this.postModel});
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: h * .1,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: Image.network(
                    "${postModel.userAvatar}",
                  ).image,
                ),
                contentPadding: EdgeInsets.all(0),
                title: Text(
                  "${postModel.userName}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Text(
                    "${getDatePhrase(postModel.tstamp)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 11,
                    ),
                  ),
                ),
                onTap: () {
                  if (postModel.uid ==
                      Provider.of<UserProvider>(context, listen: false)
                          .userModel
                          .email) {
                    // if mine post
                    widget.openProfile();
                  } else {
                    // other's post
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileDetailScreen(
                                id: postModel.uid,
                                openChatTab:
                                    (contextOfOtherScreen, UserModel usr) {
                                  Navigator.of(contextOfOtherScreen).pop();
                                  widget.openChat(usr);
                                })));
                  }
                },
              ),
            ),
            Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  postModel.description,
                  style: TextStyle(fontSize: 15),
                )),
            SizedBox(
              height: 8,
            ),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(2)),
              child: Image.network(
                "${postModel.postImg}",
                height: 170,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            Divider(),
            likesAndComments(
                postModel.likes.length, postModel.comments.length, liked),
            SizedBox(
              height: 10,
            ),
            Divider(),
            comments(),
            commentBox()
          ],
        ),
      ),
    );
  }

  Widget comments() {
    return Expanded(
        child: postModel.comments.length > 0
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: postModel.comments.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(top: 12, left: 8),
                    child: Row(
                      children: [
                        showProfilePic(postModel.comments[index].userAvatar),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              postModel.comments[index].userName,
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 2),
                                child: Text(postModel.comments[index].comment)),
                          ],
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              new DateFormat('hh:mm')
                                  .format(postModel.comments[index].timeStamp),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                            Text(
                              new DateFormat('yyyy-MM-dd')
                                  .format(postModel.comments[index].timeStamp),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 10),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 15,
                        )
                      ],
                    ),
                  );
                })
            : Center(
                child: Text("No comments yet."),
              ));
  }

  Widget showProfilePic(String av) {
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

  Widget commentBox() {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  commentOnPost();
                },
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: commentController,
                decoration: InputDecoration.collapsed(
                  hintText: ' Type your comment here...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  commentOnPost();
                },
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget likesAndComments(int nosLikes, int nosComments, bool liked) {
    return Row(
      children: [
        SizedBox(
          width: 15,
        ),
        GestureDetector(
          onTap: () async {
            UserModel usr =
                Provider.of<UserProvider>(context, listen: false).userModel;
            if (this.liked) {
              for (int i = 0; i < postModel.likes.length; i++) {
                if (postModel.likes[i].uid == usr.email) {
                  postModel.likes.removeAt(i);
                  print("Removed my like");
                }
              }
            } else {
              print("liking");
              postModel.likes.add(new LikeModel(
                  uid: usr.email,
                  userStatus: usr.status,
                  userAvatar: usr.avatar,
                  userName: usr.name));
            }
            checkMyLike();
            await Provider.of<PostProvider>(context, listen: false)
                .updatePost(postModel);
            setState(() {});
          },
          child: Image.asset(
            liked ? 'assets/images/liked.png' : 'assets/images/unliked.png',
            width: 30,
            height: 30,
          ),
        ),
        if (nosLikes > 0)
          SizedBox(
            width: 5,
          ),
        if (nosLikes > 0) Text("$nosLikes"),
        SizedBox(
          width: 15,
        ),
        Image.asset(
          'assets/images/comment.png',
          width: 30,
          height: 30,
        ),
        if (nosComments > 0)
          SizedBox(
            width: 5,
          ),
        if (nosComments > 0) Text("$nosComments")
      ],
    );
  }

  String getDatePhrase(DateTime dateTime) {
    DateTime dateTimeNow = DateTime.now();
    Duration diff = dateTimeNow.difference(dateTime);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} secs ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else if (diff.inDays < 2) {
      return 'Yesterday';
    } else {
      return "${new DateFormat('yyyy-MM-dd').format(dateTime)}";
    }
  }
}
