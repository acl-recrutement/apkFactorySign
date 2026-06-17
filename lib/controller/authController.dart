import 'package:flutter/material.dart';
import '../service/authService.dart';
import '../model/userModel.dart';
import '../model/responseModel.dart';

class Authcontroller extends ChangeNotifier {
  final authServ = Authservice();
  Future<ResponseModel> LoginUser(Usermodel user) async {
    return await authServ.LoginUSer(user);
  }
}
