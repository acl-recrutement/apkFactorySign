// lib/view/dedicated_signature_page.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/config.dart';
import '../model/responseModel.dart';
import 'widgets/signature_painter.dart';
import 'contractPage.dart';

// 📦 Structure point + pression (doit être accessible aux deux fichiers)
class StrokePoint {
  final Offset offset;
  final double pressure;
  const StrokePoint(this.offset, this.pressure);
}

class DedicatedSignaturePage extends StatefulWidget {
  final ResponseModel responseModel;
  final Map<String, dynamic> requisitionData;
  final String signerName;
  final String signerRole; // 'RHO' ou 'RH'

  const DedicatedSignaturePage({
    Key? key,
    required this.responseModel,
    required this.requisitionData,
    required this.signerName,
    required this.signerRole,
  }) : super(key: key);

  @override
  State<DedicatedSignaturePage> createState() => _DedicatedSignaturePageState();
}

class _DedicatedSignaturePageState extends State<DedicatedSignaturePage> {
  final GlobalKey _painterKey = GlobalKey();
  final List<List<StrokePoint>> _strokes = [];
  final List<StrokePoint> _currentStroke = [];
  bool _isSubmitting = false;

  // ─────── Capture tactile & stylet ───────
  void _onPointerDown(PointerDownEvent event) {
    final RenderBox? box =
        _painterKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localPos = box.globalToLocal(event.position);
    setState(() {
      _currentStroke.clear();
      _currentStroke.add(StrokePoint(localPos, event.pressure));
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    final RenderBox? box =
        _painterKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localPos = box.globalToLocal(event.position);
    setState(() => _currentStroke.add(StrokePoint(localPos, event.pressure)));
  }

  void _onPointerUp(PointerEvent event) {
    if (_currentStroke.length > 1) {
      setState(() => _strokes.add(List.from(_currentStroke)));
    }
    _currentStroke.clear();
  }

  void _clear() => setState(() {
    _strokes.clear();
    _currentStroke.clear();
  });

  // ─────── Capture PNG haute qualité ───────
  Future<Uint8List?> _captureSignature() async {
    final boundary =
        _painterKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  // ─────── 🔑 SOUMISSION API CORRIGÉE ───────
  Future<void> _submitSignature() async {
    if (_strokes.isEmpty && _currentStroke.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez signer avant de valider'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1️⃣ Capture la signature PNG haute qualité
      final bytes = await _captureSignature();
      if (bytes == null) throw Exception('Échec de la capture');

      final idContract = widget.requisitionData['idRequisition'];

      // 2️⃣ 🔑 LOGIQUE MÉTIER : Déterminer les paramètres selon le rôle connecté
      // RH = signe pour lui-même | RHO = signe pour l'employé (proxy)
      final isRH = widget.responseModel.role == 'RH';

      // Paramètre pour le backend (nouvel endpoint single)
      final signerRoleParam = isRH ? 'rh' : 'employe';

      // Champ pour la mise à jour PostgreSQL
      final dbFieldName = isRH ? 'signhr' : 'signPers';

      // Endpoint de mise à jour DB
      final dbUpdateUrl = isRH
          ? '${apiConfig.baseUrl}/api/contract/update/sign/hr/$idContract'
          : '${apiConfig.baseUrl}/api/contract/update/sign/pers/$idContract';

      // 3️⃣ Étape 1 : Upload UNIQUE vers Supabase (NOUVEL ENDPOINT /single/)
      final uploadUrl = Uri.parse(
        '${apiConfig.baseUrl}/api/sendImage/signature/contract/single/$idContract',
      );
      final uploadRequest = http.MultipartRequest('POST', uploadUrl);

      // ✅ CORRECTION : Champ 'file' + paramètre 'signer_role' dans fields
      uploadRequest.files.add(
        http.MultipartFile.fromBytes(
          'file', // ← Nom du champ attendu par le backend (pas signature_rh/employe)
          bytes,
          filename: 'signature_${signerRoleParam}_$idContract.png',
          contentType: MediaType('image', 'png'),
        ),
      );

      // ✅ CORRECTION : Ajouter signer_role dans les champs du formulaire
      uploadRequest.fields['signer_role'] = signerRoleParam;

      final uploadResponse = await http.Response.fromStream(
        await uploadRequest.send(),
      );

      if (uploadResponse.statusCode != 200) {
        final error =
            jsonDecode(uploadResponse.body)['error'] ?? 'Erreur inconnue';
        throw Exception('Échec upload Supabase: $error');
      }

      // 4️⃣ Récupérer le chemin retour du serveur
      final uploadResult = jsonDecode(uploadResponse.body);
      // ✅ APRÈS (corrigé) : utiliser la clé dynamique selon le rôle
      final signaturePath =
          uploadResult[dbFieldName]; // dbFieldName = 'signhr' ou 'signPers' // ← Clé 'path' retournée par le nouvel endpoint

      if (signaturePath == null || signaturePath.isEmpty) {
        throw Exception('Le serveur n\'a pas retourné le chemin de signature');
      }

      // 5️⃣ Étape 2 : Mise à jour de la base de données avec le bon endpoint
      final dbResponse = await http.put(
        Uri.parse(dbUpdateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({dbFieldName: signaturePath}),
      );

      if (dbResponse.statusCode != 200) {
        final error = jsonDecode(dbResponse.body)['error'] ?? 'Erreur inconnue';
        throw Exception('Échec mise à jour DB: $error');
      }

      // 6️⃣ ✅ Succès : feedback utilisateur + navigation
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Signature enregistrée avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context, // ✅ 1er argument : le BuildContext actuel
        MaterialPageRoute(
          // ✅ 2ème argument : la route de destination
          builder: (context) =>
              ContractPage(responseModel: widget.responseModel),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSignature = _strokes.isNotEmpty || _currentStroke.length > 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Signature - ${widget.signerName}'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 📋 En-tête informatif
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.signerRole == 'RHO'
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                  child: Text(
                    widget.signerName.isNotEmpty
                        ? widget.signerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.signerRole == 'RHO'
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.signerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.signerRole == 'RHO'
                            ? 'Signe pour l\'employé'
                            : 'Signe en tant que RH',
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
          ),

          // ✍️ Zone de signature optimisée
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerUp,
                child: RepaintBoundary(
                  key: _painterKey,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hasSignature
                            ? Colors.blue.shade400
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        if (!hasSignature)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.edit_note_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Touchez pour signer',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // ✅ CustomPaint avec taille dynamique via LayoutBuilder
                        LayoutBuilder(
                          builder: (context, constraints) => CustomPaint(
                            size: constraints.biggest,
                            painter: SignaturePainter(_strokes, _currentStroke),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🔘 Boutons d'action
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear, size: 20),
                  label: const Text('Effacer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: hasSignature && !_isSubmitting
                      ? _submitSignature
                      : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 20),
                  label: Text(_isSubmitting ? 'Envoi...' : 'Valider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
