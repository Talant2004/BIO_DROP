import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/mission_provider.dart';
import '../models/mission.dart';

class MissionReportScreen extends StatelessWidget {
  const MissionReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Consumer<MissionProvider>(
          builder: (context, missionProvider, child) {
            final mission = missionProvider.currentMission;

            if (mission == null) {
              return const Center(
                child: Text('Данные миссии не найдены'),
              );
            }

            return Column(
              children: [
                // Заголовок
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Миссия завершена',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Отчет о выполнении',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Основная статистика
                          _buildStatsCard(mission),

                          const SizedBox(height: 20),

                          // Детальная информация
                          _buildDetailsCard(mission),

                          const SizedBox(height: 20),

                          // Информация о биоагенте
                          _buildBioagentCard(mission),

                          const SizedBox(height: 20),

                          // Кнопки действий
                          _buildActionButtons(context, missionProvider),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCard(Mission mission) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Основная статистика',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Время полета',
                    '${mission.totalTime.inMinutes} мин',
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Капсулы',
                    '${mission.completedCapsules}/${mission.totalCapsules}',
                    Icons.inventory,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Расстояние',
                    '${mission.totalDistance.round()} м',
                    Icons.route,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Площадь',
                    '${mission.totalArea} га',
                    Icons.area_chart,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Mission mission) {
    final bioagentInfo = BioagentInfo.availableBioagents
        .firstWhere((bio) => bio.type == mission.bioagentType);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Детали миссии',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Биоагент', bioagentInfo.name),
            _buildDetailRow(
                'Режим',
                mission.applicationMode == ApplicationMode.byArea
                    ? 'По площади'
                    : 'По точкам'),
            _buildDetailRow('Высота', '${mission.altitude.round()} м'),
            _buildDetailRow(
                'Норма внесения', '${mission.applicationRate.round()} кг/га'),
            _buildDetailRow('Статус', _getStatusText(mission.status)),
            _buildDetailRow('Сигнал', 'Отличный'),
          ],
        ),
      ),
    );
  }

  Widget _buildBioagentCard(Mission mission) {
    final bioagentInfo = BioagentInfo.availableBioagents
        .firstWhere((bio) => bio.type == mission.bioagentType);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Информация о биоагенте',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      bioagentInfo.type == BioagentType.trichogramma
                          ? 'photo/TrichoCap_Preview.png'
                          : 'photo/BraconCap_Preview.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bioagentInfo.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        bioagentInfo.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                bioagentInfo.usage,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, MissionProvider missionProvider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              missionProvider.resetMission();
              context.go('/');
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Новая миссия'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _saveReport(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Сохранить отчет'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
        return 'Завершено успешно';
      case MissionStatus.failed:
        return 'Завершено с ошибками';
    }
  }

  void _saveReport(BuildContext context) {
    // Здесь должна быть логика сохранения отчета
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Отчет сохранен успешно'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
