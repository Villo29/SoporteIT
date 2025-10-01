import 'package:flutter/material.dart';

class NewsTab extends StatelessWidget {
  const NewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final news = [
      {
        'id': 1,
        'title': "Actualización del sistema de tickets",
        'summary': "Nueva versión disponible con mejoras en la interfaz y corrección de errores.",
        'category': "Sistema",
        'date': "2024-01-15",
        'isNew': true
      },
      {
        'id': 2,
        'title': "Mantenimiento programado",
        'summary': "El servidor principal estará en mantenimiento el próximo fin de semana.",
        'category': "Mantenimiento",
        'date': "2024-01-14",
        'isNew': false
      },
      {
        'id': 3,
        'title': "Nuevas políticas de seguridad",
        'summary': "Se implementarán nuevas medidas de seguridad para proteger la información.",
        'category': "Seguridad",
        'date': "2024-01-12",
        'isNew': false
      },
      {
        'id': 4,
        'title': "Capacitación en nuevas herramientas",
        'summary': "Sesión de entrenamiento sobre las últimas herramientas de soporte técnico.",
        'category': "Capacitación",
        'date': "2024-01-10",
        'isNew': false
      }
    ];

    final newNewsCount = news.where((item) => item['isNew'] == true).length;

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
                Text(
                  'Noticias',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: news.length,
              itemBuilder: (context, index) {
                final item = news[index];
                return _buildNewsCard(item, context);
              },
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
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Colors.grey[500],
                  ),
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
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: 4),
                  Text(
                    item['date'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              
              // Fecha
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: 4),
                  Text(
                    newsItem['date'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Contenido completo
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _getFullNewsContent(newsItem['title']),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
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

  String _getFullNewsContent(String title) {
    // Contenido extendido para cada noticia
    switch (title) {
      case "Actualización del sistema de tickets":
        return "Estamos emocionados de anunciar la nueva versión de nuestro sistema de tickets. Esta actualización incluye:\n\n• Interfaz de usuario completamente rediseñada para mejor usabilidad\n• Corrección de errores reportados por los usuarios\n• Nuevas funciones de seguimiento de tickets\n• Mejoras en la velocidad del sistema\n• Integración con nuevas herramientas de soporte\n\nLa actualización estará disponible para todos los usuarios a partir del 20 de enero. Recomendamos revisar las nuevas funciones y proporcionar sus comentarios.";
      
      case "Mantenimiento programado":
        return "Informamos que el servidor principal del sistema experimentará mantenimiento programado durante el próximo fin de semana.\n\nDetalles del mantenimiento:\n\n• Fecha: Sábado 20 de enero, 22:00 - Domingo 21 de enero, 06:00\n• Duración: 8 horas estimadas\n• Servicios afectados: Sistema de tickets y portal de soporte\n• Impacto: Interrupción temporal del servicio\n\nRecomendaciones:\n• Planificar actividades críticas fuera de este horario\n• Guardar todo trabajo en progreso antes del mantenimiento\n• Contactar al equipo técnico para emergencias\n\nAgradecemos su comprensión y coordinación.";
      
      case "Nuevas políticas de seguridad":
        return "Como parte de nuestro compromiso continuo con la seguridad de la información, implementaremos nuevas medidas de seguridad efectivas a partir del 25 de enero.\n\nNuevas medidas:\n\n• Autenticación de dos factores obligatoria\n• Encriptación mejorada de datos sensibles\n• Auditoría de seguridad mejorada\n• Políticas de contraseñas más estrictas\n• Monitoreo continuo de actividades sospechosas\n\nBeneficios:\n• Mayor protección de información confidencial\n• Cumplimiento con estándares internacionales\n• Reducción de riesgos de seguridad\n• Mejor trazabilidad de accesos\n\nTodo el personal recibirá capacitación sobre estas nuevas políticas la próxima semana.";
      
      case "Capacitación en nuevas herramientas":
        return "Invitamos a todo el equipo a participar en la sesión de entrenamiento sobre las últimas herramientas de soporte técnico.\n\nDetalles de la capacitación:\n\n• Fecha: Miércoles 17 de enero, 14:00 - 16:00\n• Lugar: Sala de conferencias principal\n• Modalidad: Presencial y virtual\n• Instructor: Especialista en herramientas de soporte\n\nTemas a cubrir:\n• Uso avanzado del sistema de tickets\n• Nuevas funciones de reportes\n• Herramientas de diagnóstico remoto\n• Mejores prácticas de soporte técnico\n• Casos de estudio y ejercicios prácticos\n\nInscripciones abiertas hasta el 15 de enero. Cupos limitados.";
      
      default:
        return "Contenido completo de la noticia. Aquí iría el texto extendido con todos los detalles relevantes para los usuarios.";
    }
  }
}