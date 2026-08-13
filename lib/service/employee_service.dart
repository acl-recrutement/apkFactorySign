// lib/service/employee_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../model/employee.dart';

class EmployeeService {
  static const String _endpoint =
      '${apiConfig.baseUrl}/api/perssonel/get/all';

  static Future<List<Employee>> getEmployees() async {
    print('📡 Appel : $_endpoint');

    try {
      final response = await http.get(Uri.parse(_endpoint));
      print('✅ Status: ${response.statusCode}');

      // ✅ CORRECTION : accepter 200 ET 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('📦 ${jsonList.length} employés reçus');

        final List<Employee> employees = [];
        for (var json in jsonList) {
          if (json is Map<String, dynamic>) {
            employees.add(Employee.fromJson(json));
          }
        }
        return employees;
      } else {
        print('❌ Erreur HTTP : ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Erreur : $e');
      throw Exception('Impossible de charger les employés');
    }
  }
}
