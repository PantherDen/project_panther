import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Providers/post_provider.dart';
import 'package:project/Providers/user_provider.dart';
import 'dart:io';

import 'package:toast/toast.dart';

class CreatePostsScreen extends StatefulWidget {
  const CreatePostsScreen({Key key}) : super(key: key);

  @override
  _CreatePostsScreenState createState() => _CreatePostsScreenState();
}

class _CreatePostsScreenState extends State<CreatePostsScreen> {
  double w, h;
  UserModel usr;
  TextEditingController desc = new TextEditingController();
  File pickedImg;
  bool creating = false;

  createPost() async {
    setState(() {
      creating = true;
    });
    FocusScope.of(context).unfocus();
    PostProvider postProvider =
        Provider.of<PostProvider>(context, listen: false);
    bool create = await postProvider.createPost(
        Provider.of<UserProvider>(context, listen: false).userModel,
        desc.text,
        pickedImg);
    setState(() {
      creating = false;
    });
    if (create) {
      Toast.show("Posted!", context);
      // navigate back
      Navigator.of(context).pop();
    } else {
      Toast.show("Error creating post!", context);
    }
  }

  @override
  void initState() {
    usr = Provider.of<UserProvider>(context, listen: false).userModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: h * .06,
            ),
            appBar(),
            SizedBox(
              height: h * .06,
            ),
            userHeading(),
            SizedBox(
              height: 15,
            ),
            textField(desc, 'Describe your post', 4),
            SizedBox(
              height: 15,
            ),
            if (pickedImg == null) chooseImage(),
            if (pickedImg != null) showImage()
          ],
        ),
      ),
    );
  }

  Widget userHeading() {
    return Container(
      margin: EdgeInsets.only(left: 15),
      child: Row(
        children: [
          showProfilePic(usr.avatar),
          SizedBox(
            width: 15,
          ),
          Text(
            usr.name,
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget appBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "Create Post",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              if (pickedImg != null && desc.text.length > 0 && (!creating)) {
                createPost();
              }
            },
            child: Text(
              "Post",
              style: TextStyle(
                  color: pickedImg != null && desc.text.length > 0
                      ? Color(0xff3E236E)
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
    );
  }

  Widget showImage() {
    return Container(
      width: w * .9,
      height: h * .4,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: Colors.black),
      child: Stack(
        children: [
          Center(child: Image.file(pickedImg)),
          if (!creating)
            Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      pickedImg = null;
                    });
                  },
                  child: Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: 30,
                  ),
                ))
        ],
      ),
    );
  }

  Widget textField(var controller, String hint, int numLines) {
    return Container(
      width: MediaQuery.of(context).size.width * .9,
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: border(), // set border width
        borderRadius: BorderRadius.all(
            Radius.circular(10.0)), // set rounded corner radius
      ),
      child: TextField(
        enabled: !creating,
        controller: controller,
        keyboardType: TextInputType.multiline,
        minLines: numLines,
        maxLines: numLines,
        onChanged: (val) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Border border() {
    return Border.all(
        color: Color(0xff3E236E).withOpacity(.5), // set border color
        width: 1.5);
  }

  Widget chooseImage() {
    return GestureDetector(
      onTap: () {
        _showPicker(context);
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
          "Choose Image",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
      ),
    );
  }

  Widget showProfilePic(String av) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: h * .045,
      backgroundImage: Image.asset('assets/images/loading.gif').image,
      child: CircleAvatar(
        radius: h * .045,
        backgroundColor: Colors.transparent,
        backgroundImage: av != null && av.isNotEmpty
            ? NetworkImage(av)
            : Image.asset('assets/images/no_profile.png').image,
      ),
    );
  }

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
