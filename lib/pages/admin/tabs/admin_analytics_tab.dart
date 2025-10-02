import 'package:flutter/material.dart';

/// =============================================================
/// AdminNewsSettings (Flutter) – Solo la sección "Noticias"
/// - Lista de noticias con estado Publicada/Borrador
/// - Botones: Editar / Publicar|Ocultar / Eliminar
/// - Diálogo para crear/editar noticia (mock, en memoria)
/// - Estilo Material 3, tarjetas con bordes redondeados
/// =============================================================

class AdminNewsSettings extends StatefulWidget {
  const AdminNewsSettings({super.key});

  @override
  State<AdminNewsSettings> createState() => _AdminNewsSettingsState();
}

class _AdminNewsSettingsState extends State<AdminNewsSettings> {
  int? _editingId; // null = creando
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  // Mock inicial (similar a tu captura)
  List<_NewsItem> newsList = [
    _NewsItem(
      id: 1,
      title: 'Nuevo sistema de tickets implementado',
      content:
          'Se ha actualizado el sistema de gestión de tickets con nuevas funcionalidades y mejoras en la interfaz de usuario.',
      author: 'Admin',
      date: DateTime(2024, 1, 14),
      published: true,
    ),
    _NewsItem(
      id: 2,
      title: 'Mantenimiento programado del servidor',
      content:
          'El próximo sábado 20 de enero realizaremos mantenimiento en los servidores principales. El servicio estará disponible con...',
      author: 'Admin',
      date: DateTime(2024, 1, 9),
      published: true,
    ),
    _NewsItem(
      id: 3,
      title: 'Nuevas políticas de seguridad',
      content:
          'Se han implementado nuevas políticas de seguridad que incluyen autenticación de dos factores y cambios de...',
      author: 'Admin',
      date: DateTime(2024, 1, 7),
      published: false,
    ),
  ];

  // ────────────────────────────────────────────────────────────
  // Acciones (equivalentes a tu código React)
  // ────────────────────────────────────────────────────────────
  void _handleUpdateNews() {
    if ((_editingId != null) && _titleCtrl.text.trim().isNotEmpty && _contentCtrl.text.trim().isNotEmpty) {
      setState(() {
        newsList = newsList
            .map((n) => n.id == _editingId!
                ? n.copyWith(title: _titleCtrl.text.trim(), content: _contentCtrl.text.trim())
                : n)
            .toList();
      });
      _closeDialog();
    }
  }

  void _handleTogglePublish(int newsId) {
    setState(() {
      newsList = newsList
          .map((n) => n.id == newsId ? n.copyWith(published: !n.published) : n)
          .toList();
    });
  }

  void _handleDeleteNews(int newsId) {
    setState(() {
      newsList.removeWhere((n) => n.id == newsId);
    });
  }

  // Crear nueva noticia
  void _openCreateDialog() {
    _editingId = null;
    _titleCtrl.clear();
    _contentCtrl.clear();
    _openDialog(saveLabel: 'Crear Noticia', onSave: _handleCreateNews);
  }

  void _handleCreateNews() {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) return;
    setState(() {
      final newId = (newsList.isEmpty ? 0 : newsList.map((e) => e.id).reduce((a, b) => a > b ? a : b)) + 1;
      newsList.insert(
        0,
        _NewsItem(
          id: newId,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          author: 'Admin',
          date: DateTime.now(),
          published: false,
        ),
      );
    });
    _closeDialog();
  }

  // Editar noticia existente
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

    return ListView(
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

        ...newsList.map((n) => _NewsCard(
              item: n,
              onEdit: () => _openEditDialog(n),
              onTogglePublish: () => _handleTogglePublish(n.id),
              onDelete: () => _handleDeleteNews(n.id),
            )),
      ],
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