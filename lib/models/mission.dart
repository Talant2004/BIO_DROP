import 'package:latlong2/latlong.dart';

enum ApplicationMode {
  byArea,
  byPoints,
}

enum BioagentType {
  trichogramma,
  gabrobracon,
}

class Mission {
  final ApplicationMode applicationMode;
  final BioagentType bioagentType;
  final List<LatLng> waypoints;
  final double altitude;
  final double applicationRate;
  final double totalArea;
  final int totalCapsules;
  final int completedCapsules;
  final Duration totalTime;
  final Duration elapsedTime;
  final double totalDistance;
  final double coveredDistance;
  final MissionStatus status;
  final String? kmlFilePath;

  const Mission({
    required this.applicationMode,
    required this.bioagentType,
    required this.waypoints,
    required this.altitude,
    required this.applicationRate,
    required this.totalArea,
    required this.totalCapsules,
    this.completedCapsules = 0,
    required this.totalTime,
    this.elapsedTime = Duration.zero,
    required this.totalDistance,
    this.coveredDistance = 0.0,
    this.status = MissionStatus.pending,
    this.kmlFilePath,
  });

  Mission copyWith({
    ApplicationMode? applicationMode,
    BioagentType? bioagentType,
    List<LatLng>? waypoints,
    double? altitude,
    double? applicationRate,
    double? totalArea,
    int? totalCapsules,
    int? completedCapsules,
    Duration? totalTime,
    Duration? elapsedTime,
    double? totalDistance,
    double? coveredDistance,
    MissionStatus? status,
    String? kmlFilePath,
  }) {
    return Mission(
      applicationMode: applicationMode ?? this.applicationMode,
      bioagentType: bioagentType ?? this.bioagentType,
      waypoints: waypoints ?? this.waypoints,
      altitude: altitude ?? this.altitude,
      applicationRate: applicationRate ?? this.applicationRate,
      totalArea: totalArea ?? this.totalArea,
      totalCapsules: totalCapsules ?? this.totalCapsules,
      completedCapsules: completedCapsules ?? this.completedCapsules,
      totalTime: totalTime ?? this.totalTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      totalDistance: totalDistance ?? this.totalDistance,
      coveredDistance: coveredDistance ?? this.coveredDistance,
      status: status ?? this.status,
      kmlFilePath: kmlFilePath ?? this.kmlFilePath,
    );
  }

  double get progress {
    if (totalCapsules == 0) return 0.0;
    return completedCapsules / totalCapsules;
  }

  String get progressPercentage {
    return '${(progress * 100).round()}%';
  }
}

enum MissionStatus {
  pending,
  ready,
  inProgress,
  completed,
  failed,
}

class BioagentInfo {
  final BioagentType type;
  final String name;
  final String description;
  final String targetPest;
  final String usage;
  final String capsuleDescription;
  final String iconPath;

  const BioagentInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.targetPest,
    required this.usage,
    required this.capsuleDescription,
    required this.iconPath,
  });

  static const List<BioagentInfo> availableBioagents = [
    BioagentInfo(
      type: BioagentType.trichogramma,
      name: 'Трихограмма',
      description: 'Паразитирует яйца чешуекрылых (совки, листовёртки)',
      targetPest: 'Яйца чешуекрылых',
      usage: 'Используется для профилактики массовых вспышек вредителей',
      capsuleDescription:
          'Капсулы "Коробочки" 29х53х4мм, с решеткой для выхода агента',
      iconPath: 'assets/icons/trichogramma.svg',
    ),
    BioagentInfo(
      type: BioagentType.gabrobracon,
      name: 'Габробракон',
      description: 'Паразитирует гусениц на поверхности растений',
      targetPest: 'Гусеницы',
      usage: 'Эффективен в очагах вредителей',
      capsuleDescription:
          'Капсулы "Кассеты" 29х53х4 мм, с нишами для окукливания',
      iconPath: 'assets/icons/gabrobracon.svg',
    ),
  ];
}
