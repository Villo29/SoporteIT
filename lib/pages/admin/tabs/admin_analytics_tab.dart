import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';

class AdminNewsSettings extends StatefulWidget {
  const AdminNewsSettings({super.key});

  @override
  State<AdminNewsSettings> createState() => _AdminNewsSettingsState();
}

class _AdminNewsSettingsState extends State<AdminNewsSettings> {
  int? _editingId; // null = creando
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  
  List<_NewsItem> newsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  // Cargar todas las noticias desde la API
  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/noticias'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          newsList = data.map((item) => _NewsItem.fromApi(item)).toList();
        });
        print('✅ Noticias cargadas: ${newsList.length}');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error cargando noticias: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar noticias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Crear nueva noticia
  Future<void> _createNews() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Título y contenido son requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/noticias'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'titulo': _titleCtrl.text.trim(),
          'contenido': _contentCtrl.text.trim(),
          'autor': 'Administrador',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Noticia creada exitosamente');
        _closeDialog();
        _loadNews(); // Recargar lista
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Noticia creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creando noticia: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear noticia: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Actualizar noticia existente
  Future<void> _updateNews() async {
    if (_editingId == null || _titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Título y contenido son requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/noticias/$_editingId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'titulo': _titleCtrl.text.trim(),
          'contenido': _contentCtrl.text.trim(),
          'autor': 'Administrador',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Noticia actualizada exitosamente');
        _closeDialog();
        _loadNews(); // Recargar lista
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Noticia actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error actualizando noticia: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar noticia: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Eliminar noticia
  Future<void> _deleteNews(int newsId) async {
    // Confirmar eliminación
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta noticia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/noticias/$newsId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Noticia eliminada exitosamente');
        _loadNews(); // Recargar lista
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Noticia eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error eliminando noticia: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar noticia: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _handleUpdateNews() {
    _updateNews();
  }

  void _handleTogglePublish(int newsId) {
    // Esta funcionalidad se puede implementar más tarde si la API la soporta
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de publicar/ocultar no disponible en API'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleDeleteNews(int newsId) {
    _deleteNews(newsId);
  }

  void _openCreateDialog() {
    _editingId = null;
    _titleCtrl.clear();
    _contentCtrl.clear();
    _openDialog(saveLabel: 'Crear Noticia', onSave: _handleCreateNews);
  }

  void _handleCreateNews() {
    _createNews();
  }

  void _openEditDialog(_NewsItem item) {
    _editingId = item.id;
    _titleCtrl.text = item.title;
    _contentCtrl.text = item.content;
    _openDialog(saveLabel: 'Guardar Cambios', onSave: _handleUpdateNews);
  }

  void _openDialog({required String saveLabel, required VoidCallback onSave}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_editingId == null ? 'Nueva Noticia' : 'Editar Noticia'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Contenido'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: _closeDialog, child: const Text('Cancelar')),
            FilledButton(onPressed: onSave, child: Text(saveLabel)),
          ],
        );
      },
    );
  }

  void _closeDialog() {
    Navigator.of(context).maybePop();
    setState(() {
      _editingId = null;
      _titleCtrl.clear();
      _contentCtrl.clear();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _loadNews,
      color: const Color(0xFF1C9985),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LayoutBuilder(
          builder: (context, constraints) {
            // Responsive design for mobile
            bool isMobile = constraints.maxWidth < 600;
            
            if (isMobile) {
              // Mobile: Column layout with full-width button
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gestión de Noticias',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Administra las noticias que verán los usuarios',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openCreateDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Nueva Noticia'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1C9985),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Desktop: Row layout
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gestión de Noticias',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Administra las noticias que verán los usuarios',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: _openCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva Noticia'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1C9985),
                    ),
                  ),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 16),

        // Loading indicator
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                color: Color(0xFF1C9985),
              ),
            ),
          )
        else if (newsList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay noticias',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea la primera noticia para empezar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...newsList.map((n) => _NewsCard(
                item: n,
                onEdit: () => _openEditDialog(n),
                onTogglePublish: () => _handleTogglePublish(n.id),
                onDelete: () => _handleDeleteNews(n.id),
              )),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.item,
    required this.onEdit,
    required this.onTogglePublish,
    required this.onDelete,
  });

  final _NewsItem item;
  final VoidCallback onEdit;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final String dateStr = '${item.date.day}/${item.date.month}/${item.date.year}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _Badge(
                  label: item.published ? 'Publicada' : 'Borrador',
                  color: item.published ? Colors.green : Colors.pink,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              child: Row(
                children: [
                  Text(item.author),
                  const SizedBox(width: 8),
                  const Text('•'),
                  const SizedBox(width: 8),
                  Text(dateStr),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                ),
                OutlinedButton.icon(
                  onPressed: onTogglePublish,
                  icon: Icon(item.published ? Icons.visibility_off : Icons.visibility, size: 18),
                  label: Text(item.published ? 'Ocultar' : 'Publicar'),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _NewsItem {
  const _NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.published,
  });

  final int id;
  final String title;
  final String content;
  final String author;
  final DateTime date;
  final bool published;

  // Constructor desde API
  factory _NewsItem.fromApi(Map<String, dynamic> json) {
    return _NewsItem(
      id: json['id'] ?? 0,
      title: json['titulo'] ?? '',
      content: json['contenido'] ?? '',
      author: json['autor'] ?? 'Administrador',
      date: json['fecha_creacion'] != null 
          ? DateTime.tryParse(json['fecha_creacion']) ?? DateTime.now()
          : DateTime.now(),
      published: json['publicado'] ?? true, // Asumimos que están publicadas por defecto
    );
  }

  _NewsItem copyWith({
    String? title,
    String? content,
    bool? published,
  }) => _NewsItem(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        author: author,
        date: date,
        published: published ?? this.published,
      );
}