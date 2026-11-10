import 'package:flutter/material.dart';
import 'package:e_sign/main.dart';
import 'package:e_sign/model/responseModel.dart';
import '../model/employee.dart';
import '../service/employee_service.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({Key? key, required this.responseModel}) : super(key: key);
  final ResponseModel? responseModel;
  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  late Future<List<Employee>> _employeeFuture;
  final TextEditingController _searchController = TextEditingController();
  String? _filterSexe;
  String? _filterSituation;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _employeeFuture = EmployeeService.getEmployees();
  }

  List<Employee> _filterEmployees(List<Employee> employees) {
    final query = _searchController.text.toLowerCase();
    return employees.where((emp) {
      final matchSexe = _filterSexe == null || emp.sexe == _filterSexe;
      final matchSituation =
          _filterSituation == null ||
          emp.situationMatrimoniale == _filterSituation;
      bool matchSearch = true;
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
        matchSearch = searchable.contains(query);
      }
      return matchSexe && matchSituation && matchSearch;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _filterSexe = null;
      _filterSituation = null;
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filtrer les employés',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 20),
              _buildDropdown(
                label: 'Sexe',
                value: _filterSexe,
                items: ['Masculin', 'Féminin', 'Autre'],
                onChanged: (v) {
                  setModalState(() => _filterSexe = v);
                  setState(() => _filterSexe = v);
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Situation matrimoniale',
                value: _filterSituation,
                items: ['Célibataire', 'Marié(e)', 'Divorcé(e)'],
                onChanged: (v) {
                  setModalState(() => _filterSituation = v);
                  setState(() => _filterSituation = v);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _filterSexe = null;
                          _filterSituation = null;
                        });
                        setState(() {
                          _filterSexe = null;
                          _filterSituation = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshEmployees() async {
    setState(() {
      _employeeFuture = EmployeeService.getEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icon/logo.jpg',
                  fit: BoxFit.contain,
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.business,
                      size: 18,
                      color: const Color(0xFF1565C0),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Employés',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _resetFilters();
              _refreshEmployees();
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshEmployees,
          color: const Color(0xFF1565C0),
          strokeWidth: 2.5,
          child: FutureBuilder<List<Employee>>(
            future: _employeeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1565C0),
                    strokeWidth: 3,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: Color(0xFFE53935),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Erreur de chargement',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error.toString().split(':').last.trim()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _employeeFuture = EmployeeService.getEmployees();
                            });
                          },
                          icon: const Icon(Icons.sync_rounded, size: 20),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final employees = snapshot.data ?? [];
              final filtered = _filterEmployees(employees);

              if (employees.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.people_outline_rounded,
                            size: 40,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Aucun employé',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'La liste des employés est vide pour le moment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (filtered.isEmpty && employees.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Aucun résultat',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Essayez de modifier vos critères de recherche.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Rechercher (nom, CIN, téléphone…)',
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${filtered.length} employé${filtered.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF424242),
                            ),
                          ),
                        ),
                        if (_filterSexe != null || _filterSituation != null)
                          TextButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(
                              Icons.filter_list_off_rounded,
                              size: 18,
                            ),
                            label: const Text('Réinitialiser'),
                          ),
                        IconButton(
                          onPressed: _openFilterSheet,
                          icon: Icon(
                            Icons.filter_list_rounded,
                            color:
                                _filterSexe != null || _filterSituation != null
                                ? const Color(0xFF1565C0)
                                : const Color(0xFF757575),
                          ),
                          tooltip: 'Filtres',
                        ),
                      ],
                    ),
                    if (_filterSexe != null || _filterSituation != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (_filterSexe != null)
                            Chip(
                              label: Text(_filterSexe!),
                              onDeleted: () =>
                                  setState(() => _filterSexe = null),
                              backgroundColor: const Color(0xFFE3F2FD),
                              deleteIconColor: const Color(0xFF1565C0),
                            ),
                          if (_filterSituation != null)
                            Chip(
                              label: Text(_filterSituation!),
                              onDeleted: () =>
                                  setState(() => _filterSituation = null),
                              backgroundColor: const Color(0xFFE3F2FD),
                              deleteIconColor: const Color(0xFF1565C0),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    ...filtered.map((emp) => _buildEmployeeCard(emp)),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(Employee emp) {
    final initials = '${emp.prenom[0]}${emp.nom[0]}'.toUpperCase();
    return Tooltip(
      message: 'Voir le profil de ${emp.prenom} ${emp.nom}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            hapticFeedback();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profil de ${emp.prenom} ${emp.nom}'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: emp.getSexeColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: emp.getSexeColor(),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${emp.prenom} ${emp.nom}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${emp.cin} • ${emp.telephone}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: emp.getSexeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        emp.sexe,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: emp.getSexeColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: emp.getSituationColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        emp.situationMatrimoniale,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: emp.getSituationColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFFBDBDBD),
                  size: 20,
                ),
              ],
            ),
          ),
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
      width: double.infinity,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
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
          onChanged: onChanged,
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
