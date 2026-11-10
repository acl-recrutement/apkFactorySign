// lib/view/signature_contract_page.dart
import 'package:flutter/material.dart';
import 'package:e_sign/model/responseModel.dart';
import 'package:e_sign/view/ContractDetailsPage.dart';
import 'contractPage.dart';
import 'DedicatedSignaturePage.dart';

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
  String get _signerName {
    if (widget.responseModel.role == 'RHO') {
      final nom = widget.requisitionData['nom'] ?? '';
      final prenom = widget.requisitionData['prenom'] ?? '';
      final fullName = '$prenom $nom'.trim();
      return fullName.isEmpty ? 'Employé' : fullName;
    } else {
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
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFE3F2FD);
  }

  Color get _signerTextColor {
    return widget.responseModel.role == 'RHO'
        ? const Color(0xFF2E7D32)
        : const Color(0xFF1565C0);
  }

  Future<void> _navigateToSignature() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DedicatedSignaturePage(
          responseModel: widget.responseModel,
          requisitionData: widget.requisitionData,
          signerName: _signerName,
          signerRole: widget.responseModel.role,
        ),
      ),
    );

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
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
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
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Signature du contrat',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        surfaceTintColor: const Color(0xFF1565C0),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFE3F2FD), Colors.white],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Contrat n°$idContract',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: Color(0xFF37474F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          contractType,
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
                  Text(
                    '📄 Employé concerné',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFE3F2FD),
                        child: Text(
                          employeeName.isNotEmpty
                              ? employeeName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0),
                            fontSize: 18,
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
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Matricule : $matricule',
                              style: const TextStyle(
                                color: Color(0xFF757575),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
                  Text(
                    '✍️ Signataire : $_signerRoleLabel',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _signerAvatarColor,
                        child: Text(
                          _signerName.isNotEmpty
                              ? _signerName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _signerTextColor,
                            fontSize: 18,
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
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.responseModel.role == 'RHO'
                                  ? 'Signe au nom de l\'employé'
                                  : 'Signe en tant que RH',
                              style: const TextStyle(
                                color: Color(0xFF757575),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToContractDetails,
                      icon: const Icon(Icons.rule_rounded, size: 22),
                      label: const Text(
                        'Voir les détails du contrat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToSignature,
                      icon: const Icon(Icons.edit_rounded, size: 22),
                      label: const Text(
                        '✍️ Signer le contrat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 18,
                          color: const Color(0xFF757575),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Appuyez pour ouvrir la zone de signature optimisée',
                            style: TextStyle(
                              color: const Color(0xFF757575),
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

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: const Color(0xFFF9A825),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'La signature est sécurisée et horodatée. Une fois validée, elle ne peut plus être modifiée.',
                      style: TextStyle(
                        color: const Color(0xFFF57F17),
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
