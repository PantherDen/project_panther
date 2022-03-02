import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:project/Models/post_model.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Services/post_service.dart';

class PostProvider extends ChangeNotifier {
  PostService ps = new PostService();
  List<PostModel> allPosts = [];
  List<PostModel> savedPosts = [];
  List<PostModel> myPosts = [];

  // create
  Future<bool> createPost(UserModel usr, String desc, File img) async {
    bool create = await ps.createPost(usr, desc, img);
    await getAllMyPosts(usr.email);
    getAllPosts();
    return create;
  }

  // get all posts
  Future<void> getAllPosts() async {
    allPosts = await ps.getAllPosts();
    allPosts.sort((a, b) => a.tstamp.compareTo(b.tstamp));
    notifyListeners();
  }

  // get my saved posts
  Future<void> getMySavedPosts(String myId) async {
    savedPosts = [];
    for (PostModel postModel in allPosts) {
      if (postModel.savedBy.contains(myId)) {
        savedPosts.add(postModel);
      }
    }
    notifyListeners();
  }

  // get all my posts
  Future<void> getAllMyPosts(String uid) async {
    myPosts = await ps.getMyPosts(uid);
    notifyListeners();
  }

  // get all id posts
  Future<List<PostModel>> getAllIdPosts(String uid) async {
    return await ps.getMyPosts(uid);
  }

  // update post
  Future<bool> updatePost(PostModel postModel) async {
    return await ps.updatePost(postModel);
  }
}
