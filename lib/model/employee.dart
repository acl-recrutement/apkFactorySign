// lib/model/employee.dart
import 'package:flutter/material.dart';

class Employee {
  final int id;
  final String nom;
  final String prenom;
  final String sexe;
  final DateTime? dateNaiss;
  final String cin;
  final DateTime? dateCin;
  final String adresse;
  final String adresseCin;
  final String telephone;
  final String numUrgence;
  final String affiliationUrgence;
  final String situationMatrimoniale;
  final String? enfant; // peut être "0", "2", ou null
  final String numCnaps;

  Employee({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.sexe,
    this.dateNaiss,
    required this.cin,
    this.dateCin,
    required this.adresse,
    required this.adresseCin,
    required this.telephone,
    required this.numUrgence,
    required this.affiliationUrgence,
    required this.situationMatrimoniale,
    this.enfant,
    required this.numCnaps,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      sexe: json['sexe'] ?? '',
      dateNaiss: _parseDate(json['date_naiss']),
      cin: json['cin'] ?? '',
      dateCin: _parseDate(json['date_cin']),
      adresse: json['adresse'] ?? '',
      adresseCin: json['adresse_cin'] ?? '',
      telephone: json['Telephone'] ?? '',
      numUrgence: json['num_urgence'] ?? '',
      affiliationUrgence: json['afiliation_urgence'] ?? '',
      situationMatrimoniale: json['situation_matri'] ?? '',
      enfant: json['enfant'] is String ? json['enfant'] : null,
      numCnaps: json['num_cnaps'] ?? '',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        // Format: "Fri, 14 Jan 2000 00:00:00 GMT"
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String getFullName() => '$prenom $nom';

  String getDisplayDateNaiss() {
    if (dateNaiss == null) return '—';
    return '${dateNaiss!.day}/${dateNaiss!.month}/${dateNaiss!.year}';
  }

  String getSituationBadge() {
    return situationMatrimoniale;
  }

  Color getSexeColor() {
    switch (sexe) {
      case 'Masculin':
        return Colors.blue;
      case 'Féminin':
        return Colors.pink;
      case 'Autre':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color getSituationColor() {
    switch (situationMatrimoniale) {
      case 'Marié(e)':
        return Colors.green;
      case 'Célibataire':
        return Colors.orange;
      case 'Divorcé(e)':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
