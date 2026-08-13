// lib/view/signature_detail_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/model/requisition_model.dart';
import 'package:myapp/model/responseModel.dart';
import 'signature_pad_detail_page.dart'; // ✅ Import de la page signature dédiée
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:myapp/config/config.dart';

class SignatureDetailPage extends StatefulWidget {
  final ResponseModel responseModel;
  final RequisitionModel requisitionData; // ✅ Modèle complet de la réquisition

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
  bool _isSigned = false; // Pour mettre à jour l'UI après signature

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

    // 🔔 Écouter les mises à jour de signature en temps réel
    socket.on('signature_validated', (data) {
      if (mounted &&
          data['idRequisition'] == widget.requisitionData.idRequisition) {
        setState(() => _isSigned = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Signature validée par un autre utilisateur'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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

  // 🎯 Navigation vers la page de signature dédiée
  Future<void> _navigateToSignaturePad() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SignaturePadDetailPage(
          // ✅ Nouvelle classe
          responseModel: widget.responseModel,
          requisitionData: widget.requisitionData,
          signerName: _getSignerName(),
          signerRole:
              widget.responseModel.role, // Sera converti en HOD/RH/FM/IE
        ),
      ),
    );

    // Si signature réussie, mettre à jour l'UI locale
    if (result == true && mounted) {
      setState(() => _isSigned = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Signature enregistrée avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getSignerName() {
    // RHO signe pour l'employé, RH signe pour lui-même

    final nom = widget.responseModel.nom;
    final prenom = widget.responseModel.prenom;
    return '$prenom $nom'.trim().isEmpty ? 'Signer par' : '$prenom $nom';
  }

  String _formatDate(String? dateStr) {
    // ✅ Gestion null/vide en entrée
    if (dateStr == null || dateStr.isEmpty) return '–';

    try {
      final parts = dateStr.split(RegExp(r'[-T]'));
      if (parts.length >= 3) {
        return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
      }
      return dateStr;
    } catch (_) {
      // ✅ CORRECTION 1: Utiliser {} au lieu de =>
      // ✅ CORRECTION 2: Retourner un String non-nullable avec ?? '–'
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.requisitionData;
    final canSign = _isSigned == false; // Empêcher de re-signer si déjà fait

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la réquisition'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 📋 CARTE D'INFORMATIONS PROFESSIONNELLE
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🏷️ En-tête avec statut
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue.shade50, Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data.position,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _isSigned
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _isSigned ? '✓ Signé' : '⏳ En attente',
                                  style: TextStyle(
                                    color: _isSigned
                                        ? Colors.green.shade800
                                        : Colors.orange.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoRow('📁 Département', data.departement),
                          _buildInfoRow('division', data.division),
                          _buildInfoRow('👤 Signataire', _getSignerName()),
                          _buildInfoRow(
                            '📅 Date de début',
                            _formatDate(data.dateDebut),
                          ),
                          _buildInfoRow(
                            '📅 Date de fin',
                            _formatDate(data.dateFin),
                          ),
                          _buildInfoRow('🔢 site', data.site),
                          _buildInfoRow(
                            'nombre',
                            data.nombre?.toString() ?? '–',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
            ),

            // ✍️ BOUTON "SIGNER" - Toujours visible en bas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canSign ? _navigateToSignaturePad : null,
                  icon: const Icon(Icons.edit, size: 22),
                  label: Text(
                    _isSigned ? '✓ Déjà signé' : '✍️ Signer la réquisition',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSign
                        ? Colors.blue.shade700
                        : Colors.grey.shade400,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
