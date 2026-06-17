import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      site: widget.responseModel.site ?? 'Tana',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrats'),
        backgroundColor: Colors.blue.shade700,
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Homepage(responseModel: widget.responseModel),
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<List<ContractAccessItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          final list = snapshot.data ?? [];

          if (list.isEmpty) return const Center(child: Text('Aucun contrat'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = list[index];
              final pers = item.personnel;
              final contract = item.contract;
              final infoFact = item.infoFactory;
              final dossier = item.dossier;
              // ✅ CORRECTION : matricule vient de contract, PAS de personnel
              final matricule = contract?.matricule ?? 'N/A';
              if (widget.responseModel.role == 'RHO' &&
                  contract?.signhr != null) {
                return Card(
                  child: ListTile(
                    title: Text('${pers?.nom ?? ''} ${pers?.prenom ?? ''}'),
                    subtitle: Text(
                      'Mat: $matricule • ${contract?.type ?? 'Type inconnu'}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignatureContractPage(
                          responseModel: widget.responseModel,
                          requisitionData: {
                            'idRequisition': contract?.idContract ?? 0,
                            // ✅ CORRECTION : matricule vient de contract
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
                    ),
                  ),
                );
              } else if (widget.responseModel.role == 'RH' &&
                  contract?.signhr == null) {
                return Card(
                  child: ListTile(
                    title: Text('${pers?.nom ?? ''} ${pers?.prenom ?? ''}'),
                    subtitle: Text(
                      'Mat: $matricule • ${contract?.type ?? 'Type inconnu'}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignatureContractPage(
                          responseModel: widget.responseModel,
                          requisitionData: {
                            'idRequisition': contract?.idContract ?? 0,
                            // ✅ CORRECTION : matricule vient de contract
                            'matricule': contract?.matricule ?? '',
                            'idPers': contract?.idPers ?? 0,
                            'idRh': widget.responseModel.id,
                            'nom': pers?.nom ?? '',
                            'prenom': pers?.prenom ?? '',
                            'type': contract?.type ?? '',
                          },
                        ),
                      ),
                    ),
                  ),
                ); // Handle the case where the contract is not signed by RH
              } else {
                return const SizedBox.shrink(); // Ne rien afficher pour les autres cas
              }
            },
          );
        },
      ),
    );
  }
}
