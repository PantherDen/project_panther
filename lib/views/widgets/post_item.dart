import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/post_model.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/post_provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/views/screens/posts/post_detail.dart';
import 'package:project/views/screens/profile/profile_detail.dart';

class PostItem extends StatefulWidget {
  PostModel postModel;
  Function openProfile;
  Function openChat;
  PostItem({this.postModel, this.openProfile, this.openChat});
  @override
  _PostItemState createState() => _PostItemState(postModel: postModel);
}

class _PostItemState extends State<PostItem> {
  PostModel postModel;
  bool liked = false;
  bool saved = false;

  _PostItemState({this.postModel});

  checkMyLike() {
    liked = false;
    for (LikeModel likeModel in postModel.likes) {
      if (likeModel.uid ==
          Provider.of<UserProvider>(context, listen: false).userModel.email) {
        setState(() {
          liked = true;
        });
      }
    }
  }

  @override
  void initState() {
    checkMyLike();
    checkSaving();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
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
            )
          ],
        ),
      ),
      onTap: () {},
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
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                          postModel: postModel,
                          openChat: widget.openChat,
                          openProfile: widget.openProfile,
                        )));
          },
          child: Image.asset(
            'assets/images/comment.png',
            width: 30,
            height: 30,
          ),
        ),
        if (nosComments > 0)
          SizedBox(
            width: 5,
          ),
        if (nosComments > 0) Text("$nosComments"),
        Spacer(),
        GestureDetector(
          onTap: () async {
            if (saved) {
              for (int i = 0; i < postModel.savedBy.length; i++) {
                if (postModel.savedBy[i] ==
                    Provider.of<UserProvider>(context, listen: false)
                        .userModel
                        .email) {
                  postModel.savedBy.removeAt(i);
                }
              }
            } else {
              postModel.savedBy.add(
                  Provider.of<UserProvider>(context, listen: false)
                      .userModel
                      .email);
            }
            checkSaving();
            await Provider.of<PostProvider>(context, listen: false)
                .updatePost(postModel);
            setState(() {});
          },
          child: Icon(
            saved ? Icons.save : Icons.save_outlined,
            size: 30,
            color: saved ? Colors.red : Colors.grey,
          ),
        ),
        SizedBox(
          width: 20,
        )
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

  void checkSaving() {
    saved = false;
    for (String str in postModel.savedBy) {
      if (str ==
          Provider.of<UserProvider>(context, listen: false).userModel.email) {
        setState(() {
          saved = true;
        });
      }
    }
  }
}
