import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/mission_provider.dart';
import '../models/mission.dart';

class BioagentSelectionScreen extends StatelessWidget {
  const BioagentSelectionScreen({super.key});

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
                            'Выберите тип биоагента',
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

                    // Правая панель - опции выбора биоагентов
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer<MissionProvider>(
                            builder: (context, missionProvider, child) {
                              return Column(
                                children: BioagentInfo.availableBioagents
                                    .map((bioagent) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: _buildBioagentOption(
                                      context,
                                      bioagent,
                                      missionProvider.selectedBioagent ==
                                          bioagent.type,
                                      () => missionProvider
                                          .setBioagentType(bioagent.type),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // Кнопки навигации
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        context.go('/mode-selection'),
                                    style: OutlinedButton.styleFrom(
                                      side:
                                          const BorderSide(color: Colors.grey),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Назад',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Consumer<MissionProvider>(
                                  builder: (context, missionProvider, child) {
                                    return SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: missionProvider
                                                    .selectedBioagent !=
                                                null
                                            ? () =>
                                                context.go('/mission-preview')
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4CAF50),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                              ),
                            ],
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

  Widget _buildBioagentOption(
    BuildContext context,
    BioagentInfo bioagent,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Изображение капсулы биоагента
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      bioagent.type == BioagentType.trichogramma
                          ? 'photo/TrichoCap_Preview.png'
                          : 'photo/BraconCap_Preview.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Информация о биоагенте
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bioagent.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF4CAF50)
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bioagent.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? const Color(0xFF4CAF50).withOpacity(0.8)
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bioagent.usage,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFF4CAF50).withOpacity(0.7)
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Индикатор выбора
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 28,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey[400],
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
