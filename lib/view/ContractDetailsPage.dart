// lib/view/ContractDetailsPage.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ContractDetailsPage extends StatelessWidget {
  final Map<String, dynamic> requisitionData;
  final String signerRole; // 'RH' ou 'RHO'

  const ContractDetailsPage({
    Key? key,
    required this.requisitionData,
    required this.signerRole,
  }) : super(key: key);

  // 🎨 Helper : Couleur selon le type de contrat
  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'CDI':
        return Colors.green.shade700;
      case 'CDD':
        return Colors.orange.shade700;
      case 'STAGE':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // 📄 Génération du PDF (optionnel - à activer si besoin)
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
            // TODO: Ajouter ici le contenu complet des articles
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
    // 📋 Extraction des données
    final employeeName =
        '${requisitionData['prenom']} ${requisitionData['nom']}'.trim();
    final contractType = requisitionData['type'] ?? 'CDI';
    final salaire = requisitionData['salaire'] ?? '–';
    final site = requisitionData['site'] ?? '–';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du contrat'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        actions: [
          // 🖨️ Bouton Télécharger PDF (optionnel)
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'Télécharger en PDF',
            onPressed: () => _generateAndPrintPDF(context),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 📄 FEUILLE DE CONTRAT (style papier)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 🏢 EN-TÊTE AVEC LOGO
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Colors.blue.shade200),
                      ),
                    ),
                    child: Column(
                      children: [
                        // 🖼️ LOGO — À REMPLACER PAR TON FICHIER
                        // 👇 EMPLACEMENT DU LOGO 👇
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/logo_aquarelle.jpeg',
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.business,
                                    size: 40,
                                    color: Colors.blue.shade400,
                                  ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'AQUARELLE MADAGASCAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          'Code du Travail Malagasy • Loi 2024-14',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 📋 CORPS DU CONTRAT
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre principal
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(
                                contractType,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getTypeColor(contractType),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'CONTRAT DE TRAVAIL — $contractType',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _getTypeColor(contractType),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 👤 Carte employé
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

                        // 💼 Carte poste
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

                        // 📜 Articles du contrat (statiques)
                        const Text(
                          'CLAUSES CONTRACTUELLES',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blueGrey,
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

                        // ✍️ Zone de signature (indicative)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✍️ Signatures',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSignaturePlaceholder(
                                    'Employé',
                                    Colors.green,
                                  ),
                                  _buildSignaturePlaceholder(
                                    'Responsable RH',
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🦶 PIED DE PAGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Document confidentiel • Généré le ${DateTime.now().toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
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

            // 🔘 Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Retour'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateAndPrintPDF(context),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  // 🧱 Widget : Carte d'information
  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey.shade800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // 📋 Widget : Ligne d'information
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
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
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📜 Widget : Article du contrat
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
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // ✍️ Widget : Placeholder de signature
  Widget _buildSignaturePlaceholder(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.5),
              style: BorderStyle.solid,
            ),
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
