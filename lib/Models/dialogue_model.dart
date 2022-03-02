import 'package:cloud_firestore/cloud_firestore.dart';

class DialogueModel {
  DateTime dt;
  String from;
  String message;
  String myAvatar;
  String myName;
  String peerAvatar;
  String peerName;
  String to;

  DialogueModel(
      {this.dt,
      this.from,
      this.message,
      this.myAvatar,
      this.myName,
      this.peerAvatar,
      this.peerName,
      this.to});

  DialogueModel.fromJson(Map<String, dynamic> json) {
    dt = (json['dt'] as Timestamp).toDate();
    from = json['from'];
    message = json['message'];
    myAvatar = json['myAvatar'];
    myName = json['myName'];
    peerAvatar = json['peerAvatar'];
    peerName = json['peerName'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dt'] = this.dt;
    data['from'] = this.from;
    data['message'] = this.message;
    data['myAvatar'] = this.myAvatar;
    data['myName'] = this.myName;
    data['peerAvatar'] = this.peerAvatar;
    data['peerName'] = this.peerName;
    data['to'] = this.to;
    return data;
  }
}
