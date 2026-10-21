import 'package:flutter/material.dart';
import 'package:myapp/config/config.dart';
import 'package:myapp/main.dart';
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

  Future<List<RequisitionModel>> _loadRequisitions() {
    return RequisitionService.getUnsignedRequisitions(
      widget.responseModel.site,
    );
  }

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
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
        setState(() => _futureRequisitions = _loadRequisitions());
      }
    });

    socket.on('timer_ended', (data) => _handleTimerEvent(data));
    socket.on('timer_closed', (data) => _handleTimerEvent(data));

    socket.connect();
  }

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

  Future<void> _refreshRequisitions() async {
    setState(() => _futureRequisitions = _loadRequisitions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
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
              'À signer',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.white,
      ),
      body: FutureBuilder<List<RequisitionModel>>(
        future: _futureRequisitions,
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
            return _buildErrorState(snapshot.error.toString());
          }
          final requisitions = snapshot.data ?? [];
          return _buildRequisitionList(requisitions);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  setState(() => _futureRequisitions = _loadRequisitions()),
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

Widget _buildRequisitionList(List<RequisitionModel> requisitions) {
    // Filtre par département pour le rôle HOD
    final userDept = widget.responseModel.departement;
    final filtered = (widget.responseModel.role == 'HOD' && userDept != null && userDept.isNotEmpty)
        ? requisitions.where((req) => req.departement.trim().toLowerCase() == userDept.trim().toLowerCase()).toList()
        : requisitions;

    if (filtered.isEmpty) {
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
                'Tout est à jour !',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vous n\'avez aucun document en attente pour le site ${widget.responseModel.site}${widget.responseModel.role == 'HOD' ? ' et département $userDept' : ''}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshRequisitions,
      color: const Color(0xFF1565C0),
      strokeWidth: 2.5,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final req = filtered[index];
          if (widget.responseModel.role == 'HOD' && req.signhod == null) {
            return _buildRequisitionCard(req);
          } else if (widget.responseModel.role == 'RH' &&
              req.signhr == null &&
              req.signhod != null) {
            return _buildRequisitionCard(req);
          } else if (widget.responseModel.role == 'IE' &&
              req.signie == null &&
              req.signhr != null) {
            return _buildRequisitionCard(req);
          } else if (widget.responseModel.role == 'FM' &&
              req.signfm == null &&
              req.signie != null &&
              req.signhr != null) {
            return _buildRequisitionCard(req);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

    Widget _buildRequisitionCard(RequisitionModel req) {
      final initials = req.displayTitle.isNotEmpty
          ? req.displayTitle[0].toUpperCase()
          : '?';
      return Tooltip(
        message: req.displayTitle,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              hapticFeedback();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignatureDetailPage(
                    responseModel: widget.responseModel,
                    requisitionData: req,
                  ),
                ),
              );
            },
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 20,
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
                        req.displayTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        req.departement,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        req.formattedDateDebut,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSignatureChips(req),
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

  Widget _buildSignatureChips(RequisitionModel req) {
    if (req.isFullySigned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF2E7D32)),
            const SizedBox(width: 4),
            Text(
              'Signé',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    final total = 4;
    final signed = total - req.missingSignatures.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pending_rounded, size: 14, color: const Color(0xFFEF6C00)),
          const SizedBox(width: 4),
          Text(
            '$signed/$total signé${signed != 1 ? 's' : ''}',
            style: const TextStyle(
              color: Color(0xFFEF6C00),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
