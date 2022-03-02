import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/Models/user_model.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:path/path.dart';

class UserService {
  // register user
  Future<UserModel> registerUser(
      String name, String email, String password, BuildContext context) async {
    try {
      // user exist
      bool userExist = await doesUserExist(email);
      if (userExist) {
        Toast.show(
            'You are already registered with this email, Navigate to login!',
            context,
            duration: Toast.LENGTH_LONG);
        return null;
      } else {
        // register in auth
        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            print('The password provided is too weak.');
          } else if (e.code == 'email-already-in-use') {
            print('The account already exists for that email.');
          }
          return null;
        } catch (e) {
          print(e);
          return null;
        }
        // register user in fire-store
        String id = FirebaseAuth.instance.currentUser.uid;
        FirebaseFirestore.instance
            .collection('Users')
            .add({'name': name, 'email': email, 'id': id});

        // create user object
        UserModel userModel = UserModel();
        userModel.name = name;
        userModel.email = email;
        userModel.id = id;
        userModel.avatar = null;
        userModel.status = null;
        //save to prefs
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('userEmail', email);
        return userModel;
      }
    } catch (e) {
      print("Error occured $e");
      Toast.show('Failed to create your account, Try again later!', context,
          duration: Toast.LENGTH_LONG);
      return null;
    }
  }

  // login user
  Future<UserModel> loginUser(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // get user
      var snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      if (snapshot.docs.length > 0) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('userEmail', email);
        Map data = snapshot.docs[0].data();
        UserModel userModel = UserModel();
        userModel.name = data['name'];
        userModel.email = data['email'];
        userModel.id = data['id'];
        userModel.avatar = data.containsKey('avatar') ? data['avatar'] : null;
        userModel.status = data.containsKey('status') ? data['status'] : null;
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Toast.show('No user found for that email.', context);
      } else if (e.code == 'wrong-password') {
        Toast.show('Wrong password provided for that user.', context);
      }
      return null;
    } catch (e) {
      Toast.show('Error logging in', context);
      return null;
    }
  }

  // send password reset email
  Future<bool> sendPasswordResetEmail(
      String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      Toast.show("Error resetting your password...$e", context,
          duration: Toast.LENGTH_LONG);
      return false;
    }
  }

  // check account exist
  Future<bool> doesUserExist(String email) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      return snapshot.docs.length > 0;
    } catch (e) {
      print("User checking failed...$e");
      return false;
    }
  }

  // update user profile
  Future<bool> updateUserProfile(String name, String status, File img,
      BuildContext context, String oldAvatar) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String email = sharedPreferences.getString('userEmail');
      String avatar = oldAvatar;
      if (img != null) {
        String dwnUrl = await uploadFile(img, email);
        avatar = dwnUrl != null ? dwnUrl : avatar;
      }
      // write to fire-store
      var snapshots = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      DocumentSnapshot ds = snapshots.docs[0];
      Map data = ds.data();
      data['name'] = name;
      data['status'] = status;
      data['avatar'] = avatar;
      ds.reference.update(data);
      Toast.show("Profile updated!", context);
      return true;
    } catch (e) {
      Toast.show("Failed to update your profile...$e", context);
      return false;
    }
  }

  Future<String> uploadFile(File file, String userEmail) async {
    try {
      FirebaseStorage storage = await FirebaseStorage.instance;
      Reference reference = await storage.ref().child(
          "Avatars/${basename(file.path)}${DateTime.now().millisecondsSinceEpoch}");
      // save to
      TaskSnapshot taskSnapshot = await reference.putFile(file);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading file... $e");
      return null;
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: sharedPreferences.getString('userEmail'))
          .get();
      if (snapshot.docs.length > 0) {
        Map data = snapshot.docs[0].data();
        UserModel userModel = UserModel.fromJson(data);
        return userModel;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting current user....$e");
      return null;
    }
  }

  Future<UserModel> getCurrentUserById(String id) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: id)
          .get();
      if (snapshot.docs.length > 0) {
        Map data = snapshot.docs[0].data();
        UserModel userModel = UserModel.fromJson(data);
        return userModel;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting $id user....$e");
      return null;
    }
  }
}
