import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController name = new TextEditingController();
  TextEditingController status = new TextEditingController();
  UserModel usr;
  double w, h;
  File pickedImg = null;
  bool loading = false;

  update() async {
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
    });
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    bool upload = await userProvider.updateProfile(
        name.text, status.text, pickedImg, context);
    await userProvider.getCurrentUser();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    usr = Provider.of<UserProvider>(context, listen: false).userModel;
    name = new TextEditingController(text: usr.name);
    status = new TextEditingController(text: usr.status);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: h * .15),
              Stack(
                children: [
                  pickedImg != null
                      ? CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: h * .1,
                          backgroundImage: Image.file(pickedImg).image,
                        )
                      : showProfilePic(usr.avatar),
                  Positioned(
                      bottom: 0, right: 4, child: buildEditIcon(Colors.black))
                ],
              ),
              SizedBox(
                height: h * .08,
              ),
              textField(name, 'Name', 1),
              SizedBox(
                height: 10,
              ),
              textField(status, 'Status', 1),
              SizedBox(
                height: 20,
              ),
              !loading
                  ? GestureDetector(
                      onTap: () {
                        update();
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
                          "UPDATE",
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
        ),
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
          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
}
