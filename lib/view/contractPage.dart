import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import '../service/contract_service.dart';
import '../model/contract_access_item.dart';
import '../model/responseModel.dart';
import 'signature_contract_page.dart';
import 'HomePage.dart';

class ContractPage extends StatefulWidget {
  final ResponseModel responseModel;
  const ContractPage({Key? key, required this.responseModel}) : super(key: key);

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  late Future<List<ContractAccessItem>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ContractService.getUnsignedContracts(
      idUser: widget.responseModel.id,
      site: widget.responseModel.site,
    );
  }

  Future<void> _refreshContracts() async {
    setState(() {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              'Contrats',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: const Color(0xFF1565C0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
      ),
      body: FutureBuilder<List<ContractAccessItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                backgroundColor: Color(0xFF42A5F5),
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
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _load,
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
          final list = snapshot.data ?? [];

          if (list.isEmpty) {
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
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 40,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aucun contrat',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aucun contrat en attente de signature.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF757575), fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshContracts,
            color: Colors.white,
            backgroundColor: const Color(0xFF1565C0),
            strokeWidth: 2.5,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = list[index];
                final pers = item.personnel;
                final contract = item.contract;
                final infoFact = item.infoFactory;
                final matricule = contract?.matricule ?? 'N/A';
                if (widget.responseModel.role == 'RHO' &&
                    contract?.signhr != null) {
                  return _buildContractCard(
                    pers: pers,
                    contract: contract,
                    infoFact: infoFact,
                    matricule: matricule,
                  );
                } else if (widget.responseModel.role == 'RH' &&
                    contract?.signhr == null) {
                  return _buildContractCard(
                    pers: pers,
                    contract: contract,
                    infoFact: infoFact,
                    matricule: matricule,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildContractCard({
    required Personnel? pers,
    required Contract? contract,
    required InfoFactory? infoFact,
    required String matricule,
  }) {
    final fullName = '${pers?.nom ?? ''} ${pers?.prenom ?? ''}'.trim();
    final initials = fullName.isNotEmpty
        ? (fullName.split(' ').map((e) => e[0]).join().toUpperCase().padRight(2, '?').substring(0, 2))
        : '??';
    final contractType = contract?.type ?? 'Type inconnu';

    Color typeColor;
    switch (contractType.toUpperCase()) {
      case 'CDI':
        typeColor = const Color(0xFF2E7D32);
        break;
      case 'CDD':
        typeColor = const Color(0xFFEF6C00);
        break;
      case 'STAGE':
        typeColor = const Color(0xFF1565C0);
        break;
      default:
        typeColor = const Color(0xFF757575);
    }

    return Tooltip(
      message: "${fullName.isEmpty ? 'Employé inconnu' : fullName} - $matricule",
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            hapticFeedback();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignatureContractPage(
                  responseModel: widget.responseModel,
                  requisitionData: {
                    'idRequisition': contract?.idContract ?? 0,
                    'matricule': contract?.matricule ?? '',
                    'idPers': contract?.idPers ?? 0,
                    'idRh': widget.responseModel.id,
                    'nom': pers?.nom ?? '',
                    'prenom': pers?.prenom ?? '',
                    'type': contract?.type ?? '',
                    'site': infoFact?.site ?? '',
                    'salaire': contract?.salaire ?? '',
                    'cin': pers?.cin ?? '',
                    'Fonction': infoFact?.fonction ?? '',
                    'Département': infoFact?.departement ?? '',
                    'naissance': pers?.date_naiss ?? '',
                    'Adresse': pers?.adresse ?? '',
                  },
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
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: typeColor,
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
                        fullName.isEmpty ? 'Employé inconnu' : fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Mat: $matricule',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          contractType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
}
