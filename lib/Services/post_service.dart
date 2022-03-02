import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project/Models/post_model.dart';
import 'package:project/Models/user_model.dart';
import 'package:path/path.dart';

class PostService {
  // create
  Future<bool> createPost(UserModel usr, String desc, File img) async {
    try {
      String uploadUrl = await uploadFile(img);
      PostModel postModel = new PostModel(
          userName: usr.name,
          userAvatar: usr.avatar,
          description: desc,
          uid: usr.email,
          postImg: uploadUrl);
      await FirebaseFirestore.instance
          .collection('Posts')
          .add(postModel.toJson());
      return true;
    } catch (e) {
      print("Error creating post....$e");
      return false;
    }
  }

  // get all posts
  Future<List<PostModel>> getAllPosts() async {
    List<PostModel> posts = [];
    try {
      var snapshots =
          await FirebaseFirestore.instance.collection('Posts').get();
      if (snapshots.docs.length > 0) {
        for (DocumentSnapshot ds in snapshots.docs) {
          posts.add(PostModel.fromJson(ds.data()));
        }
      }
      return posts;
    } catch (e) {
      print("Error getting posts....$e");
      return posts;
    }
  }

  // get my posts only
  Future<List<PostModel>> getMyPosts(String uid) async {
    print("getting posts for $uid");
    List<PostModel> posts = [];
    try {
      var snapshots = await FirebaseFirestore.instance
          .collection('Posts')
          .where('uid', isEqualTo: uid)
          .get();
      if (snapshots.docs.length > 0) {
        for (DocumentSnapshot ds in snapshots.docs) {
          posts.add(PostModel.fromJson(ds.data()));
        }
      }
      return posts;
    } catch (e) {
      print("Error getting posts....$e");
      return posts;
    }
  }

  Future<String> uploadFile(File file) async {
    try {
      FirebaseStorage storage = await FirebaseStorage.instance;
      Reference reference = await storage.ref().child(
          "Posts/${basename(file.path)}${DateTime.now().millisecondsSinceEpoch}");
      // save to
      TaskSnapshot taskSnapshot = await reference.putFile(file);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading file... $e");
      return null;
    }
  }

  // update post
  Future<bool> updatePost(PostModel postModel) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .where('pid', isEqualTo: postModel.pid)
          .get();
      snapshot.docs[0].reference.update(postModel.toJson());
      return true;
    } catch (e) {
      print("Updating post fails....$e");
      return false;
    }
  }
}
