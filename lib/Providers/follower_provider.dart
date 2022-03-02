import 'package:flutter/cupertino.dart';
import 'package:project/Models/follower_model.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Services/follower_service.dart';

class FollowerProvider extends ChangeNotifier {
  List<FollowerModel> allUsers = [];
  FollowerService fs = new FollowerService();

  // get all users
  Future<List<FollowerModel>> getAllUserBase() async {
    allUsers = await fs.getAllUserBase();
    print("all users ${allUsers.length}");
    notifyListeners();
  }

  // follow a user
  Future<bool> followUser(FollowerModel flw, UserModel usr) async {
    bool follow = await fs.followUser(flw, usr);
    if (follow) {
      for (int i = 0; i < allUsers.length; i++) {
        if (allUsers[i].uid == flw.uid) {
          allUsers[i].imFollowing = true;
        }
      }
    }
    notifyListeners();
    return follow;
  }

  // unfollow a user
  Future<bool> unfollowUser(FollowerModel flw, UserModel usr) async {
    bool unfollow = await fs.unfollowUser(flw, usr);
    if (unfollow) {
      for (int i = 0; i < allUsers.length; i++) {
        if (allUsers[i].uid == flw.uid) {
          allUsers[i].imFollowing = false;
        }
      }
    }
    notifyListeners();
    return unfollow;
  }
}
