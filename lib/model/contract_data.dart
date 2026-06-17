// lib/models/contract_data.dart
class ContractData {
  final String? contenue;
  final int? idContract;
  final int? idPers;
  final String? matricule;
  final String? signPers;
  final String? signhr;
  final String? type;

  ContractData({
    this.contenue,
    this.idContract,
    this.idPers,
    this.matricule,
    this.signPers,
    this.signhr,
    this.type,
  });

  factory ContractData.fromJson(Map<String, dynamic> json) {
    return ContractData(
      contenue: json['contenue']?.toString(),
      idContract: _toInt(json['idContract']),
      idPers: _toInt(json['idPers']),
      matricule: json['matricule']?.toString(),
      signPers: json['signPers']?.toString(),
      signhr: json['signhr']?.toString(),
      type: json['type']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class AccessData {
  final int? idAcces;
  final int? idContract;
  final int? idPers;
  final int? idrh;
  final String? type;

  AccessData({
    this.idAcces,
    this.idContract,
    this.idPers,
    this.idrh,
    this.type,
  });

  factory AccessData.fromJson(Map<String, dynamic> json) {
    return AccessData(
      idAcces: ContractData._toInt(json['idAcces']),
      idContract: ContractData._toInt(json['idContract']),
      idPers: ContractData._toInt(json['idPers']),
      idrh: ContractData._toInt(json['idrh']),
      type: json['type']?.toString(),
    );
  }
}
