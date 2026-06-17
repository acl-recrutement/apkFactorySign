// lib/model/mobile_access_response.dart
class MobileAccessResponse {
  final Requisition requisition;
  final MobileAccesReq mobileAccesReq;

  MobileAccessResponse({
    required this.requisition,
    required this.mobileAccesReq,
  });

  factory MobileAccessResponse.fromJson(Map<String, dynamic> json) {
    return MobileAccessResponse(
      requisition: Requisition.fromJson(json['Requisition']),
      mobileAccesReq: MobileAccesReq.fromJson(json['MobileAccesReq']),
    );
  }
}

class Requisition {
  final int idRequisition;
  final String title;
  final String type;
  final String status;
  final String dateCreation;

  Requisition({
    required this.idRequisition,
    required this.title,
    required this.type,
    required this.status,
    required this.dateCreation,
  });

  factory Requisition.fromJson(Map<String, dynamic> json) {
    return Requisition(
      idRequisition: json['idRequisition'],
      title: json['title'] ?? 'Sans titre',
      type: json['type'] ?? '',
      status: json['status'] ?? 'en_attente',
      dateCreation: json['dateCreation'] ?? '',
    );
  }

  // Formatage utile pour l’affichage
  String get formattedDate {
    try {
      final dt = DateTime.parse(dateCreation);
      return '${dt.day}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return dateCreation.split('T')[0].split('-').reversed.join('/');
    }
  }
}

class MobileAccesReq {
  final int idMobile;
  final int idRequisiion;
  final int idUser;
  final String type;

  MobileAccesReq({
    required this.idMobile,
    required this.idRequisiion,
    required this.idUser,
    required this.type,
  });

  factory MobileAccesReq.fromJson(Map<String, dynamic> json) {
    return MobileAccesReq(
      idMobile: json['idMobile'],
      idRequisiion: json['idRequisiion'],
      idUser: json['idUser'],
      type: json['type'],
    );
  }
}
