import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String pid, uid, userName, userAvatar, description, postImg;
  DateTime tstamp;
  List<LikeModel> likes = [];
  List<CommentModel> comments = [];
  List<String> savedBy = [];

  PostModel(
      {this.userName,
      this.userAvatar,
      this.description,
      this.uid,
      this.postImg}) {
    pid = (DateTime.now().millisecondsSinceEpoch ~/ 100000).toString();
    likes = [];
    comments = [];
    tstamp = DateTime.now();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pid'] = this.pid;
    data['uid'] = this.uid;
    data['userName'] = this.userName;
    data['userAvatar'] = this.userAvatar;
    data['description'] = this.description;
    data['postImg'] = this.postImg;
    data['timeStamp'] = this.tstamp;
    if (likes != null) {
      data["likes"] = likes.map((v) => v.toJson()).toList();
    }
    if (comments != null) {
      data["comments"] = comments.map((v) => v.toJson()).toList();
    }
    data['savedBy'] = savedBy;
    return data;
  }

  PostModel.fromJson(dynamic json) {
    pid = json["pid"];
    uid = json["uid"];
    userName = json["userName"];
    userAvatar = json["userAvatar"];
    description = json["description"];
    postImg = json["postImg"];
    tstamp = (json["timeStamp"] as Timestamp).toDate();
    if (json['likes'] != null) {
      likes = <LikeModel>[];
      json['likes'].forEach((v) {
        likes.add(new LikeModel.fromJson(v));
      });
    }
    if (json['comments'] != null) {
      comments = <CommentModel>[];
      json['comments'].forEach((v) {
        comments.add(new CommentModel.fromJson(v));
      });
    }
    savedBy = json['savedBy'] != null ? json['savedBy'].cast<String>() : [];
  }
}

class LikeModel {
  String uid;
  String userName;
  String userAvatar;
  String userStatus;

  LikeModel({this.uid, this.userName, this.userAvatar, this.userStatus});

  LikeModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    userName = json['userName'];
    userAvatar = json['userAvatar'];
    userStatus = json['userStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['userName'] = this.userName;
    data['userAvatar'] = this.userAvatar;
    data['userStatus'] = this.userStatus;
    return data;
  }
}

class CommentModel {
  String uid;
  String userName;
  String userAvatar;
  String comment;
  DateTime timeStamp;
  CommentModel({this.uid, this.userName, this.userAvatar, this.comment}) {
    timeStamp = DateTime.now();
  }

  CommentModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    userName = json['userName'];
    userAvatar = json['userAvatar'];
    timeStamp = (json['timeStamp'] as Timestamp).toDate();
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['userName'] = this.userName;
    data['userAvatar'] = this.userAvatar;
    data['timeStamp'] = this.timeStamp;
    data['comment'] = this.comment;
    return data;
  }
}
