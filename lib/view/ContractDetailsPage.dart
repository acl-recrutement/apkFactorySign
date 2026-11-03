// lib/view/ContractDetailsPage.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ContractDetailsPage extends StatelessWidget {
  final Map<String, dynamic> requisitionData;
  final String signerRole;

  const ContractDetailsPage({
    Key? key,
    required this.requisitionData,
    required this.signerRole,
  }) : super(key: key);

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'CDI':
        return const Color(0xFF2E7D32);
      case 'CDD':
        return const Color(0xFFEF6C00);
      case 'STAGE':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF757575);
    }
  }

  Future<void> _generateAndPrintPDF(BuildContext context) async {
    final pdf = pw.Document();

    final empNo = (requisitionData['matricule'] ?? '–').toString();
    final prenom = (requisitionData['prenom'] ?? '').toString();
    final nom = (requisitionData['nom'] ?? '').toString();
    final fullname = '$prenom $nom'.trim().isEmpty ? 'Employé' : '$prenom $nom';
    final dob = (requisitionData['naissance'] ?? '–').toString();
    final nic = (requisitionData['cin'] ?? '–').toString();
    final adrs = (requisitionData['Adresse'] ?? '–').toString();
    final doe = (requisitionData['target_date'] ?? requisitionData['dateDebut'] ?? '–').toString();
    final occupation = (requisitionData['Fonction'] ?? '–').toString();
    final departement = (requisitionData['Département'] ?? '–').toString();
    final site = (requisitionData['site'] ?? '–').toString();
    final salaire = (requisitionData['salaire'] ?? '–').toString();
    final contractType = requisitionData['type'] ?? 'CDI';

    final page = pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(12),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // --- Header ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Laharana : $empNo',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 7,
                  ),
                ),
                pw.Text(
                  site.toLowerCase() == 'tana' ? 'Antananarivo' : site,
                  style: pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Center(
              child: pw.Text(
                'FIFANEKENA ARAK’ASA MANDRITRY NY FOTOANA TSY VOAFETRA',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7.6,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                '(Contrat à durée indéterminée — CDI)',
                style: pw.TextStyle(fontSize: 5.8, color: PdfColors.grey600),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Ifanaovan’ ny : MPAMPIASA', style: _txt(6.4)),
            pw.Text('Orinasa AQUARELLE MADAGASCAR S.A', style: _txt(6.4)),
            pw.Text(
              'Adiresy : Module 15 Zone Forello Tanjombato Antananarivo',
              style: _txt(6.4),
            ),
            pw.SizedBox(height: 3.5),
            pw.Text(
              'Izay soloin’ny Responsable des Ressources Humaines tana',
              style: _txt(6.4),
            ),
            pw.SizedBox(height: 3.5),
            pw.Text('Andaniny', style: _txt(6.4)),
            pw.SizedBox(height: 2.5),

            // Employee info two columns
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _infoLine('MPIASA', fullname),
                _infoLine('Teraka tamin’ny', dob),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _infoLine('Karapanondro laharana', nic),
                _infoLine('Adiresy', adrs),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _infoLine('Daty nidirana', doe),
                _infoLine('Poste / Département', '$occupation • $departement'),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text('Ankilany', style: _txt(6.4)),
            pw.SizedBox(height: 3),

            // Intro
            pw.Text(
              'Dia manao izao fifanarahana arak’asa izao izay mifanaraka amin’ny lalàna 2003-044 tamin’ny 28 jolajy 2004 mirakitra ny fahezan-dalàna momba ny asa sy ny fampiharana azy.',
              style: _txt(6, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 2.5),
            pw.Text(
              '(Le présent contrat à durée indéterminée est conclu conformément à la loi 2003-044 du 28 juillet 2004.)',
              style: _txt(5.4, color: PdfColors.grey500, italic: true),
            ),
            pw.SizedBox(height: 5),

            // Articles
            ..._articles().map(
              (a) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    a['titleMg'] as String,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 6.4,
                    ),
                  ),
                  pw.SizedBox(height: 1.8),
                  pw.Text(
                    a['titleFr'] as String,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 5.7,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 1.8),
                  pw.Text(a['bodyMg'] as String, style: _txt(6)),
                  pw.SizedBox(height: 1.5),
                  pw.Text(
                    a['bodyFr'] as String,
                    style: _txt(5.4, color: PdfColors.grey500, italic: true),
                  ),
                  pw.SizedBox(height: 4),
                ],
              ),
            ),

            pw.SizedBox(height: 4),
            pw.Text('Natao teto Antananarivo ny $doe', style: _txt(6.2)),
            pw.SizedBox(height: 4),
            pw.Text(
              'Ny andaniny sy ny ankilany dia samy nanaiky fa nahazo dika mitovy',
              style: _txt(6.2),
            ),
            pw.SizedBox(height: 8),

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [_sigBlock('Ny Mpampiasa'), _sigBlock('Ny Mpiasa')],
            ),
          ],
        );
      },
    );

    pdf.addPage(page);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Contrat_$empNo',
    );
  }

  pw.TextStyle _txt(
    double size, {
    PdfColor color = PdfColors.black,
    bool italic = false,
  }) {
    return pw.TextStyle(
      fontSize: size,
      color: color,
      fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal,
    );
  }

  pw.Widget _infoLine(String label, String value) {
    return pw.Expanded(
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label : ',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 6.4,
              ),
            ),
            pw.TextSpan(text: value, style: pw.TextStyle(fontSize: 6.4)),
          ],
        ),
      ),
    );
  }

  pw.Widget _sigBlock(String label) {
    return pw.Column(
      children: [
        pw.Container(
          width: 52,
          height: 16,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.5),
            ),
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
        ),
      ],
    );
  }

  List<Map<String, String>> _articles() {
    final prenom = (requisitionData['prenom'] ?? '').toString();
    final nom = (requisitionData['nom'] ?? '').toString();
    final fullname = '$prenom $nom'.trim().isEmpty ? 'Employé' : '$prenom $nom';
    final occupation = (requisitionData['Fonction'] ?? '–').toString();
    final departement = (requisitionData['Département'] ?? '–').toString();
    final salaire = (requisitionData['salaire'] ?? '–').toString();

    return [
      {
        'titleMg': 'ANDININY 1: MOMBA NY FIFANARAHANA SY NY ANDRANA ASA',
        'titleFr': 'Article 1 : Période d’essai et durée du travail',
        'bodyMg':
            'Manankery mandritra ny fotoana tsy voafetra ity fifanarahana ity miantomboka eo amin’ny fanaovana sonia ny fifanekena arak’asa. Ny andrana asa dia 6 volana. Mandritra ny andran’asa dia azo tapahina ny fifanarahana.',
        'bodyFr':
            'Période d’essai de 6 mois. Durant l’essai, le contrat peut être rompu sans préavis ni indemnité.',
      },
      {
        'titleMg': 'ANDININY 2: TOERANA IASANA',
        'titleFr': 'Article 2 : Lieu de travail',
        'bodyMg':
            'Atoa/Rtoa/Rtoakely $fullname dia mpiasa eto amin’ny Orinasa AQUARELLE MADAGASCAR S.A eto Zone Forello Tanjombato, Module 15.'
                .replaceAll('\$fullname', fullname),
        'bodyFr':
            'Le salarié exerce ses fonctions à l’Orinasa AQUARELLE MADAGASCAR S.A, Zone Forello Tanjombato, Module 15.',
      },
      {
        'titleMg': 'ANDININY 3: ANDRAIKITRA',
        'titleFr': 'Article 3 : Poste et département',
        'bodyMg':
            'Ny asanao $fullname dia $occupation ao amin’ny departemanta $departement.'
                .replaceAll('\$fullname', fullname)
                .replaceAll('\$occupation', occupation)
                .replaceAll('\$departement', departement),
        'bodyFr':
            'Le salarié occupe le poste de $occupation au département $departement.'
                .replaceAll('\$occupation', occupation)
                .replaceAll('\$departement', departement),
      },
      {
        'titleMg': 'ANDININY 4: MARI-KARAMA',
        'titleFr': 'Article 4 : Rémunération',
        'bodyMg':
            'Mandritry ny andran’asa, ny karama nifanarahana dia : $salaire Ariary.'
                .replaceAll('\$salaire', salaire),
        'bodyFr': 'Salaire mensuel brut : $salaire Ariary.'.replaceAll(
          '\$salaire',
          salaire,
        ),
      },
      {
        'titleMg': 'ANDININY 5: ORA FIASANA',
        'titleFr': 'Article 5 : Horaires de travail',
        'bodyMg':
            'Alatsinainy (Lundi)-Zoma (vendredi): 07h 00-16 h 00. 16h 00-18h 00 (supplémentaires). Sabotsy (Samedi): heures supplémentaires.',
        'bodyFr':
            'Lundi-Vendredi 07h00-16h00, 16h00-18h00 supplémentaires. Samedi: heures supplémentaires.',
      },
      {
        'titleMg': 'ANDININY 6: FANDRARANA',
        'titleFr': 'Article 6 : Confidentialité',
        'bodyMg':
            'Ny mpiasa dia tsy mahazo miasa afa tsy amin’ny mpampiasa iray ary tsy mahazo mamoaka ny tsiambaratelon’ny ORINASA (art. 418 du code penal).',
        'bodyFr':
            'Le salarié ne peut travailler pour un autre employeur ni divulguer les secrets de l’Orinasa (art. 418 code pénal).',
      },
      {
        'titleMg': 'ANDININY 7: FAHASALAMANA SY SOSIALY',
        'titleFr': 'Article 7 : Santé et protection sociale',
        'bodyMg':
            'Ny mpiasa dia mahazo fikarakarana sy fanafody ilaina amin’ny fitsaboana ny tenany sy ny fianakaviany. CNaPS selon les fepetra.',
        'bodyFr':
            'Protection sociale et soins selon les œuvres sociales. Cotisation CNaPS selon les conditions légales.',
      },
      {
        'titleMg': 'ANDININY 8: FIALAN-TSASATRA',
        'titleFr': 'Article 8 : Congés payés',
        'bodyMg':
            'Ny mpiasa dia manan-jo hiala sasatra mandritra ny 30 andro isan-taona tontosa.',
        'bodyFr': '30 jours de congé payé par an (2,5 jours par mois).',
      },
      {
        'titleMg': 'ANDININY 9: FITSAHARAN’NY FIFANARAHANA',
        'titleFr': 'Article 9 : Rupture du contrat',
        'bodyMg':
            'Ny fitsaharan’ny fifanarahana amin’ny fotoana tsy voafetra dia tsy maintsy manaraka ny fepetra DECRET 2007 009 du 09 janvier 2007.',
        'bodyFr':
            'Rupture du CDI conforme au Décret 2007-009 du 09 janvier 2007.',
      },
      {
        'titleMg': 'ANDININY 10: FITSIPIKA ANATINY',
        'titleFr': 'Article 10 : Règlement intérieur',
        'bodyMg':
            'Izaho mpiasa dia manaiky fa efa namaky sy mahafantatra ny fitsipika anatiny (RI) an’ny orinasa.',
        'bodyFr':
            'Le salarié déclare connaître le règlement intérieur de l’Orinasa.',
      },
      {
        'titleMg': 'ANDININY 11: FANEKENA AN-KALALAHANA',
        'titleFr': 'Article 11 : Exclusivité',
        'bodyMg':
            'Izaho mpiasa dia manaiky fa ankalalahana tanteraka no hidirako miasa ato amin’ny orinasa Aquarelle Antananarivo.',
        'bodyFr':
            'Le salarié déclare travailler exclusivement à l’Orinasa Aquarelle Antananarivo.',
      },
      {
        'titleMg': 'ANDININY 12: FANITSIANA',
        'titleFr': 'Article 12 : Litiges',
        'bodyMg':
            'Ity fifanarahana ity dia azo ahitsy araka ny fifanarahana misy eo amin’ny roa tonta.',
        'bodyFr':
            'Le contrat est soumis aux juridictions compétentes à Antananarivo.',
      },
      {
        'titleMg': 'ANDININY 13: FIFANOLANANA',
        'titleFr': 'Article 13 : Dispositions diverses',
        'bodyMg':
            'Izay fifanolanana tsy hita ao anatin’ity fifanarahana ity, dia ho arovana amin’ny lalana manan-kery eto MADAGASIKARA.',
        'bodyFr':
            'Les dispositions non prévues sont réglées d’un commun accord selon la législation malagasy.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final employeeName =
        '${requisitionData['prenom']} ${requisitionData['nom']}'.trim();
    final contractType = requisitionData['type'] ?? 'CDI';
    final salaire = requisitionData['salaire'] ?? '–';
    final site = requisitionData['site'] ?? '–';

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
            const Text(
              'Détails du contrat',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        surfaceTintColor: const Color(0xFF1565C0),
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            tooltip: 'Télécharger en PDF',
            onPressed: () => _generateAndPrintPDF(context),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF1565C0).withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF1565C0).withOpacity(0.15),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/icon/logo.jpg',
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.business,
                                    size: 40,
                                    color: const Color(0xFF1565C0),
                                  ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'AQUARELLE MADAGASCAR',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: const Color(0xFF1565C0),
                          ),
                        ),
                        Text(
                          'Code du Travail Malagasy • Loi 2024-14',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF757575),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(
                                contractType,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _getTypeColor(contractType),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'CONTRAT DE TRAVAIL — $contractType',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: _getTypeColor(contractType),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildInfoCard(
                          title: '📄 SALARIÉ',
                          children: [
                            _buildInfoRow('Nom complet', employeeName),
                            _buildInfoRow(
                              'Matricule',
                              requisitionData['matricule'],
                            ),
                            _buildInfoRow('CIN', requisitionData['cin']),
                            _buildInfoRow(
                              'Date de naissance',
                              requisitionData['naissance'],
                            ),
                            _buildInfoRow(
                              'Adresse',
                              requisitionData['Adresse'],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildInfoCard(
                          title: '💼 POSTE & AFFECTATION',
                          children: [
                            _buildInfoRow(
                              'Fonction',
                              requisitionData['Fonction'],
                            ),
                            _buildInfoRow(
                              'Département',
                              requisitionData['Département'],
                            ),
                            _buildInfoRow('Site', site),
                            _buildInfoRow('Type de contrat', contractType),
                            _buildInfoRow(
                              'Salaire mensuel brut',
                              '$salaire Ariary',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'CLAUSES CONTRACTUELLES',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF37474F),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildArticle(
                          number: 1,
                          title: 'Objet',
                          content:
                              'Le présent contrat est conclu pour une durée indéterminée.',
                        ),
                        _buildArticle(
                          number: 2,
                          title: 'Période d\'essai',
                          content:
                              'Une période d\'essai de 1 mois est prévue, renouvelable une fois. Elle peut être rompue sans indemnité avec un préavis de 48 heures.',
                        ),
                        _buildArticle(
                          number: 3,
                          title: 'Lieu de travail',
                          content:
                              'Le salarié exercera ses fonctions à $site, avec possibilité d\'affectation selon les besoins de l\'entreprise. Selon les besoins de production, il pourra être affecté à d\'autres tâches ou départements.',
                        ),
                        _buildArticle(
                          number: 4,
                          title: 'Durée du travail',
                          content:
                              'La durée de travail est fixée à 40 heures par semaine. Les heures supplémentaires seront rémunérées conformément à la législation en vigueur.',
                        ),
                        _buildArticle(
                          number: 5,
                          title: 'Rémunération',
                          content:
                              'Le salarié percevra un salaire mensuel brut de $salaire Ariary. Le paiement s\'effectuera mensuellement.',
                        ),
                        _buildArticle(
                          number: 6,
                          title: 'Congés',
                          content:
                              'Le salarié bénéficie de congés payés conformément à la législation en vigueur (2,5 jours par mois de travail effectif).',
                        ),
                        _buildArticle(
                          number: 7,
                          title: 'Rupture',
                          content:
                              'Le contrat peut être rompu par l\'une ou l\'autre des parties dans le respect du préavis prévu par la loi et la convention collective applicable.',
                        ),
                        _buildArticle(
                          number: 8,
                          title: 'Règlement intérieur',
                          content:
                              'Le salarié s\'engage à respecter le règlement intérieur de l\'entreprise.',
                        ),
                        _buildArticle(
                          number: 9,
                          title: 'Litiges',
                          content:
                              'Tout litige relatif à l\'exécution du présent contrat sera réglé conformément aux lois en vigueur à Madagascar.',
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✍️ Signatures',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF37474F),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSignaturePlaceholder(
                                    'Employé',
                                    const Color(0xFF2E7D32),
                                  ),
                                  _buildSignaturePlaceholder(
                                    'Responsable RH',
                                    const Color(0xFF1565C0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(18),
                      ),
                      border: Border(
                        top: BorderSide(color: const Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: const Color(0xFF757575),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Document confidentiel • Généré le ${DateTime.now().toString().split(' ')[0]}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF757575),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Retour'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateAndPrintPDF(context),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF37474F),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
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
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '–',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticle({
    required int number,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Article $number — $title',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF424242),
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePlaceholder(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.05),
          ),
          child: Center(
            child: Text(
              'Signature\n$label',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
