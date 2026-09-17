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
                'Contrat de Travail — ${requisitionData['type'] ?? 'CDI'}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Divider(),
            pw.Text(
              'Employé : ${requisitionData['prenom']} ${requisitionData['nom']}',
            ),
            pw.Text('Matricule : ${requisitionData['matricule']}'),
            pw.Text('Fonction : ${requisitionData['Fonction']}'),
            pw.Text('Département : ${requisitionData['Département']}'),
            pw.SizedBox(height: 20),
            pw.Text(
              'CONTENU DU CONTRAT...',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                            ),
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
