import 'package:flutter/material.dart';
import 'package:myapp/model/responseModel.dart';
import '../model/employee.dart';
import '../service/employee_service.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({Key? key, required this.responseModel})
    : super(key: key); // ✅ plus de responseModel
  final ResponseModel? responseModel;
  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  late Future<List<Employee>> _employeeFuture;
  final TextEditingController _searchController = TextEditingController();
  String? _filterSexe;
  String? _filterSituation;

  @override
  void initState() {
    super.initState();
    _employeeFuture = EmployeeService.getEmployees();
  }

  List<Employee> _filterEmployees(List<Employee> employees) {
    final query = _searchController.text.toLowerCase();
    return employees.where((emp) {
      if (query.isNotEmpty) {
        final searchable = [
          emp.nom,
          emp.prenom,
          emp.cin,
          emp.telephone,
          emp.adresse,
          emp.situationMatrimoniale,
          emp.sexe,
        ].join(' ').toLowerCase();
        return searchable.contains(query);
      }

      final matchSexe = _filterSexe == null || emp.sexe == _filterSexe;
      final matchSituation =
          _filterSituation == null ||
          emp.situationMatrimoniale == _filterSituation;

      return matchSexe && matchSituation;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _filterSexe = null;
      _filterSituation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.people, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Liste des employés',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _resetFilters();
              setState(() {
                _employeeFuture = EmployeeService.getEmployees();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Employee>>(
          future: _employeeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      '❌ ${snapshot.error.toString().split(':').last.trim()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _employeeFuture = EmployeeService.getEmployees();
                        });
                      },
                      icon: const Icon(Icons.sync),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final employees = snapshot.data ?? [];
            final filtered = _filterEmployees(employees);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Recherche
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
                      hintText: 'Rechercher (nom, CIN, téléphone…)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // 📊 Stats — ✅ CORRIGÉ : plus de "Instance of"
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${filtered.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const TextSpan(text: ' employé'),
                        TextSpan(text: filtered.length != 1 ? 's' : ''),
                        if (employees.length > filtered.length)
                          TextSpan(
                            text: ' sur ${employees.length}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // 🗂️ Filtres
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildDropdown(
                            label: 'Sexe',
                            value: _filterSexe,
                            items: ['Masculin', 'Féminin', 'Autre'],
                            onChanged: (v) => setState(() => _filterSexe = v),
                          ),
                          _buildDropdown(
                            label: 'Situation',
                            value: _filterSituation,
                            items: ['Célibataire', 'Marié(e)', 'Divorcé(e)'],
                            onChanged: (v) =>
                                setState(() => _filterSituation = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📋 Tableau
                  Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataRowHeight: 60,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Nom',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Prénom',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CIN',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Téléphone',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Sexe',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Situation',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(label: Text('')),
                        ],
                        rows: filtered.map((emp) {
                          // ✅ Sécurité : valeurs par défaut si null
                          final nom = emp.nom;
                          final prenom = emp.prenom;
                          final cin = emp.cin;
                          final tel = emp.telephone;
                          final sexe = emp.sexe;
                          final situation = emp.situationMatrimoniale;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  nom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(Text(prenom)),
                              DataCell(Text(cin)),
                              DataCell(Text(tel)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: emp.getSexeColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    sexe,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: emp.getSexeColor(),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: emp.getSituationColor().withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    situation,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: emp.getSituationColor(),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                    Icons.visibility,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Profil de $prenom $nom'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2 - 6,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: DropdownButton<String?>(
          isDense: true,
          value: value,
          underline: const SizedBox(),
          hint: const Text('Tous'),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Tous')),
            for (final item in items)
              DropdownMenuItem<String?>(value: item, child: Text(item)),
          ],
          onChanged: _searchController.text.isEmpty ? onChanged : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
