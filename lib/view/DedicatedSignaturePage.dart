// lib/view/dedicated_signature_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pdf/widgets.dart' as pw;
import '../config/config.dart';
import '../model/responseModel.dart';
import 'widgets/signature_painter.dart';
import 'contractPage.dart';

class StrokePoint {
  final Offset offset;
  final double pressure;
  const StrokePoint(this.offset, this.pressure);
}

class DedicatedSignaturePage extends StatefulWidget {
  final ResponseModel responseModel;
  final Map<String, dynamic> requisitionData;
  final String signerName;
  final String signerRole;

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

  Future<Uint8List?> _captureSignature() async {
    final boundary =
        _painterKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final completer = Completer<Uint8List?>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        completer.complete(byteData?.buffer.asUint8List());
      } catch (e) {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  Future<Uint8List> _generateContractPdf(Uint8List signatureBytes) async {
    try {
      final pdf = pw.Document();
      final data = widget.requisitionData;
      final employeeName = '${data['prenom'] ?? ''} ${data['nom'] ?? ''}'
          .trim();
      final contractType = data['type'] ?? 'CDI';
      final salaire = data['salaire'] ?? '–';
      final site = data['site'] ?? '–';
      final fonction = data['Fonction'] ?? data['fonction'] ?? '—';
      final departement = data['Département'] ?? data['departement'] ?? '—';
      final matricule = data['matricule']?.toString() ?? '—';
      final cin = data['cin'] ?? '—';
      final dateNaissance = data['naissance'] ?? data['date_naiss'] ?? '—';
      final adresse = data['Adresse'] ?? data['adresse'] ?? '—';

      final Uint8List rawSignatureBytes = await _decodePngToRaw(signatureBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'AQUARELLE MADAGASCAR',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Contrat de Travail — $contractType',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Divider(),
              pw.Text('Employé : $employeeName'),
              pw.Text('Matricule : $matricule'),
              pw.Text('CIN : $cin'),
              pw.Text('Date de naissance : $dateNaissance'),
              pw.Text('Adresse : $adresse'),
              pw.Text('Fonction : $fonction'),
              pw.Text('Département : $departement'),
              pw.Text('Site : $site'),
              pw.Text('Salaire mensuel brut : $salaire Ariary'),
              pw.SizedBox(height: 20),
              pw.Text(
                'CLAUSES CONTRACTUELLES',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                "Article 1 — Objet\nLe présent contrat est conclu pour une durée indéterminée.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 2 — Période d'essai\nUne période d'essai de 1 mois est prévue, renouvelable une fois. Elle peut être rompue sans indemnité avec un préavis de 48 heures.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 3 — Lieu de travail\nLe salarié exercera ses fonctions à $site, avec possibilité d'affectation selon les besoins de l'entreprise.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 4 — Durée du travail\nLa durée de travail est fixée à 40 heures par semaine.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 5 — Rémunération\nLe salarié percevra un salaire mensuel brut de $salaire Ariary.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 6 — Congés\nLe salarié bénéficie de congés payés conformément à la législation en vigueur.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 7 — Rupture\nLe contrat peut être rompu par l'une ou l'autre des parties dans le respect du préavis.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 8 — Règlement intérieur\nLe salarié s'engage à respecter le règlement intérieur de l'entreprise.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 9 — Litiges\nTout litige relatif à l'exécution du présent contrat sera réglé conformément aux lois en vigueur à Madagascar.",
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'SIGNATURE',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Image(
                pw.MemoryImage(rawSignatureBytes),
                width: 200,
                height: 100,
              ),
            ],
          ),
        ),
      );

      return pdf.save();
    } catch (e) {
      throw Exception('Échec génération PDF: $e');
    }
  }

  Future<Uint8List> _decodePngToRaw(Uint8List pngBytes) async {
    final codec = await ui.instantiateImageCodec(pngBytes);
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List?> _fetchSignatureFromSupabase(
    int idContract,
    String role,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${apiConfig.baseUrl}/api/contract/signed/pdf/$idContract'),
      );
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final signPath = role == 'rh' ? data['signhr'] : data['signPers'];

      if (signPath == null || signPath.isEmpty) return null;

      final url =
          'https://fphepafdcqtytdsjddpz.supabase.co/storage/v1/object/dossiers-personnel/$signPath';
      final imgResponse = await http.get(Uri.parse(url));
      if (imgResponse.statusCode != 200) return null;

      return imgResponse.bodyBytes;
    } catch (e) {
      print('⚠️ Erreur recuperation signature $role: $e');
      return null;
    }
  }

  Future<Uint8List> _generateContractPdfWithBothSignatures({
    required Uint8List currentSignatureBytes,
    Uint8List? otherSignatureBytes,
    required String currentSignerRole,
  }) async {
    try {
      final pdf = pw.Document();
      final data = widget.requisitionData;
      final employeeName = '${data['prenom'] ?? ''} ${data['nom'] ?? ''}'
          .trim();
      final contractType = data['type'] ?? 'CDI';
      final salaire = data['salaire'] ?? '–';
      final site = data['site'] ?? '–';
      final fonction = data['Fonction'] ?? data['fonction'] ?? '—';
      final departement = data['Département'] ?? data['departement'] ?? '—';
      final matricule = data['matricule']?.toString() ?? '—';
      final cin = data['cin'] ?? '—';
      final dateNaissance = data['naissance'] ?? data['date_naiss'] ?? '—';
      final adresse = data['Adresse'] ?? data['adresse'] ?? '—';

      final Uint8List rawCurrentBytes = await _decodePngToRaw(
        currentSignatureBytes,
      );
      Uint8List? rawOtherBytes;
      if (otherSignatureBytes != null) {
        rawOtherBytes = await _decodePngToRaw(otherSignatureBytes);
      }

      final bool isEmployeeSigning = currentSignerRole == 'employe';
      final Uint8List empBytes = isEmployeeSigning
          ? rawCurrentBytes
          : (rawOtherBytes ?? rawCurrentBytes);
      final Uint8List rhBytes = isEmployeeSigning
          ? (rawOtherBytes ?? rawCurrentBytes)
          : rawCurrentBytes;

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'AQUARELLE MADAGASCAR',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Contrat de Travail — $contractType',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Divider(),
              pw.Text('Employé : $employeeName'),
              pw.Text('Matricule : $matricule'),
              pw.Text('CIN : $cin'),
              pw.Text('Date de naissance : $dateNaissance'),
              pw.Text('Adresse : $adresse'),
              pw.Text('Fonction : $fonction'),
              pw.Text('Département : $departement'),
              pw.Text('Site : $site'),
              pw.Text('Salaire mensuel brut : $salaire Ariary'),
              pw.SizedBox(height: 20),
              pw.Text(
                'CLAUSES CONTRACTUELLES',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                "Article 1 — Objet\nLe présent contrat est conclu pour une durée indéterminée.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 2 — Période d'essai\nUne période d'essai de 1 mois est prévue, renouvelable une fois. Elle peut être rompue sans indemnité avec un préavis de 48 heures.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 3 — Lieu de travail\nLe salarié exercera ses fonctions à $site, avec possibilité d'affectation selon les besoins de l'entreprise.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 4 — Durée du travail\nLa durée de travail est fixée à 40 heures par semaine.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 5 — Rémunération\nLe salarié percevra un salaire mensuel brut de $salaire Ariary.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 6 — Congés\nLe salarié bénéficie de congés payés conformément à la législation en vigueur.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 7 — Rupture\nLe contrat peut être rompu par l'une ou l'autre des parties dans le respect du préavis.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 8 — Règlement intérieur\nLe salarié s'engage à respecter le règlement intérieur de l'entreprise.",
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Article 9 — Litiges\nTout litige relatif à l'exécution du présent contrat sera réglé conformément aux lois en vigueur à Madagascar.",
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'SIGNATURE',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Text('Employé', style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Image(
                          pw.MemoryImage(empBytes),
                          width: 200,
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.SizedBox(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Responsable RH',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Image(
                          pw.MemoryImage(rhBytes),
                          width: 200,
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      return pdf.save();
    } catch (e) {
      throw Exception('Échec génération PDF: $e');
    }
  }

  Future<void> _submitSignature() async {
    if (_strokes.isEmpty && _currentStroke.length < 2) {
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
      if (bytes == null || bytes.isEmpty)
        throw Exception('Échec de la capture');

      final idContract = widget.requisitionData['idRequisition'];

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
        throw Exception('Échec upload Supabase: $error');
      }

      final uploadResult = jsonDecode(uploadResponse.body);
      final signaturePath = uploadResult[dbFieldName];

      if (signaturePath == null || signaturePath.isEmpty) {
        throw Exception('Le serveur n\'a pas retourné le chemin de signature');
      }

      final dbResponse = await http.put(
        Uri.parse(dbUpdateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({dbFieldName: signaturePath}),
      );

      if (dbResponse.statusCode != 200) {
        final error = jsonDecode(dbResponse.body)['error'] ?? 'Erreur inconnue';
        throw Exception('Échec mise à jour DB: $error');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Signature enregistrée avec succès'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      );

      // Generer le PDF avec les deux signatures (actuelle + existante)
      try {
        // Recuperer la signature de l'autre signataire si elle existe
        Uint8List? otherSignatureBytes;
        if (!isRH) {
          otherSignatureBytes = await _fetchSignatureFromSupabase(
            idContract,
            'rh',
          );
        } else {
          otherSignatureBytes = await _fetchSignatureFromSupabase(
            idContract,
            'employe',
          );
        }

        final pdfBytes = await _generateContractPdfWithBothSignatures(
          currentSignatureBytes: bytes,
          otherSignatureBytes: otherSignatureBytes,
          currentSignerRole: isRH ? 'rh' : 'employe',
        );

        if (pdfBytes.isEmpty || pdfBytes.length < 100) {
          throw Exception('PDF genere vide ou trop petit');
        }
        print('PDF genere: ${pdfBytes.length} bytes');

        final pdfUploadUrl = Uri.parse(
          '${apiConfig.baseUrl}/api/contract/upload/pdf/signed/$idContract',
        );
        final pdfRequest = http.MultipartRequest('POST', pdfUploadUrl);
        pdfRequest.files.add(
          http.MultipartFile.fromBytes(
            'file',
            pdfBytes,
            filename: 'contrat_signature_$idContract.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        );

        final pdfResponse = await http.Response.fromStream(
          await pdfRequest.send().timeout(const Duration(seconds: 30)),
        );

        if (pdfResponse.statusCode != 200) {
          final errorBody = pdfResponse.body;
          print('Erreur upload PDF: $errorBody');
          final error = jsonDecode(errorBody)['error'] ?? 'Erreur inconnue';
          throw Exception('Echec upload PDF: $error');
        }

        final pdfResult = jsonDecode(pdfResponse.body);
        print('PDF uploade: ${pdfResult['path']}');
      } catch (e) {
        print('Erreur generation/upload PDF: ${e.toString()}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur envoi PDF: ${e.toString()}'),
            backgroundColor: const Color(0xFFF57C00),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ContractPage(responseModel: widget.responseModel),
        ),
      );
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
    final hasSignature = _strokes.isNotEmpty || _currentStroke.length > 1;

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
                    return Icon(Icons.business, size: 18, color: Colors.white);
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
                              children: const [
                                Icon(
                                  Icons.edit_note_outlined,
                                  size: 48,
                                  color: Color(0xFFBDBDBD),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Touchez pour signer',
                                  style: TextStyle(
                                    color: Color(0xFF757575),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  label: const Text('Effacer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
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
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(_isSubmitting ? 'Envoi...' : 'Valider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(130, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
