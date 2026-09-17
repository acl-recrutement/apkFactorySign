class Personnel {
  final int? id;
  final String? nom;
  final String? prenom;
  final String? telephone;
  final String? adresse;
  final String? cin;
  final String? sexe;
  final String? date_naiss;
  Personnel({
    this.id,
    this.nom,
    this.prenom,
    this.telephone,
    this.adresse,
    this.cin,
    this.sexe,
    this.date_naiss,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) => Personnel(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    telephone: json['Telephone'],
    adresse: json['adresse'],
    cin: json['cin'],
    sexe: json['sexe'],
    date_naiss: json['date_naiss'],
    // ❌ matricule n'existe PAS dans perssonel → ne pas le mapper ici
  );
}

class Contract {
  final int? idContract;
  final int? idPers;
  final String? type;
  final String? signhr;
  final String? signPers;
  final String? matricule;
  final String? contenue;
  final double? salaire;
  final String? pdfPath;

  Contract({
    this.idContract,
    this.idPers,
    this.type,
    this.signhr,
    this.signPers,
    this.matricule,
    this.contenue,
    this.salaire,
    this.pdfPath,
  });

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
    idContract: json['idContract'],
    idPers: json['idPers'],
    type: json['type'],
    signhr: json['signhr'],
    signPers: json['signPers'],
    matricule: json['matricule']?.toString(),
    contenue: json['contenue'],
    salaire: json['salaire']?.toDouble(),
    pdfPath: json['pdf_path'],
  );
}

class InfoFactory {
  final String? site;
  final String? departement;
  final String? fonction;
  final String? typeContrat;
  final int? matricule; // ✅ Optionnel : matricule aussi dans InfoFacotry (int)

  InfoFactory({
    this.site,
    this.departement,
    this.fonction,
    this.typeContrat,
    this.matricule,
  });

  factory InfoFactory.fromJson(Map<String, dynamic> json) => InfoFactory(
    site: json['site'],
    departement: json['departement'],
    fonction: json['fonction'],
    typeContrat: json['type_contrat'],
    matricule: json['matricule'],
  );
}

class DossierPersonnel {
  final int? id;
  final int? idPers;
  DossierPersonnel({this.id, this.idPers});
  factory DossierPersonnel.fromJson(Map<String, dynamic> json) =>
      DossierPersonnel(id: json['id'], idPers: json['idPers']);
}

class ContractAccessItem {
  final Personnel? personnel;
  final Contract? contract;
  final InfoFactory? infoFactory;
  final DossierPersonnel? dossier;

  ContractAccessItem({
    this.personnel,
    this.contract,
    this.infoFactory,
    this.dossier,
  });

  factory ContractAccessItem.fromJson(Map<String, dynamic> json) =>
      ContractAccessItem(
        personnel: json['perssonel'] != null
            ? Personnel.fromJson(json['perssonel'])
            : null,
        contract: json['Contract'] != null
            ? Contract.fromJson(json['Contract'])
            : null,
        infoFactory: json['InfoFacotry'] != null
            ? InfoFactory.fromJson(json['InfoFacotry'])
            : null,
        dossier: json['dossierPersonel'] != null
            ? DossierPersonnel.fromJson(json['dossierPersonel'])
            : null,
      );
}
