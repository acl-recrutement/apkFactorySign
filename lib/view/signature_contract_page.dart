// lib/view/signature_contract_page.dart
import 'package:flutter/material.dart';
import 'package:myapp/model/responseModel.dart';
import 'package:myapp/view/ContractDetailsPage.dart';
import 'contractPage.dart';
import 'DedicatedSignaturePage.dart'; // ✅ Nouvelle page dédiée

class SignatureContractPage extends StatefulWidget {
  final ResponseModel responseModel;
  final Map<String, dynamic> requisitionData;

  const SignatureContractPage({
    Key? key,
    required this.responseModel,
    required this.requisitionData,
  }) : super(key: key);

  @override
  State<SignatureContractPage> createState() => _SignatureContractPageState();
}

class _SignatureContractPageState extends State<SignatureContractPage> {
  // ─────── Logique dynamique du nom du signataire ───────
  String get _signerName {
    if (widget.responseModel.role == 'RHO') {
      // RHO signe pour l'employé → afficher le nom de l'employé
      final nom = widget.requisitionData['nom'] ?? '';
      final prenom = widget.requisitionData['prenom'] ?? '';
      final fullName = '$prenom $nom'.trim();
      return fullName.isEmpty ? 'Employé' : fullName;
    } else {
      // RH signe pour lui-même → afficher le nom de l'utilisateur connecté
      final nom = widget.responseModel.nom;
      final prenom = widget.responseModel.prenom;
      final fullName = '$prenom $nom'.trim();
      return fullName.isEmpty ? 'Responsable RH' : fullName;
    }
  }

  String get _signerRoleLabel {
    return widget.responseModel.role == 'RHO' ? 'Employé' : 'Responsable RH';
  }

  Color get _signerAvatarColor {
    return widget.responseModel.role == 'RHO'
        ? Colors.green.shade100
        : Colors.blue.shade100;
  }

  Color get _signerTextColor {
    return widget.responseModel.role == 'RHO' ? Colors.green : Colors.blue;
  }

  // ─────── Navigation vers la page de signature dédiée ───────
  Future<void> _navigateToSignature() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DedicatedSignaturePage(
          responseModel: widget.responseModel,
          requisitionData: widget.requisitionData,
          signerName: _signerName,
          signerRole: widget.responseModel.role, // 'RHO' ou 'RH'
        ),
      ),
    );

    // Si signature réussie, retour direct à la liste des contrats
    if (result == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ContractPage(responseModel: widget.responseModel),
        ),
      );
    }
  }

  Future<void> _navigateToContractDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractDetailsPage(
          requisitionData: widget.requisitionData,
          signerRole: widget.responseModel.role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 📋 Extraction des données du contrat
    final idContract = widget.requisitionData['idRequisition'] ?? '–';
    final matricule = widget.requisitionData['matricule']?.toString() ?? '–';
    final contractType = widget.requisitionData['type'] ?? 'CDI';
    final employeeName =
        widget.requisitionData['nom'] != null &&
            widget.requisitionData['prenom'] != null
        ? '${widget.requisitionData['prenom']} ${widget.requisitionData['nom']}'
        : 'Employé';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature du contrat'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 🏷️ CARTE D'INFORMATIONS DU CONTRAT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête : Numéro de contrat + Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Contrat n°$idContract',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.blueGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          contractType,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, thickness: 1),

                  // 👤 Informations de l'employé
                  const Text(
                    '📄 Employé concerné',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          employeeName.isNotEmpty
                              ? employeeName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employeeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Matricule : $matricule',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, thickness: 1),

                  // ✍️ Informations du signataire actuel
                  Text(
                    '✍️ Signataire : $_signerRoleLabel',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _signerAvatarColor,
                        child: Text(
                          _signerName.isNotEmpty
                              ? _signerName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _signerTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _signerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.responseModel.role == 'RHO'
                                  ? 'Signe au nom de l\'employé'
                                  : 'Signe en tant que RH',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToContractDetails,
                      icon: const Icon(Icons.rule, size: 22),
                      label: const Text(
                        'Voir les détails du contrat',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 245, 7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.blue.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🎯 BOUTON "SIGNER" → Page dédiée performante
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton principal
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToSignature,
                      icon: const Icon(Icons.edit, size: 22),
                      label: const Text(
                        '✍️ Signer le contrat',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.blue.withOpacity(0.4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Texte d'aide
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Appuyez pour ouvrir la zone de signature optimisée',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ℹ️ Note informative
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade800,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'La signature est sécurisée et horodatée. Une fois validée, elle ne peut plus être modifiée.',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
