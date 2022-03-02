import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Models/group_model.dart';

class GroupService {
  // create group
  Future<bool> createGroup(GroupModel gp) async {
    try {
      await FirebaseFirestore.instance.collection('Groups').add(gp.toJson());
      return true;
    } catch (e) {
      print("Error creating group....$e");
      return false;
    }
  }

  // update group
  Future<bool> updateGroup(GroupModel gp) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .where('gpid', isEqualTo: gp.gpid)
          .get();
      DocumentSnapshot ds = snapshot.docs[0];
      ds.reference.update(gp.toJson());
      return true;
    } catch (e) {
      print("Error updating group....$e");
      return false;
    }
  }

  // load my groups
  Future<List<GroupModel>> loadGroups(String uid) async {
    List<GroupModel> groups = [];
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('Groups').get();
      if (snapshot.docs.length > 0) {
        for (DocumentSnapshot ds in snapshot.docs) {
          GroupModel groupModel = GroupModel.fromJson(ds.data());
          if (groupModel.creatorId == uid ||
              containId(groupModel.members, uid)) {
            // im creator or member
            groups.add(groupModel);
          }
        }
      }
      return groups;
    } catch (e) {
      print("Error getting groups... $e");
      return groups;
    }
  }

  // members contain my id
  bool containId(List<Members> members, String id) {
    bool exists = false;
    for (Members member in members) {
      if (member.email == id) {
        exists = true;
        break;
      }
    }
    return exists;
  }
}
