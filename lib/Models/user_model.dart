import 'package:project/Models/follower_model.dart';

class UserModel {
  String name, email, avatar, status;
  List<FollowerModel> followers = [];
  List<FollowerModel> following = [];
  String id;
  UserModel();
  UserModel.fromJson(dynamic json) {
    name = json['name'];
    email = json['email'];
    id = json['id'];
    avatar = json.containsKey('avatar') ? json['avatar'] : null;
    status = json.containsKey('status') ? json['status'] : null;
    following = <FollowerModel>[];
    if (json['following'] != null) {
      json['following'].forEach((v) {
        following.add(new FollowerModel.fromJson(v));
      });
    }
    followers = <FollowerModel>[];
    if (json['followers'] != null) {
      json['followers'].forEach((v) {
        followers.add(new FollowerModel.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['id'] = this.id;
    data['avatar'] = this.avatar;
    data['status'] = this.status;
    if (following != null) {
      data["following"] = following.map((v) => v.toJson()).toList();
    }
    if (followers != null) {
      data["followers"] = followers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
