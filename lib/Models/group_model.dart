class GroupModel {
  String gpid;
  String groupName;
  String about;
  String groupAvatar;
  String creatorId;
  List<Members> members;

  GroupModel(
      {this.groupName,
      this.about,
      this.groupAvatar,
      this.creatorId,
      this.members}) {
    gpid = (DateTime.now().microsecondsSinceEpoch ~/ 10000).toString();
  }

  GroupModel.fromJson(Map<String, dynamic> json) {
    gpid = json['gpid'];
    groupName = json['groupName'];
    about = json['about'];
    groupAvatar = json['groupAvatar'];
    creatorId = json['creatorId'];
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members.add(new Members.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gpid'] = this.gpid;
    data['about'] = this.about;
    data['groupName'] = this.groupName;
    data['groupAvatar'] = this.groupAvatar;
    data['creatorId'] = this.creatorId;
    if (this.members != null) {
      data['members'] = this.members.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Members {
  String email;
  String name;
  String avatar;
  String status;

  Members({this.email, this.name, this.avatar, this.status});

  Members.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    avatar = json['avatar'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['status'] = this.status;
    return data;
  }
}
