class ConditionMeteo {
  int? idMeteo;
  DateTime? dateReleve;
  double? temperature;
  double? humidite;
  double? vitesseVent;
  String? directionVent;
  double? pressionAtmospherique;
  String? precipitation;
  String? visibilite;
  String? etatGeneral;

  ConditionMeteo({
    this.idMeteo,
    this.dateReleve,
    this.temperature,
    this.humidite,
    this.vitesseVent,
    this.directionVent,
    this.pressionAtmospherique,
    this.precipitation,
    this.visibilite,
    this.etatGeneral,
  });

  Map<String, dynamic> toMap() {
    return {
      'date_releve': dateReleve?.toIso8601String(),
      'temperature': temperature,
      'humidite': humidite,
      'vitesse_vent': vitesseVent,
      'direction_vent': directionVent,
      'pression_atmospherique': pressionAtmospherique,
      'precipitation': precipitation,
      'visibilite': visibilite,
      'etat_general': etatGeneral,
    };
  }

  factory ConditionMeteo.fromMap(Map<String, dynamic> map) {
    return ConditionMeteo(
      idMeteo: map['id_meteo'],
      dateReleve: map['date_releve'] != null ? DateTime.parse(map['date_releve']) : null,
      temperature: map['temperature'],
      humidite: map['humidite'],
      vitesseVent: map['vitesse_vent'],
      directionVent: map['direction_vent'],
      pressionAtmospherique: map['pression_atmospherique'],
      precipitation: map['precipitation'],
      visibilite: map['visibilite'],
      etatGeneral: map['etat_general'],
    );
  }
}