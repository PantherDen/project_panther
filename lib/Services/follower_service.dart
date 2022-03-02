import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/Models/follower_model.dart';
import 'package:project/Models/user_model.dart';

class FollowerService {
  // get all user base
  Future<List<FollowerModel>> getAllUserBase() async {
    List<FollowerModel> followers = [];
    List<String> myFollowersList = [];
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String currentUser = sharedPreferences.getString('userEmail');
      // let get current users followers
      var snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: currentUser)
          .get();
      Map data = snapshot.docs[0].data();
      if (data.containsKey('following')) {
        List followersList = data['following'] as List;
        for (var d in followersList) {
          myFollowersList.add(d['uid']);
        }
      }
      // lets get all users and mark them
      snapshot = await FirebaseFirestore.instance.collection('Users').get();
      if (snapshot.docs.length > 0) {
        for (DocumentSnapshot ds in snapshot.docs) {
          FollowerModel fl = FollowerModel.fromUserObject(ds.data());
          if (fl.uid == currentUser) continue;
          if (myFollowersList.contains(fl.uid)) {
            fl.imFollowing = true;
          }
          followers.add(fl);
        }
      }
      return followers;
    } catch (e) {
      print("Error getting followers.... $e");
      return followers;
    }
  }

  // follow a user
  Future<bool> followUser(FollowerModel flw, UserModel usr) async {
    try {
      // add it to my following list ------------------
      var snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: usr.email)
          .get();
      DocumentSnapshot ds = snapshot.docs[0];
      Map data = ds.data();
      // get previous following list
      List<FollowerModel> following = <FollowerModel>[];
      if (data['following'] != null) {
        data['following'].forEach((v) {
          following.add(new FollowerModel.fromJson(v));
        });
      }
      // add new following
      following.add(flw);
      data['following'] = following.map((v) => v.toJson()).toList();
      // update my following list
      ds.reference.update(data);
      // add me to other's follower list -----------------
      snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: flw.uid)
          .get();
      ds = snapshot.docs[0];
      data = ds.data();
      // get previous followers list
      List<FollowerModel> followers = <FollowerModel>[];
      if (data['followers'] != null) {
        data['followers'].forEach((v) {
          followers.add(new FollowerModel.fromJson(v));
        });
      }
      // add new following
      followers.add(new FollowerModel(
          uid: usr.email,
          userAvatar: usr.avatar,
          userName: usr.name,
          userStatus: usr.status));
      data['followers'] = followers.map((v) => v.toJson()).toList();
      // update my following list
      ds.reference.update(data);
      return true;
    } catch (e) {
      print("Error un-following user....$e");
      return false;
    }
  }

  // unfollow a user
  Future<bool> unfollowUser(FollowerModel flw, UserModel usr) async {
    try {
      print('unfollowing.....');
      // add it to my following list ------------------
      var snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: usr.email)
          .get();
      DocumentSnapshot ds = snapshot.docs[0];
      Map data = ds.data();
      // get previous following list
      List<FollowerModel> following = <FollowerModel>[];
      if (data['following'] != null) {
        data['following'].forEach((v) {
          following.add(new FollowerModel.fromJson(v));
        });
      }
      // remove new following
      if (following.length > 0) {
        for (int i = 0; i < following.length; i++) {
          if (following[i].uid == flw.uid) {
            following.removeAt(i);
          }
        }
      }
      data['following'] = following.map((v) => v.toJson()).toList();
      // update my following list
      ds.reference.update(data);
      // add me to other's follower list -----------------
      var snapshot1 = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: flw.uid)
          .get();
      DocumentSnapshot ds1 = snapshot1.docs[0];
      Map data1 = ds1.data();
      // get previous followers list
      List<FollowerModel> followers = <FollowerModel>[];
      if (data1['followers'] != null) {
        data1['followers'].forEach((v) {
          followers.add(new FollowerModel.fromJson(v));
        });
      }
      // add new following
      if (followers.length > 0)
        for (int i = 0; i < followers.length; i++) {
          if (followers[i].uid == usr.email) {
            followers.removeAt(i);
          }
        }
      data1['followers'] = followers.map((v) => v.toJson()).toList();
      // update my following list
      ds1.reference.update(data1);
      return true;
    } catch (e) {
      print("Error un-following user....$e");
      return false;
    }
  }

  // get current user
  Future<String> getUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String currentUser = sharedPreferences.getString('userEmail');
    return currentUser;
  }
}
