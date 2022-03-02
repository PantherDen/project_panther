import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/dialogue_model.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/user_provider.dart';
import 'Chat.dart';
import 'ColorConstants.dart';

class DialogueScreen extends StatefulWidget {
  @override
  State createState() => DialogueScreenState();
}

class DialogueScreenState extends State<DialogueScreen>
    with WidgetsBindingObserver {
  bool loading = true;
  String currentUserId = '';
  bool isLoading = false;
  List<DialogueModel> dialogues = [];
  UserModel usr;
  double w, h;

  void initUser() async {
    await fetchDialogues();
    setState(() {
      loading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getDialogs();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> fetchDialogues() async {
    UserModel userData =
        Provider.of<UserProvider>(context, listen: false).userModel;
    usr = userData;
    currentUserId = userData.id;
    await getDialogs();
  }

  Future<void> getDialogs() async {
    List<DialogueModel> dialogues = [];
    String currentUserId = usr.id;
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Dialogues').get();
    if (snapshot.docs.length > 0) {
      List<DialogueModel> d = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        if (snapshot.docs[i]['to'] == currentUserId ||
            snapshot.docs[i]['from'] == currentUserId) {
          d.add(DialogueModel.fromJson(snapshot.docs[i].data()));
        }
      }
      d.sort((a, b) => a.dt.compareTo(b.dt));
      d = d.reversed.toList();
      dialogues = d;
    }
    setState(() {
      this.dialogues = dialogues;
    });
    print("dl = ${this.dialogues.length}");
  }

  void showNotification(message) async {}

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: !loading
          ? dialogues.length > 0
              ? ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) =>
                      buildItem(context, dialogues[index]),
                  itemCount: dialogues.length,
                )
              : Center(
                  child: Text("No chat history found"),
                )
          : Center(
              child: progress(),
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

  Widget buildItem(BuildContext context, DialogueModel data) {
    final f = new DateFormat('yyyy-MM-dd hh:mm');
    String avatar = data.to == currentUserId ? data.myAvatar : data.peerAvatar;
    String name = data.to == currentUserId ? data.myName : data.peerName;
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        peerId: data.to == currentUserId ? data.from : data.to,
                        peerAvatar: avatar,
                        peerName: name,
                      ))).then((value) {
            fetchDialogues();
          });
        },
        child: Column(children: [
          ChatWidget(
            name: name,
            image: avatar,
            lastmsg: data.message,
            dt: data.dt,
          ),
          Divider(
            indent: 80,
            endIndent: 30,
          ),
        ]));
  }
}

class Choice {
  Choice({this.title, this.icon});

  String title;
  IconData icon;
}

class ChatWidget extends StatelessWidget {
  var name, image, lastmsg, dt;
  ChatWidget({this.name, this.image, this.lastmsg, this.dt});
  double h, w;

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(right: 18, top: 5, bottom: 5),
      child: Row(
        children: [
          showProfilePicSmall(image),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: Text(
                  lastmsg,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                ),
              )
            ],
          ),
          Spacer(),
          Align(
            alignment: Alignment.topCenter,
            child: Text('${DateFormat('yyyy-MM-dd hh:mm').format(dt)}',
                style: TextStyle(
                    color: ColorConstants.primaryColor, fontSize: 11)),
          )
        ],
      ),
    );
  }

  Widget showProfilePicSmall(String av) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: h * .04,
      backgroundImage: Image.asset('assets/images/loading.gif').image,
      child: CircleAvatar(
        radius: h * .035,
        backgroundColor: Colors.transparent,
        backgroundImage: av != null && av.isNotEmpty
            ? NetworkImage(av)
            : Image.asset('assets/images/no_profile.png').image,
      ),
    );
  }
}
