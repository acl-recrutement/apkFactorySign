// models/contract_access_model.dart
class ContractAccessModel {
  final AccesContractModel accesContractModel;
  final Contract contract;

  ContractAccessModel({
    required this.accesContractModel,
    required this.contract,
  });

  factory ContractAccessModel.fromJson(Map<String, dynamic> json) {
    return ContractAccessModel(
      accesContractModel: AccesContractModel.fromJson(
        json['AccesContractModel'] as Map<String, dynamic>,
      ),
      contract: Contract.fromJson(json['Contract'] as Map<String, dynamic>),
    );
  }
}

class AccesContractModel {
  final int idAcces;
  final int idContract;
  final int idPers;
  final int idrh;
  final String type;

  AccesContractModel({
    required this.idAcces,
    required this.idContract,
    required this.idPers,
    required this.idrh,
    required this.type,
  });

  factory AccesContractModel.fromJson(Map<String, dynamic> json) {
    return AccesContractModel(
      idAcces: json['idAcces'],
      idContract: json['idContract'],
      idPers: json['idPers'],
      idrh: json['idrh'],
      type: json['type'] ?? '',
    );
  }
}

class Contract {
  final int idContract;
  final int idPers;
  final String type;
  final String matricule;
  final String? contenue;
  final String? signPers;
  final String? signhr;

  Contract({
    required this.idContract,
    required this.idPers,
    required this.type,
    required this.matricule,
    this.contenue,
    this.signPers,
    this.signhr,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      idContract: json['idContract'],
      idPers: json['idPers'],
      type: json['type'] ?? '',
      matricule: json['matricule'] ?? '',
      contenue: json['contenue'],
      signPers: json['signPers'],
      signhr: json['signhr'],
    );
  }
}
