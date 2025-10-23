import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/mission.dart';

class MissionProvider extends ChangeNotifier {
  Mission? _currentMission;
  ApplicationMode? _selectedMode;
  BioagentType? _selectedBioagent;
  String? _kmlFilePath;
  List<LatLng> _waypoints = [];
  bool _isMissionRunning = false;

  // Getters
  Mission? get currentMission => _currentMission;
  ApplicationMode? get selectedMode => _selectedMode;
  BioagentType? get selectedBioagent => _selectedBioagent;
  String? get kmlFilePath => _kmlFilePath;
  List<LatLng> get waypoints => _waypoints;
  bool get isMissionRunning => _isMissionRunning;

  // Setters
  void setApplicationMode(ApplicationMode mode) {
    _selectedMode = mode;
    notifyListeners();
  }

  void setBioagentType(BioagentType type) {
    _selectedBioagent = type;
    notifyListeners();
  }

  void setKmlFilePath(String path) {
    _kmlFilePath = path;
    notifyListeners();
  }

  void setWaypoints(List<LatLng> points) {
    _waypoints = points;
    notifyListeners();
  }

  void createMission() {
    if (_selectedMode == null ||
        _selectedBioagent == null ||
        _waypoints.isEmpty) {
      return;
    }

    // Рассчитываем параметры миссии
    final totalDistance = _calculateTotalDistance(_waypoints);
    final totalArea = _calculateTotalArea(_waypoints);
    final totalCapsules =
        _calculateTotalCapsules(totalArea, _selectedBioagent!);
    final totalTime = _calculateTotalTime(totalDistance);

    _currentMission = Mission(
      applicationMode: _selectedMode!,
      bioagentType: _selectedBioagent!,
      waypoints: _waypoints,
      altitude: 5.0, // 5 метров по умолчанию
      applicationRate: _getApplicationRate(_selectedBioagent!),
      totalArea: totalArea,
      totalCapsules: totalCapsules,
      totalTime: totalTime,
      totalDistance: totalDistance,
      status: MissionStatus.ready,
      kmlFilePath: _kmlFilePath,
    );

    notifyListeners();
  }

  void startMission() {
    if (_currentMission != null) {
      _currentMission = _currentMission!.copyWith(
        status: MissionStatus.inProgress,
      );
      _isMissionRunning = true;
      notifyListeners();
    }
  }

  void updateMissionProgress({
    int? completedCapsules,
    Duration? elapsedTime,
    double? coveredDistance,
  }) {
    if (_currentMission != null && _isMissionRunning) {
      _currentMission = _currentMission!.copyWith(
        completedCapsules:
            completedCapsules ?? _currentMission!.completedCapsules,
        elapsedTime: elapsedTime ?? _currentMission!.elapsedTime,
        coveredDistance: coveredDistance ?? _currentMission!.coveredDistance,
      );
      notifyListeners();
    }
  }

  void stopMission() {
    if (_currentMission != null) {
      _currentMission = _currentMission!.copyWith(
        status: MissionStatus.completed,
      );
      _isMissionRunning = false;
      notifyListeners();
    }
  }

  void resetMission() {
    _currentMission = null;
    _selectedMode = null;
    _selectedBioagent = null;
    _kmlFilePath = null;
    _waypoints = [];
    _isMissionRunning = false;
    notifyListeners();
  }

  // Вспомогательные методы
  double _calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _calculateDistanceBetween(points[i], points[i + 1]);
    }
    return totalDistance;
  }

  double _calculateDistanceBetween(LatLng point1, LatLng point2) {
    // Упрощенный расчет расстояния (для демонстрации)
    final latDiff = point1.latitude - point2.latitude;
    final lngDiff = point1.longitude - point2.longitude;
    return (latDiff * latDiff + lngDiff * lngDiff) *
        111000; // Примерное значение в метрах
  }

  double _calculateTotalArea(List<LatLng> points) {
    // Упрощенный расчет площади (для демонстрации)
    if (points.length < 3) return 0.0;

    // Используем формулу Гаусса для площади многоугольника
    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += points[i].longitude * points[j].latitude;
      area -= points[j].longitude * points[i].latitude;
    }
    area =
        (area.abs() / 2.0) * 111000 * 111000; // Конвертация в квадратные метры
    return area / 10000; // Конвертация в гектары
  }

  int _calculateTotalCapsules(double areaHa, BioagentType bioagentType) {
    // Примерный расчет количества капсул
    const double capsulesPerHectare = 110.0; // 110 капсул на гектар
    return (areaHa * capsulesPerHectare).round();
  }

  Duration _calculateTotalTime(double distanceMeters) {
    // Примерный расчет времени полета (скорость 20 м/с)
    const double speedMs = 20.0;
    final int seconds = (distanceMeters / speedMs).round();
    return Duration(seconds: seconds);
  }

  double _getApplicationRate(BioagentType bioagentType) {
    return 110.0; // 110 кг/га по умолчанию
  }

  bool canCreateMission() {
    return _selectedMode != null &&
        _selectedBioagent != null &&
        _waypoints.isNotEmpty;
  }
}
