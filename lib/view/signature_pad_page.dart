// lib/view/signature_pad_page.dart
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
import 'widgets/stroke_point.dart';

class SignaturePadPage extends StatefulWidget {
  final ResponseModel responseModel;
  final RequisitionModel requisitionData;
  final String signerName;
  final String signerRole;

  const SignaturePadPage({
    Key? key,
    required this.responseModel,
    required this.requisitionData,
    required this.signerName,
    required this.signerRole,
  }) : super(key: key);

  @override
  State<SignaturePadPage> createState() => _SignaturePadPageState();
}

class _SignaturePadPageState extends State<SignaturePadPage> {
  final GlobalKey _painterKey = GlobalKey();
  final List<List<StrokePoint>> _strokes = [];
  final List<StrokePoint> _currentStroke = [];
  bool _isSubmitting = false;

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

  Future<Uint8List?> _captureSignature() async {
    final boundary =
        _painterKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _submitSignature() async {
    if (_strokes.isEmpty && _currentStroke.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez signer avant de valider'),
          backgroundColor: Color(0xFFF57C00),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bytes = await _captureSignature();
      if (bytes == null) throw Exception('Échec de la capture');

      final idContract = widget.requisitionData.idRequisition;
      final isRH = widget.responseModel.role == 'RH';
      final signerRoleParam = isRH ? 'rh' : 'employe';
      final dbFieldName = isRH ? 'signhr' : 'signPers';
      final dbUpdateUrl = isRH
          ? '${apiConfig.baseUrl}/api/contract/update/sign/hr/$idContract'
          : '${apiConfig.baseUrl}/api/contract/update/sign/pers/$idContract';

      final uploadUrl = Uri.parse(
        '${apiConfig.baseUrl}/api/sendImage/signature/contract/single/$idContract',
      );
      final uploadRequest = http.MultipartRequest('POST', uploadUrl);

      uploadRequest.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'signature_${signerRoleParam}_$idContract.png',
          contentType: MediaType('image', 'png'),
        ),
      );
      uploadRequest.fields['signer_role'] = signerRoleParam;

      final uploadResponse = await http.Response.fromStream(
        await uploadRequest.send(),
      );
      if (uploadResponse.statusCode != 200) {
        final error =
            jsonDecode(uploadResponse.body)['error'] ?? 'Erreur inconnue';
        throw Exception('Échec upload: $error');
      }

      final uploadResult = jsonDecode(uploadResponse.body);
      final signaturePath = uploadResult[dbFieldName] ?? uploadResult['path'];

      if (signaturePath == null || signaturePath.isEmpty) {
        throw Exception('Chemin de signature non retourné');
      }

      final dbResponse = await http.put(
        Uri.parse(dbUpdateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({dbFieldName: signaturePath}),
      );

      if (dbResponse.statusCode != 200) {
        final error = jsonDecode(dbResponse.body)['error'] ?? 'Erreur DB';
        throw Exception('Échec DB: $error');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Signature enregistrée'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString()}'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSignature = _strokes.isNotEmpty || _currentStroke.length > 2;

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
            Text(
              'Signature - ${widget.signerName}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        surfaceTintColor: const Color(0xFF1565C0),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE3F2FD),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: widget.signerRole == 'RHO'
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFE3F2FD),
                  child: Text(
                    widget.signerName.isNotEmpty
                        ? widget.signerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: widget.signerRole == 'RHO'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF1565C0),
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
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        widget.signerRole == 'RHO'
                            ? 'Signe pour l\'employé'
                            : 'Signe en tant que RH',
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
          ),

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
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFE0E0E0),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
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
                                  color: const Color(0xFFBDBDBD),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Signez ici avec votre doigt ou un stylet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF757575),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '✏️ La pression du stylet est prise en compte',
                                  style: TextStyle(
                                    color: const Color(0xFFBDBDBD),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
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

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  label: const Text('Effacer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
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
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(_isSubmitting ? 'Envoi...' : 'Valider la signature'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size(160, 50),
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
      ..color = const Color(0xFF1565C0)
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
