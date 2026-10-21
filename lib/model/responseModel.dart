class ResponseModel {
  final bool result;
  final int id;
  final String role;
  final int matricule;
  final String site;
  final String? departement;
  final String nom;
  final String prenom;
  final String mail;
  final String adresse;
  final String Sexe;
  final String matrimoniale;
  final String dateNaissance;
  final String photo;

  ResponseModel({
    required this.result,
    required this.id,
    required this.role,
    required this.matricule,
    required this.site,
    this.departement,
    required this.nom,
    required this.prenom,
    required this.mail,
    required this.adresse,
    required this.Sexe,
    required this.matrimoniale,
    required this.dateNaissance,
    required this.photo,
  });
  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      result: json['result'],
      id: json['id'],
      role: json['role'],
      matricule: json['matricule'],
      site: json['site'],
      departement: json['departement'],
      nom: json['nom'],
      prenom: json['prenom'],
      mail: json['mail'],
      adresse: json['adresse'],
      Sexe: json['Sexe'],
      matrimoniale: json['matrimoniale'],
      dateNaissance: json['dateNaissance'],
      photo: json['photo'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'id': id,
      'role': role,
      'matricule': matricule,
      'site': site,
      'nom': nom,
      'prenom': prenom,
      'mail': mail,
      'adresse': adresse,
      'Sexe': Sexe,
      'matrimoniale': matrimoniale,
      'dateNaissance': dateNaissance,
      'photo': photo,
    };
  }

  factory ResponseModel.error() {
    return ResponseModel(
      result: false,
      id: 0,
      role: '',
      matricule: 0,
      site: '',
      nom: '',
      prenom: '',
      mail: '',
      adresse: '',
      Sexe: '',
      matrimoniale: '',
      dateNaissance: '',
      photo: '',
    );
  }
}
