import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/Providers/post_provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/views/widgets/post_item.dart';
import 'package:project/util/data.dart';

class SavedPostScreen extends StatefulWidget {
  Function openProfile;
  Function openChatTab;
  SavedPostScreen({this.openProfile, this.openChatTab});
  @override
  _SavedPostState createState() => _SavedPostState();
}

class _SavedPostState extends State<SavedPostScreen> {
  PostProvider postProvider;
  bool loading = true;

  loadFeed() async {
    postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.getAllPosts();
    await postProvider.getMySavedPosts(
        Provider.of<UserProvider>(context, listen: false).userModel.email);
    setState(() {
      loading = false;
    });
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
        title: Text("Saved Posts"),
        centerTitle: true,
      ),
      body: !loading
          ? ps.savedPosts.length > 0
              ? ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: ps.savedPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PostItem(
                      postModel: ps.savedPosts[index],
                      openProfile: widget.openProfile,
                      openChat: widget.openChatTab,
                    );
                  },
                )
              : Center(
                  child: Text("No post saved yet!"),
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
}
