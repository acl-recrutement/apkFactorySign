import 'package:flutter/foundation.dart';

class Usermodel {
  final String mail;
  final String password;
  Usermodel({required this.mail, required this.password});

  factory Usermodel.fromJson(Map<String, dynamic> json) {
    return Usermodel(mail: json['mail'], password: json['password']);
  }
  Map<String, dynamic> toJson() {
    return {'mail': mail, 'mdp': password};
  }
}
