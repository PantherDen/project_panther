import 'package:flutter/material.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/group_model.dart';
import 'package:project/Providers/group_provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/views/screens/chat/group_chat/group_chat.dart';

class AllGroups extends StatefulWidget {
  _AllGroupsState w;
  refresh() {
    w.loadGroups();
  }

  @override
  _AllGroupsState createState() {
    w = _AllGroupsState();
    return w;
  }
}

class _AllGroupsState extends State<AllGroups> {
  GroupProvider groupProvider;
  UserProvider userProvider;
  List<GroupModel> groups = [];
  double h, w;
  bool loading = true;

  loadGroups() async {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    groupProvider = Provider.of<GroupProvider>(context, listen: false);
    var groups = await groupProvider.loadGroups(userProvider.userModel.email);
    print("length = ${groups.length}");
    setState(() {
      this.groups = groups;
      loading = false;
    });
  }

  @override
  void initState() {
    loadGroups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;
    w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: !loading
          ? ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return itemView(groups[index]);
              },
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

  Widget itemView(GroupModel groupModel) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupChatScreen(
                      gp: groupModel,
                    )));
      },
      child: Column(children: [
        Container(
          width: w,
          margin: EdgeInsets.only(top: 10, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  showProfilePicSmall(groupModel.groupAvatar),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupModel.groupName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        groupModel.about,
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          width: w,
          height: 1,
          color: Colors.grey[200],
        )
      ]),
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
