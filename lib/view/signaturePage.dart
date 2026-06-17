import 'package:flutter/material.dart';
import 'package:myapp/config/config.dart';
import 'package:myapp/model/responseModel.dart';
import 'package:myapp/model/requisition_model.dart';
import 'package:myapp/service/requisition_service.dart';
import 'package:myapp/view/HomePage.dart';

import 'package:myapp/view/signature_detail_page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SignaturePage extends StatefulWidget {
  final ResponseModel responseModel;

  const SignaturePage({Key? key, required this.responseModel})
    : super(key: key);

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  late Future<List<RequisitionModel>> _futureRequisitions;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _futureRequisitions = _loadRequisitions();
    _initSocket();
  }

  /// Charge les réquisitions depuis le service en utilisant le site de l'utilisateur
  Future<List<RequisitionModel>> _loadRequisitions() {
    return RequisitionService.getUnsignedRequisitions(
      widget.responseModel.site,
    );
  }

  /// Initialisation du WebSocket
  void _initSocket() {
    socket = IO.io(apiConfig.baseUrl, {
      'transports': ['websocket'],
    });

    socket.on('signature_created', (data) {
      print('🔌 SOCKET: signature_created → $data');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${data['message'] ?? 'Document mis à jour'}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _futureRequisitions = _loadRequisitions());
      }
    });

    socket.on('timer_ended', (data) => _handleTimerEvent(data));
    socket.on('timer_closed', (data) => _handleTimerEvent(data));

    socket.connect();
  }

  /// Gestion des événements timer → suppression de l'accès
  Future<void> _handleTimerEvent(dynamic data) async {
    final idRequisition = data['idRequisition'];
    if (idRequisition != null) {
      final success = await RequisitionService.deleteAccessByRequisition(
        idRequisition,
      );
      if (success && mounted) {
        setState(() => _futureRequisitions = _loadRequisitions());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Homepage(responseModel: widget.responseModel),
            ),
          ),
        ),
        title: Text(
          'À signer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: FutureBuilder<List<RequisitionModel>>(
        future: _futureRequisitions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          final requisitions = snapshot.data ?? [];
          if (requisitions.isEmpty) {
            return _buildEmptyState();
          }
          return _buildRequisitionList(requisitions);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erreur : $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                setState(() => _futureRequisitions = _loadRequisitions()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucun document à signer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous navez aucun document en attente pour le site ${widget.responseModel.site}.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequisitionList(List<RequisitionModel> requisitions) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: requisitions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = requisitions[index];
        if (widget.responseModel.role == 'HOD' && req.signhod == null) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                req.displayTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.departement,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    req.formattedDateDebut,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  _buildSignatureChips(req),
                ],
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignatureDetailPage(
                    responseModel: widget.responseModel,
                    requisitionData: req,
                    // ✅ Passage du modèle complet
                  ),
                ),
              ),
            ),
          );
        } else if (widget.responseModel.role == 'RH' &&
            req.signhr == null &&
            req.signhod != null) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                req.displayTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.departement,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    req.formattedDateDebut,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  _buildSignatureChips(req),
                ],
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignatureDetailPage(
                    responseModel: widget.responseModel,
                    requisitionData: req,
                    // ✅ Passage du modèle complet
                  ),
                ),
              ),
            ),
          );
        } else if (widget.responseModel.role == 'IE' &&
            req.signie == null &&
            req.signhr != null) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                req.displayTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.departement,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    req.formattedDateDebut,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  _buildSignatureChips(req),
                ],
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignatureDetailPage(
                    responseModel: widget.responseModel,
                    requisitionData: req,
                    // ✅ Passage du modèle complet
                  ),
                ),
              ),
            ),
          );
        } else if (widget.responseModel.role == 'FM' &&
            req.signfm == null &&
            req.signie != null &&
            req.signhr != null) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                req.displayTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.departement,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    req.formattedDateDebut,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  _buildSignatureChips(req),
                ],
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignatureDetailPage(
                    responseModel: widget.responseModel,
                    requisitionData: req,
                    // ✅ Passage du modèle complet
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink(); // Ne rien afficher si le contrat ne correspond pas au rôle
        }
      },
    );
  }

  /// Affiche des chips pour les signatures manquantes
  Widget _buildSignatureChips(RequisitionModel req) {
    if (req.isFullySigned) {
      return const Chip(
        label: Text(
          '✓ Signé',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: Colors.green,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    }
    final missing = req.missingSignatures.take(2).join(', ');
    return Chip(
      label: Text('En attente: $missing', style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.orange[100],
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
