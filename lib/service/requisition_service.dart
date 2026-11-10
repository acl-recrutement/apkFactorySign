import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_sign/config/config.dart';
import 'package:e_sign/model/requisition_model.dart';

class RequisitionService {
  /// Récupère les réquisitions non validées pour un site donné
  static Future<List<RequisitionModel>> getUnsignedRequisitions(
    String site,
  ) async {
    final url = Uri.parse(
      '${apiConfig.baseUrl}/api/requisition/get/notval/$site',
    );

    final response = await http.get(url, headers: apiConfig.defaultHeader);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.body.trim();
      if (body.isEmpty) return [];

      final List<dynamic> jsonList = json.decode(body);
      return jsonList.map((item) => RequisitionModel.fromJson(item)).toList();
    } else {
      throw Exception(
        'Erreur ${response.statusCode} lors du chargement des réquisitions',
      );
    }
  }

  /// Supprime un accès par idRequisition (utilisé pour timer_ended/closed)
  static Future<bool> deleteAccessByRequisition(int idRequisition) async {
    final url = Uri.parse(
      '${apiConfig.baseUrl}/api/mobile/acces/req/delete/byrequisition/$idRequisition',
    );

    final response = await http.delete(url, headers: apiConfig.defaultHeader);
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
