import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/follower_model.dart';
import 'package:project/Models/group_model.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/follower_provider.dart';
import 'package:project/Providers/group_provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:project/Services/user_service.dart';
import 'package:toast/toast.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key key}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController name = new TextEditingController();
  TextEditingController status = new TextEditingController();
  FollowerProvider followerProvider;
  GroupProvider groupProvider;
  UserProvider userProvider;
  double w, h;
  File pickedImg = null;
  bool loading = true;
  bool progressLoading = false;
  List<FollowerModel> allUsers = [];

  getAllUsers() async {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    followerProvider = Provider.of<FollowerProvider>(context, listen: false);
    groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await followerProvider.getAllUserBase();
    setState(() {
      allUsers = followerProvider.allUsers;
      loading = false;
    });
  }

  createGroup() async {
    // validation
    if (pickedImg == null) {
      Toast.show("Please select group image!", context);
      return;
    }
    if (name.text.isEmpty) {
      Toast.show("Group Name is required!", context);
      return;
    }
    if (status.text.isEmpty) {
      Toast.show("About group is required!", context);
      return;
    }
    if (!isMemberAdded()) {
      Toast.show("Please add at-least 1 group member !", context);
      return;
    }
    // creation
    setState(() {
      progressLoading = true;
    });
    UserService us = new UserService();
    String avatar =
        await us.uploadFile(pickedImg, userProvider.userModel.email);
    GroupModel gp = new GroupModel(
        creatorId: userProvider.userModel.email,
        groupAvatar: avatar,
        groupName: name.text,
        about: status.text,
        members: buildMembers());
    bool create = await groupProvider.createGroup(gp);
    if (create) {
      Toast.show('Group created!', context);
      Navigator.of(context).pop();
    } else {
      Toast.show('Failed to create group!', context);
    }
    setState(() {
      progressLoading = false;
    });
  }

  @override
  void initState() {
    getAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: w,
          height: h,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: h * .1),
              Stack(
                children: [
                  pickedImg != null
                      ? CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: h * .1,
                          backgroundImage: Image.file(pickedImg).image,
                        )
                      : showProfilePic(null),
                  Positioned(
                      bottom: 0, right: 4, child: buildEditIcon(Colors.black))
                ],
              ),
              SizedBox(
                height: h * .04,
              ),
              textField(name, 'Group Name', 1),
              SizedBox(
                height: 10,
              ),
              textField(status, 'About Group', 1),
              SizedBox(
                height: 15,
              ),
              Container(
                width: w * .8,
                alignment: Alignment.topLeft,
                child: Text(
                  "Choose members",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              listAllUser(),
              Spacer(),
              !progressLoading
                  ? GestureDetector(
                      onTap: () {
                        createGroup();
                      },
                      child: Container(
                        height: 52,
                        width: w * 0.8,
                        decoration: BoxDecoration(
                          color: Color(0xff3E236E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: Text(
                          "Create",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                    )
                  : progress(),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
  }

  Widget listAllUser() {
    return !loading
        ? Container(
            width: w * .8,
            margin: EdgeInsets.only(top: 15),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                FollowerModel flw = allUsers[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      showProfilePicSmall(flw.userAvatar),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flw.userName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            flw.imFollowing ? "Following" : "Not Following",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontStyle: FontStyle.italic),
                          )
                        ],
                      ),
                      Spacer(),
                      Checkbox(
                        value: flw.selected,
                        onChanged: (bool value) {
                          toggleSelection(flw.uid);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        : Container(
            margin: EdgeInsets.only(top: 20),
            child: progress(),
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

  Widget showProfilePicSmall(String av) {
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

  Border border() {
    return Border.all(
        color: Color(0xff3E236E).withOpacity(.5), // set border color
        width: 1.5);
  }

  Widget textField(var controller, String hint, int numLines) {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width * .8,
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: border(), // set border width
        borderRadius: BorderRadius.all(
            Radius.circular(10.0)), // set rounded corner radius
      ),
      child: TextField(
        controller: controller,
        maxLines: numLines,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => GestureDetector(
        onTap: () {
          _showPicker(context);
        },
        child: buildCircle(
          color: Colors.white,
          all: 3,
          child: buildCircle(
            color: color,
            all: 8,
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );

  Widget buildCircle({
    Widget child,
    double all,
    Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
  _imgFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    var image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      pickedImg = File(image.path);
    });
  }

  _imgFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    XFile image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      pickedImg = File(image.path);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void toggleSelection(String uid) {
    for (int i = 0; i < allUsers.length; i++) {
      if (allUsers[i].uid == uid) {
        setState(() {
          allUsers[i].selected = !allUsers[i].selected;
        });
      }
    }
  }

  bool isMemberAdded() {
    bool added = false;
    List<Members> members = [];
    for (int i = 0; i < allUsers.length; i++) {
      if (allUsers[i].selected) {
        added = true;
        break;
      }
    }
    return added;
  }

  List<Members> buildMembers() {
    List<Members> members = [];
    for (int i = 0; i < allUsers.length; i++) {
      if (allUsers[i].selected) {
        FollowerModel flw = allUsers[i];
        members.add(new Members(
            email: flw.uid,
            name: flw.userName,
            avatar: flw.userAvatar,
            status: flw.userStatus));
      }
    }
    return members;
  }
}
