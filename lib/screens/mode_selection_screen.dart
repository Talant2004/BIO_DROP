import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/mission_provider.dart';
import '../models/mission.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя полоса
            Container(
              height: 8,
              color: const Color(0xFF4CAF50),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // Левая панель - логотип и заголовок
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Логотип
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'Logo/Logo_string_Maincolor.png',
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Заголовок
                          const Text(
                            'Выберите тип работ по внесению капсул',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Кнопка помощи
                          TextButton(
                            onPressed: () => context.go('/help'),
                            child: const Text(
                              'Помощь',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 40),

                    // Правая панель - опции выбора
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer<MissionProvider>(
                            builder: (context, missionProvider, child) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildModeOption(
                                      context,
                                      'По площади',
                                      Icons.grid_view,
                                      'Для обработки больших участков поля',
                                      ApplicationMode.byArea,
                                      missionProvider.selectedMode ==
                                          ApplicationMode.byArea,
                                      () => missionProvider.setApplicationMode(
                                          ApplicationMode.byArea),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildModeOption(
                                      context,
                                      'По точкам',
                                      Icons.location_on,
                                      'Для точечного внесения в местах повышенной численности',
                                      ApplicationMode.byPoints,
                                      missionProvider.selectedMode ==
                                          ApplicationMode.byPoints,
                                      () => missionProvider.setApplicationMode(
                                          ApplicationMode.byPoints),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // Кнопка продолжения
                          Consumer<MissionProvider>(
                            builder: (context, missionProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: missionProvider.selectedMode !=
                                          null
                                      ? () => context.go('/bioagent-selection')
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    'Продолжить',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    ApplicationMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white70 : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
