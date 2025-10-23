import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Помощь'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            const Text(
              'Руководство пользователя BIO_DROP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // Разделы помощи
            _buildHelpSection(
              '2.1 Выбор режима внесения',
              'При запуске выберите, как именно вы хотите внести биоагент:\n\n'
                  '• По площади — для обработки больших участков поля (например, при массовом выпуске паразитоидов).\n\n'
                  '• По точкам — для точечного внесения, например, в местах повышенной численности вредителя.\n\n'
                  'Так вы можете адаптировать задание под реальные условия.',
            ),

            _buildHelpSection(
              '2.2 Выбор типа биоагента',
              'На следующем экране выберите, какой биоагент вы планируете использовать.\n\n'
                  'На данный момент доступны два типа:\n\n'
                  '• Trichogramma Pintoi - Паразитирует яйца чешуекрылых (совки, листовёртки). Используется для профилактики массовых вспышек вредителей.\n\n'
                  '• Bracon Hebetor - Паразитирует гусениц на поверхности растений. Эффективен в очагах вредителей.',
            ),

            _buildHelpSection(
              '2.3 Загрузка задания',
              'Загрузите задание в формате *.KML.\n\n'
                  'Это должен быть тот же самый файл, что вы вносите в ваш дрон!',
            ),

            _buildHelpSection(
              '2.4 Проверка параметров и статистики задания',
              'После выбора режима и агента приложение покажет основные параметры работы.\n\n'
                  'Проверьте параметры а затем нажмите «Начать» для отправки задания на разбрасыватель и активации задания.',
            ),

            _buildHelpSection(
              '2.5 Начало миссии',
              'Начните миссию на вашем Matrice 350 с прикрепленным и заряженным Bio Drop, после чего сброс капсул начнется автоматически.\n\n'
                  'Подготовьте ваш Matrice 350!',
            ),

            _buildHelpSection(
              '2.6 Выполнение задания',
              'Во время полёта вы можете наблюдать за ходом миссии в реальном времени:\n\n'
                  '• иконка дрона на карте показывает текущее положение\n'
                  '• маршрут обозначается линией\n'
                  '• Внесенные капсулы отмечаются на карте\n\n'
                  'Система синхронно управляет сбросом капсул: дрон выполняет полёт, а разбрасыватель точно сбрасывает капсулы в нужных точках.',
            ),

            _buildHelpSection(
              '2.7 Завершение миссии и отчёт',
              'После выполнения задания приложение сформирует отчёт:\n\n'
                  '• общее время полёта\n'
                  '• количество внесённых капсул\n'
                  '• длину маршрута\n'
                  '• статус выполнения и уровень сигнала\n\n'
                  'Вы можете сохранить отчёт или отправить его в систему учёта полевых работ.',
            ),

            const SizedBox(height: 30),

            // Кнопка назад
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Вернуться на главную',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}




