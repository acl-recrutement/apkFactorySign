import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../model/contract_access_item.dart';

class ContractService {
  static Future<List<ContractAccessItem>> getUnsignedContracts({
    required int idUser,
    required String site,
  }) async {
    final url = Uri.parse(apiConfig.getUnsignedContractsUrl(idUser, site));
    final response = await http.get(url, headers: apiConfig.defaultHeader);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }

    final body = response.body.trim();
    if (body.isEmpty) return [];

    final dynamic decoded = jsonDecode(body);
    List<dynamic> dataList = [];

    if (decoded is List) {
      dataList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      for (final key in ['data', 'result', 'contracts', 'response']) {
        if (decoded[key] is List) {
          dataList = decoded[key];
          break;
        }
      }
      if (dataList.isEmpty) {
        for (final value in decoded.values) {
          if (value is List) {
            dataList = value;
            break;
          }
        }
      }
    }

    return dataList
        .where((item) => item is Map<String, dynamic>)
        .map((item) => ContractAccessItem.fromJson(item))
        .toList();
  }
}
