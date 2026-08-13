// lib/view/signature_pad_detail_page.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:myapp/config/config.dart';
import 'package:myapp/model/requisition_model.dart';
import 'package:myapp/model/responseModel.dart';
import 'widgets/stroke_point.dart'; // ✅ Même widget partagé
import 'signaturePage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SignaturePadDetailPage extends StatefulWidget {
  final ResponseModel responseModel;
  final RequisitionModel requisitionData;
  final String signerName;
  final String signerRole; // 'HOD', 'RH', 'FM', ou 'IE'

  const SignaturePadDetailPage({
    Key? key,
    required this.responseModel,
    required this.requisitionData,
    required this.signerName,
    required this.signerRole,
  }) : super(key: key);

  @override
  State<SignaturePadDetailPage> createState() => _SignaturePadDetailPageState();
}

class _SignaturePadDetailPageState extends State<SignaturePadDetailPage> {
  final GlobalKey _painterKey = GlobalKey();
  final List<List<StrokePoint>> _strokes = [];
  final List<StrokePoint> _currentStroke = [];
  bool _isSubmitting = false;

  // ─────── Gestion tactile & stylet (identique à l'original) ───────
  void _onPointerDown(PointerDownEvent event) {
    final box = _painterKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    setState(() {
      _currentStroke.clear();
      _currentStroke.add(
        StrokePoint(box.globalToLocal(event.position), event.pressure),
      );
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    final box = _painterKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    setState(() {
      _currentStroke.add(
        StrokePoint(box.globalToLocal(event.position), event.pressure),
      );
    });
  }

  void _onPointerUp(PointerEvent event) {
    if (_currentStroke.length > 2) {
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

  IO.Socket socket = IO.io(
    apiConfig.baseUrl,
    IO.OptionBuilder().setTransports(['websocket']).enableAutoConnect().build(),
  );
  // ─────── 🎯 NOUVELLE LOGIQUE D'ENVOI (adaptée à tes endpoints) ───────
  Future<void> _submitSignature() async {
    if (_strokes.isEmpty && _currentStroke.length < 3) {
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
      // 1️⃣ Capture de la signature
      final bytes = await _captureSignature();
      if (bytes == null) throw Exception('Échec de la capture de la signature');

      // 2️⃣ Préparation des données
      final idReq = widget.requisitionData.idRequisition;
      final idUser = widget.responseModel.id;
      final role = widget.signerRole.toUpperCase(); // HOD, RH, FM, IE
      final fileName = '${idReq}${role}${idUser}.png'; // ✅ Format demandé

      // 3️⃣ 📤 Upload vers Supabase via ton endpoint
      final uploadUrl = Uri.parse(
        '${apiConfig.baseUrl}/api/sendimage/signature',
      );
      final uploadRequest = http.MultipartRequest('POST', uploadUrl);

      uploadRequest.files.add(
        http.MultipartFile.fromBytes(
          'file', // Champ attendu par ton backend
          bytes,
          filename: fileName,
          contentType: MediaType('image', 'png'),
        ),
      );

      final uploadResponse = await http.Response.fromStream(
        await uploadRequest.send(),
      );

      if (uploadResponse.statusCode != 201) {
        final error =
            jsonDecode(uploadResponse.body)['error'] ?? 'Erreur upload';
        throw Exception('Échec upload Supabase: $error');
      }

      // 4️⃣ 🗄️ Mise à jour de la base de données avec le nom du fichier
      final dbUrl = Uri.parse(
        '${apiConfig.baseUrl}/api/requisition/update/sign/$idReq',
      );
      final dbResponse = await http.put(
        dbUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': role, // HOD, RH, FM, ou IE
          'filename': fileName, // Nom exact stocké dans Supabase
        }),
      );

      if (dbResponse.statusCode != 200) {
        final body = jsonDecode(dbResponse.body);
        final error = body is Map ? (body['error'] ?? 'Erreur DB') : 'Erreur DB';
        throw Exception('Échec mise à jour DB: $error');
      }

      // 5️⃣ ✅ Succès : feedback + retour
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Signature enregistrée avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      socket.emit('signature_updated', {'idRequisition': idReq, 'role': role});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SignaturePage(responseModel: widget.responseModel),
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

  // ─────── UI (identique à SignaturePadPage, juste le titre change) ───────
  @override
  Widget build(BuildContext context) {
    final hasSignature = _strokes.isNotEmpty || _currentStroke.length > 2;

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
          // En-tête signataire
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    widget.signerName.isNotEmpty
                        ? widget.signerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
                        'Rôle: ${widget.signerRole.toUpperCase()}',
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

          // Zone de signature
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (!hasSignature)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_note_outlined,
                                  size: 56,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Signez ici avec votre doigt ou un stylet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        LayoutBuilder(
                          builder: (context, constraints) => CustomPaint(
                            size: constraints.biggest,
                            painter: _SignaturePainter(
                              _strokes,
                              _currentStroke,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Boutons d'action
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear, size: 20),
                  label: const Text('Effacer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
                const Spacer(),
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
                  label: Text(
                    _isSubmitting ? 'Envoi...' : 'Valider la signature',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(140, 50),
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

// ─────────────────────────────────────────────
// 🎨 SignaturePainter (identique à l'original)
// ─────────────────────────────────────────────
class _SignaturePainter extends CustomPainter {
  final List<List<StrokePoint>> strokes;
  final List<StrokePoint> currentStroke;

  _SignaturePainter(this.strokes, this.currentStroke);

  double _calculateWidth(StrokePoint p1, StrokePoint p2, StrokePoint p3) {
    final pressure = p2.pressure.clamp(0.0, 1.0);
    final speed =
        ((p2.offset - p1.offset).distance + (p3.offset - p2.offset).distance) /
        2;
    final speedFactor = (speed / 40).clamp(0.0, 1.0);
    final dynamicFactor = (pressure * 0.7) + (speedFactor * 0.3);
    return 2.0 + 5.0 * (1 - dynamicFactor);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A237E)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    void drawStroke(List<StrokePoint> points) {
      if (points.length < 2) return;
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1], curr = points[i];
        final next = i < points.length - 1 ? points[i + 1] : points[i];
        paint.strokeWidth = _calculateWidth(prev, curr, next);
        canvas.drawLine(prev.offset, curr.offset, paint);
      }
    }

    for (final stroke in strokes) drawStroke(stroke);
    if (currentStroke.length > 1) drawStroke(currentStroke);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter old) =>
      old.strokes != strokes || old.currentStroke != currentStroke;
}
