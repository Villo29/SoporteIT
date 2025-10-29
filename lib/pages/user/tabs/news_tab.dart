import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  List<Map<String, dynamic>> _news = [];
  bool _isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isLoadingNews = true;
      });

      final token = await AuthService.getCurrentToken();
      if (token == null) {
        setState(() {
          _isLoadingNews = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/noticias/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> newsData = json.decode(response.body);

        setState(() {
          _news = newsData.map((news) => _mapNewsFromApi(news)).toList();
          _isLoadingNews = false;
        });
      } else {
        setState(() {
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingNews = false;
      });
    }
  }

  Map<String, dynamic> _mapNewsFromApi(Map<String, dynamic> apiNews) {
    return {
      'id': apiNews['id'],
      'title': apiNews['titulo'] ?? 'Sin título',
      'summary': _createSummary(apiNews['contenido'] ?? 'Sin contenido'),
      'content': apiNews['contenido'] ?? 'Sin contenido',
      'author': apiNews['autor'] ?? 'Desconocido',
      'date': _formatDateFromApi(apiNews['fecha'] ?? ''),
      'category': _extractCategory(apiNews['titulo'] ?? ''),
      'isNew': _isRecentNews(apiNews['fecha'] ?? ''),
    };
  }

  String _createSummary(String content) {
    // Crear un resumen de los primeros 120 caracteres
    if (content.length <= 120) return content;
    return '${content.substring(0, 120)}...';
  }

  String _extractCategory(String title) {
    // Extraer categoría basada en palabras clave del título
    final titleLower = title.toLowerCase();
    if (titleLower.contains('mantenimiento') ||
        titleLower.contains('mantener')) {
      return 'Mantenimiento';
    } else if (titleLower.contains('sistema') ||
        titleLower.contains('actualización')) {
      return 'Sistema';
    } else if (titleLower.contains('seguridad') ||
        titleLower.contains('política')) {
      return 'Seguridad';
    } else if (titleLower.contains('capacitación') ||
        titleLower.contains('entrenamiento')) {
      return 'Capacitación';
    } else {
      return 'General';
    }
  }

  bool _isRecentNews(String isoDate) {
    try {
      final DateTime newsDate = DateTime.parse(isoDate);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(newsDate);

      // Considerar como "nuevo" si es de hace menos de 3 días
      return difference.inDays <= 3;
    } catch (e) {
      return false;
    }
  }

  String _formatDateFromApi(String isoDate) {
    try {
      final DateTime newsDate = DateTime.parse(isoDate);
      return '${newsDate.day.toString().padLeft(2, '0')}-${newsDate.month.toString().padLeft(2, '0')}-${newsDate.year}';
    } catch (e) {
      return 'Sin fecha';
    }
  }

  @override
  Widget build(BuildContext context) {
    final newNewsCount = _news.where((item) => item['isNew'] == true).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Noticias',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isLoadingNews) ...[
                      SizedBox(width: 12),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1C9985),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!_isLoadingNews)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$newNewsCount nuevas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Lista de noticias
          Expanded(
            child: _isLoadingNews
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1C9985),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando noticias...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _news.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.newspaper,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay noticias disponibles',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Las noticias aparecerán aquí cuando estén disponibles',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNews,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _news.length,
                      itemBuilder: (context, index) {
                        final item = _news[index];
                        return _buildNewsCard(item, context);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> item, BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navegar a detalle de noticia
          _showNewsDetail(context, item);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título, badge "Nuevo" y icono
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item['isNew'] == true) ...[
                              SizedBox(width: 8),
                              _buildNewBadge(),
                            ],
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildCategoryBadge(item['category']),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.open_in_new, size: 16, color: Colors.grey[500]),
                ],
              ),
              SizedBox(height: 12),

              // Resumen
              Text(
                item['summary'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),

              // Fecha
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    item['date'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Nuevo',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color getCategoryColor(String category) {
      switch (category.toLowerCase()) {
        case 'sistema':
          return Colors.blue;
        case 'mantenimiento':
          return Colors.green;
        case 'seguridad':
          return Colors.red;
        case 'capacitación':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: getCategoryColor(category),
        ),
      ),
    );
  }

  void _showNewsDetail(BuildContext context, Map<String, dynamic> newsItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Título y categoría
              Row(
                children: [
                  _buildCategoryBadge(newsItem['category']),
                  if (newsItem['isNew'] == true) ...[
                    SizedBox(width: 8),
                    _buildNewBadge(),
                  ],
                ],
              ),
              SizedBox(height: 12),

              Text(
                newsItem['title'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Fecha
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    newsItem['date'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Contenido completo
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mostrar autor si está disponible
                      if (newsItem['author'] != null &&
                          newsItem['author'] != 'Desconocido') ...[
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Por: ${newsItem['author']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],

                      // Contenido principal
                      Text(
                        newsItem['content'] ??
                            newsItem['summary'] ??
                            'Contenido no disponible',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
