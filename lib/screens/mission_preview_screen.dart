import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/mission_provider.dart';
import '../models/mission.dart';

class MissionPreviewScreen extends StatefulWidget {
  const MissionPreviewScreen({super.key});

  @override
  State<MissionPreviewScreen> createState() => _MissionPreviewScreenState();
}

class _MissionPreviewScreenState extends State<MissionPreviewScreen> {
  List<LatLng> _waypoints = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadSampleWaypoints(); // Загружаем тестовые точки для демонстрации
  }

  void _loadSampleWaypoints() {
    // Тестовые координаты для демонстрации
    _waypoints = [
      const LatLng(43.238949, 76.889709),
      const LatLng(43.239949, 76.890709),
      const LatLng(43.240949, 76.891709),
      const LatLng(43.241949, 76.892709),
    ];

    setState(() {});
    _updateMapView();
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

  Future<void> _loadKmlFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['kml'],
      );

      if (result != null) {
        // Здесь должна быть логика парсинга KML файла
        // Для демонстрации используем тестовые данные
        context
            .read<MissionProvider>()
            .setKmlFilePath(result.files.first.path!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KML файл загружен успешно'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки файла: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя полоса
            Container(
              height: 8,
              color: const Color(0xFF4CAF50),
            ),

            // Заголовок
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/bioagent-selection'),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Назад',
                    iconSize: 28,
                  ),
                  const Expanded(
                    child: Text(
                      'Предварительный просмотр миссии',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadKmlFile,
                    icon: const Icon(Icons.upload_file),
                    tooltip: 'Загрузить KML',
                    iconSize: 28,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  // Карта
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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

            // Кнопки управления
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/bioagent-selection'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Назад'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final provider = context.read<MissionProvider>();
                        provider.createMission();
                        context.go('/mission-execution');
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Старт'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPanel(MissionProvider missionProvider) {
    final selectedMode = missionProvider.selectedMode;
    final selectedBioagent = missionProvider.selectedBioagent;

    if (selectedMode == null || selectedBioagent == null) {
      return const Center(
        child: Text('Выберите режим и биоагент'),
      );
    }

    final bioagentInfo = BioagentInfo.availableBioagents
        .firstWhere((bio) => bio.type == selectedBioagent);

    // Рассчитываем примерные параметры
    final totalDistance = 1257.0; // метры
    final totalArea = 0.49; // гектары
    final totalCapsules = 57;
    final altitude = 5.0; // метры
    final applicationRate = 110.0; // кг/га
    final estimatedTime = 59; // секунды

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Параметры миссии',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatItem('Агент', bioagentInfo.name),
            _buildStatItem(
                'Режим',
                selectedMode == ApplicationMode.byArea
                    ? 'По площади'
                    : 'По точкам'),
            _buildStatItem(
                'Общая дистанция миссии', '${totalDistance.round()} м'),
            _buildStatItem('Общая площадь', '$totalArea га'),
            _buildStatItem('Количество капсул', '$totalCapsules'),
            _buildStatItem('Высота', '${altitude.round()} м'),
            _buildStatItem(
                'Норма внесения (EST)', '${applicationRate.round()} к/га'),
            _buildStatItem('Время', '${estimatedTime} сек'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Загруженные точки:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_waypoints.length} точек (${selectedBioagent == BioagentType.trichogramma ? 'T' : 'G'})',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '$totalArea га площадь участка',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
      markers.add(
        Marker(
          point: _waypoints[i],
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
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

    return markers;
  }
}
