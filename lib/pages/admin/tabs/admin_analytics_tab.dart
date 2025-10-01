import 'package:flutter/material.dart';

class AdminAnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics y Reportes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Summary cards
            _buildSummaryCard(
              'Tickets Este Mes',
              '127',
              '+12% vs mes anterior',
              Colors.blue,
              Icons.trending_up,
            ),
            
            _buildSummaryCard(
              'Tiempo Promedio Resolución',
              '2.5 horas',
              '-15 min vs mes anterior',
              Colors.green,
              Icons.access_time,
            ),
            
            _buildSummaryCard(
              'Satisfacción del Usuario',
              '4.2/5.0',
              '+0.3 vs mes anterior',
              Colors.orange,
              Icons.star,
            ),
            
            SizedBox(height: 24),
            
            Text(
              'Distribución por Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            _buildCategoryChart(),
            
            SizedBox(height: 24),
            
            Text(
              'Tendencias Semanales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            _buildTrendsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String change,
    Color color,
    IconData icon,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    change,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
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

  Widget _buildCategoryChart() {
    final categories = [
      {'name': 'Software', 'count': 45, 'color': Colors.blue},
      {'name': 'Hardware', 'count': 32, 'color': Colors.orange},
      {'name': 'Red', 'count': 28, 'color': Colors.green},
      {'name': 'Accesos', 'count': 22, 'color': Colors.purple},
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: categories.map((category) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: category['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Text(category['name'] as String),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: (category['count'] as int) / 50,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(category['color'] as Color),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('${category['count']}'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTrendsChart() {
    return Card(
      child: Container(
        height: 200,
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 8),
              Text(
                'Gráfico de tendencias',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              Text(
                'Funcionalidad en desarrollo',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}