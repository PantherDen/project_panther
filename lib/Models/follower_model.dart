class FollowerModel {
  String uid;
  String userName;
  String userAvatar;
  String userStatus;
  bool imFollowing = false;
  bool selected = false;

  FollowerModel({this.uid, this.userName, this.userAvatar, this.userStatus});

  FollowerModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    userName = json['userName'];
    userAvatar = json['userAvatar'];
    userStatus = json['userStatus'];
  }
  FollowerModel.fromUserObject(Map<String, dynamic> json) {
    uid = json['email'];
    userName = json['name'];
    userAvatar = json.containsKey('avatar') ? json['avatar'] : null;
    userStatus = json.containsKey('status') ? json['status'] : '';
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
