// lib/view/signature_detail_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/model/requisition_model.dart';
import 'package:myapp/model/responseModel.dart';
import 'signature_pad_detail_page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:myapp/config/config.dart';

class SignatureDetailPage extends StatefulWidget {
  final ResponseModel responseModel;
  final RequisitionModel requisitionData;

  const SignatureDetailPage({
    Key? key,
    required this.responseModel,
    required this.requisitionData,
  }) : super(key: key);

  @override
  State<SignatureDetailPage> createState() => _SignatureDetailPageState();
}

class _SignatureDetailPageState extends State<SignatureDetailPage> {
  late final IO.Socket socket;
  bool _isSigned = false;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io(
      apiConfig.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    )..connect();

    socket.on('signature_validated', (data) {
      if (mounted &&
          data['idRequisition'] == widget.requisitionData.idRequisition) {
        setState(() => _isSigned = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Signature validée par un autre utilisateur'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  Future<void> _navigateToSignaturePad() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SignaturePadDetailPage(
          responseModel: widget.responseModel,
          requisitionData: widget.requisitionData,
          signerName: _getSignerName(),
          signerRole: widget.responseModel.role,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() => _isSigned = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Signature enregistrée avec succès'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      );
    }
  }

  String _getSignerName() {
    final nom = widget.responseModel.nom;
    final prenom = widget.responseModel.prenom;
    return '$prenom $nom'.trim().isEmpty ? 'Signer par' : '$prenom $nom';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '–';

    try {
      final parts = dateStr.split(RegExp(r'[-T]'));
      if (parts.length >= 3) {
        return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.requisitionData;
    final canSign = _isSigned == false;

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
              'Détails de la réquisition',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              Expanded(
                                child: Text(
                                  data.position,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Color(0xFF37474F),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _isSigned
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _isSigned ? '✓ Signé' : '⏳ En attente',
                                  style: TextStyle(
                                    color: _isSigned
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFEF6C00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
                          _buildInfoRow('📁 Département', data.departement),
                          _buildInfoRow('Division', data.division),
                          _buildInfoRow('👤 Signataire', _getSignerName()),
                          _buildInfoRow('📅 Date de début', _formatDate(data.dateDebut)),
                          _buildInfoRow('📅 Date de fin', _formatDate(data.dateFin)),
                          _buildInfoRow('🔢 Site', data.site),
                          _buildInfoRow('Nombre', data.nombre?.toString() ?? '–'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canSign ? _navigateToSignaturePad : null,
                  icon: Icon(
                    _isSigned ? Icons.check_circle_rounded : Icons.edit_rounded,
                    size: 22,
                  ),
                  label: Text(
                    _isSigned ? '✓ Déjà signé' : '✍️ Signer la réquisition',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSign
                        ? const Color(0xFF1565C0)
                        : const Color(0xFFE0E0E0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: canSign ? 3 : 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
