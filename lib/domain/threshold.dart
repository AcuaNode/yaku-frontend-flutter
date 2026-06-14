class Threshold {
  final int? id;
  final String species;
  final double minTemperature;
  final double maxTemperature;
  final double minPh;
  final double maxPh;
  final double minTurbidity;
  final double maxTurbidity;

  const Threshold({
    this.id,
    required this.species,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minPh,
    required this.maxPh,
    required this.minTurbidity,
    required this.maxTurbidity,
  });

  factory Threshold.fromJson(Map<String, dynamic> j) => Threshold(
    id: (j['id'] as num?)?.toInt(),
    species: j['species']?.toString() ?? '',
    minTemperature: (j['minTemperature'] as num?)?.toDouble() ?? 0,
    maxTemperature: (j['maxTemperature'] as num?)?.toDouble() ?? 0,
    minPh: (j['minPh'] as num?)?.toDouble() ?? 0,
    maxPh: (j['maxPh'] as num?)?.toDouble() ?? 0,
    minTurbidity: (j['minTurbidity'] as num?)?.toDouble() ?? 0,
    maxTurbidity: (j['maxTurbidity'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'species': species,
    'minTemperature': minTemperature,
    'maxTemperature': maxTemperature,
    'minPh': minPh,
    'maxPh': maxPh,
    'minTurbidity': minTurbidity,
    'maxTurbidity': maxTurbidity,
  };

  Threshold copyWith({
    String? species,
    double? minTemperature,
    double? maxTemperature,
    double? minPh,
    double? maxPh,
    double? minTurbidity,
    double? maxTurbidity,
  }) => Threshold(
    id: id,
    species: species ?? this.species,
    minTemperature: minTemperature ?? this.minTemperature,
    maxTemperature: maxTemperature ?? this.maxTemperature,
    minPh: minPh ?? this.minPh,
    maxPh: maxPh ?? this.maxPh,
    minTurbidity: minTurbidity ?? this.minTurbidity,
    maxTurbidity: maxTurbidity ?? this.maxTurbidity,
  );
}
