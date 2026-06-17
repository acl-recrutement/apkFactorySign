import 'dart:convert';

import '../model/userModel.dart';
import '../model/responseModel.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class Authservice {
  Future<ResponseModel> LoginUSer(Usermodel user) async {
    final response = await http.post(
      Uri.parse(apiConfig.loginUrl),
      headers: apiConfig.defaultHeader,
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 201) {
      return ResponseModel.fromJson(jsonDecode(response.body));
    } else {
      print("STATUS: ${response.statusCode}");
      print("BODY: '${response.body}'");

      if (response.statusCode == 401) {
        return ResponseModel.error();
      } else {
        throw Exception('Une erreur se produit : ${response.statusCode}');
      }
    }
  }
}
