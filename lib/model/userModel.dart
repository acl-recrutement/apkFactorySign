class Usermodel {
  final String identifier;
  final String password;

  Usermodel({required this.identifier, required this.password});

  factory Usermodel.fromJson(Map<String, dynamic> json) {
    return Usermodel(
      identifier: json['identifier'] ?? json['mail'] ?? '',
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    final isUsername = RegExp(r'^(AMAT|AMAA|LMAA)\d+$', caseSensitive: false).hasMatch(identifier);
    return {
      if (isUsername) 'username': identifier else 'mail': identifier,
      'mdp': password,
    };
  }
}