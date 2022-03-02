import 'package:flutter/cupertino.dart';
import 'package:project/Models/follower_model.dart';
import 'package:project/Models/group_model.dart';
import 'package:project/Services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  GroupService gs = new GroupService();

  // create group
  Future<bool> createGroup(GroupModel gp) async {
    return await gs.createGroup(gp);
  }

  // load groups
  Future<List<GroupModel>> loadGroups(String uid) async {
    return await gs.loadGroups(uid);
  }

  // update group
  Future<bool> updateGroup() async {}
}
