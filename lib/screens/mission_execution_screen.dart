import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../providers/mission_provider.dart';
import '../models/mission.dart';

class MissionExecutionScreen extends StatefulWidget {
  const MissionExecutionScreen({super.key});

  @override
  State<MissionExecutionScreen> createState() => _MissionExecutionScreenState();
}

class _MissionExecutionScreenState extends State<MissionExecutionScreen> {
  final MapController _mapController = MapController();
  Timer? _missionTimer;
  List<LatLng> _waypoints = [];
  List<LatLng> _completedPoints = [];
  LatLng _dronePosition = const LatLng(43.238949, 76.889709);
  int _currentPointIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeMission();
  }

  @override
  void dispose() {
    _missionTimer?.cancel();
    super.dispose();
  }

  void _initializeMission() {
    final missionProvider = context.read<MissionProvider>();
    final mission = missionProvider.currentMission;

    if (mission != null) {
      _waypoints = mission.waypoints;
      _updateMapView();
      missionProvider.startMission();
      _startMissionTimer();
    } else {
      // Если миссия не найдена, создаем тестовые данные
      _waypoints = [
        const LatLng(43.238949, 76.889709),
        const LatLng(43.239949, 76.890709),
        const LatLng(43.240949, 76.891709),
        const LatLng(43.241949, 76.892709),
      ];
      _updateMapView();
      _startMissionTimer();
    }
  }

  void _updateMapView() {
    if (_waypoints.isNotEmpty) {
      // Ждем следующий кадр, чтобы карта была отрендерена
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController.camera != null) {
          // Центрируем карту на области миссии
          final bounds = LatLngBounds.fromPoints(_waypoints);
          _mapController.fitCamera(CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50),
          ));
        }
      });
    }
  }

  void _startMissionTimer() {
    _missionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final missionProvider = context.read<MissionProvider>();
      final mission = missionProvider.currentMission;

      if (mission != null && missionProvider.isMissionRunning) {
        // Обновляем прогресс
        final newElapsedTime = Duration(seconds: timer.tick);
        final newCompletedCapsules =
            (timer.tick / 59 * 57).round(); // Примерный расчет
        final newCoveredDistance =
            (timer.tick / 59 * 1257).toDouble(); // Примерный расчет

        missionProvider.updateMissionProgress(
          completedCapsules: newCompletedCapsules,
          elapsedTime: newElapsedTime,
          coveredDistance: newCoveredDistance,
        );

        // Обновляем позицию дрона и завершенные точки
        if (timer.tick % 10 == 0 && _currentPointIndex < _waypoints.length) {
          setState(() {
            _dronePosition = _waypoints[_currentPointIndex];
            _completedPoints.add(_waypoints[_currentPointIndex]);
            _currentPointIndex++;
          });
        }

        // Проверяем завершение миссии
        if (timer.tick >= 59) {
          _completeMission();
        }
      }
    });
  }

  void _completeMission() {
    _missionTimer?.cancel();
    final missionProvider = context.read<MissionProvider>();
    missionProvider.stopMission();

    // Переходим к экрану отчета
    context.go('/mission-report');
  }

  void _stopMission() {
    _missionTimer?.cancel();
    final missionProvider = context.read<MissionProvider>();
    missionProvider.stopMission();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Остановить миссию?'),
        content:
            const Text('Вы уверены, что хотите остановить текущую миссию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/mission-report');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Остановить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя полоса с прогрессом
            Container(
              height: 50,
              color: Colors.blue,
              child: Consumer<MissionProvider>(
                builder: (context, missionProvider, child) {
                  final mission = missionProvider.currentMission;
                  final progress = mission?.progress ?? 0.0;
                  final progressPercentage =
                      mission?.progressPercentage ?? '0%';

                  return Row(
                    children: [
                      // Кнопка назад
                      IconButton(
                        onPressed: () => context.go('/mission-preview'),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                        tooltip: 'Назад',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),

                      // Заголовок
                      const Icon(Icons.flight, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'BIO_DROP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      // Прогресс
                      Expanded(
                        flex: 2,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Процент
                      Text(
                        progressPercentage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(width: 16),
                    ],
                  );
                },
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  // Карта
                  Expanded(
                    flex: 2,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(43.238949, 76.889709),
                        initialZoom: 15.0,
                        minZoom: 5.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        // Слой карты OpenStreetMap
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.biodrop.app',
                          maxZoom: 18,
                        ),

                        // Слой полигонов
                        PolygonLayer(
                          polygons: _buildPolygons(),
                        ),

                        // Слой маркеров
                        MarkerLayer(
                          markers: _buildMarkers(),
                        ),
                      ],
                    ),
                  ),

                  // Панель статистики
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                      child: Consumer<MissionProvider>(
                        builder: (context, missionProvider, child) {
                          return _buildStatsPanel(missionProvider);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Кнопка остановки
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _stopMission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'СТОП',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Polygon> _buildPolygons() {
    if (_waypoints.length < 3) return [];

    return [
      Polygon(
        points: _waypoints,
        color: Colors.green.withOpacity(0.2),
        borderColor: Colors.white,
        borderStrokeWidth: 2,
        isFilled: true,
      ),
    ];
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Маркеры для точек миссии
    for (int i = 0; i < _waypoints.length; i++) {
      final isCompleted = i < _completedPoints.length;
      final isCurrent = i == _currentPointIndex;

      Color markerColor;
      String status;

      if (isCompleted) {
        markerColor = Colors.green;
        status = 'Завершено';
      } else if (isCurrent) {
        markerColor = Colors.blue;
        status = 'В процессе';
      } else {
        markerColor = Colors.red;
        status = 'Ожидает';
      }

      markers.add(
        Marker(
          point: _waypoints[i],
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Маркер дрона
    markers.add(
      Marker(
        point: _dronePosition,
        width: 30,
        height: 30,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.flight,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );

    return markers;
  }

  Widget _buildStatsPanel(MissionProvider missionProvider) {
    final mission = missionProvider.currentMission;

    // Если миссия не найдена, показываем тестовые данные
    final completedCapsules = mission?.completedCapsules ?? 0;
    final totalCapsules = mission?.totalCapsules ?? 100;
    final elapsedTime = mission?.elapsedTime ?? Duration.zero;
    final totalTime = mission?.totalTime ?? const Duration(minutes: 5);
    final coveredDistance = mission?.coveredDistance ?? 0.0;
    final totalDistance = mission?.totalDistance ?? 1257.0;
    final status = mission?.status ?? MissionStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выполнение миссии',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
              'Внесение капсул', '$completedCapsules/$totalCapsules'),
          _buildStatItem(
              'Время', '${elapsedTime.inSeconds}/${totalTime.inSeconds} сек'),
          _buildStatItem('Пройденный путь',
              '${coveredDistance.round()}/${totalDistance.round()} м'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Статус:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(status),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(MissionStatus status) {
    switch (status) {
      case MissionStatus.pending:
        return 'Ожидает';
      case MissionStatus.ready:
        return 'Готово к запуску';
      case MissionStatus.inProgress:
        return 'В процессе';
      case MissionStatus.completed:
        return 'Завершено';
      case MissionStatus.failed:
        return 'Ошибка';
    }
  }
}
