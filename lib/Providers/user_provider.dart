import 'package:flutter/material.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Services/user_service.dart';
import 'dart:io';

class UserProvider extends ChangeNotifier {
  UserModel userModel = null;
  UserService us = new UserService();

  Future<bool> registerUser(
      String email, String password, String name, BuildContext context) async {
    userModel = await us.registerUser(name, email, password, context);
    return userModel != null;
  }

  Future<bool> loginUser(
      String email, String password, BuildContext context) async {
    userModel = await us.loginUser(email, password, context);
    return userModel != null;
  }

  Future<bool> sendPasswordResetEmail(
      String email, BuildContext context) async {
    return await us.sendPasswordResetEmail(email, context);
  }

  Future<bool> updateProfile(
      String name, String status, File img, BuildContext context) async {
    return await us.updateUserProfile(name, status, img, context,
        userModel.avatar != null ? userModel.avatar : '');
  }

  Future<void> getCurrentUser() async {
    userModel = await us.getCurrentUser();
  }

  Future<UserModel> getCurrentUserById(String id) async {
    return await us.getCurrentUserById(id);
  }
}
