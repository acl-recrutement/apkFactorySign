class RequisitionModel {
  final double? budget;
  final String targetDate;
  final String departement;
  final String division;
  final int idRequisition;
  final int? nombre;
  final String position;
  final String raison;
  final String section;
  final String? signfm;
  final String? signhod;
  final String? signhr;
  final String? signie;
  final String site;
  final String type;

  RequisitionModel({
    this.budget,
    required this.targetDate,
    required this.departement,
    required this.division,
    required this.idRequisition,
    this.nombre,
    required this.position,
    required this.raison,
    required this.section,
    this.signfm,
    this.signhod,
    this.signhr,
    this.signie,
    required this.site,
    required this.type,
  });

  factory RequisitionModel.fromJson(Map<String, dynamic> json) {
    return RequisitionModel(
      budget: json['budget']?.toDouble(),
      targetDate: json['target_date']?.toString() ?? json['dateDebut']?.toString() ?? '',
      departement: json['departement']?.toString() ?? '',
      division: json['division']?.toString() ?? '',
      idRequisition: json['idRequisition'] ?? 0,
      nombre: json['nombre'],
      position: json['position']?.toString().trim() ?? '',
      raison: json['raison']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      signfm: json['signfm']?.toString(),
      signhod: json['signhod']?.toString(),
      signhr: json['signhr']?.toString(),
      signie: json['signie']?.toString(),
      site: json['site']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budget': budget,
      'target_date': targetDate,
      'departement': departement,
      'division': division,
      'idRequisition': idRequisition,
      'nombre': nombre,
      'position': position,
      'raison': raison,
      'section': section,
      'signfm': signfm,
      'signhod': signhod,
      'signhr': signhr,
      'signie': signie,
      'site': site,
      'type': type,
    };
  }

  /// Titre affiché dans la liste : "Position – Type"
  String get displayTitle {
    return type.isEmpty ? position.trim() : '${position.trim()} – $type';
  }

  /// Statut de signature : retourne une liste des signataires manquants
  List<String> get missingSignatures {
    final missing = <String>[];
    if (signhr == null) missing.add('RH');
    if (signhod == null) missing.add('HOD');
    if (signie == null) missing.add('IE');
    if (signfm == null) missing.add('FM');
    return missing;
  }

  /// Vérifie si le document est entièrement signé
  bool get isFullySigned => missingSignatures.isEmpty;

  /// Formatage de la date cible pour l'affichage (JJ/MM/AAAA)
  String get formattedTargetDate {
    try {
      // Format attendu : "Thu, 01 Jan 2026 00:00:00 GMT"
      final parts = targetDate.split(' ');
      if (parts.length >= 4) {
        final day = parts[1];
        final monthStr = parts[2];
        final year = parts[3];
        final month = _monthToInt(monthStr);
        return '$day/${month.toString().padLeft(2, '0')}/$year';
      }
      return targetDate;
    } catch (_) {
      return targetDate;
    }
  }

  int _monthToInt(String month) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[month] ?? 1;
  }
}
