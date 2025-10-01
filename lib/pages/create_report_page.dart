import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  String? _selectedCategory;
  String? _priority;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Variables para archivos adjuntos
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final List<File> _selectedFiles = [];

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'computer',
      'icon': Icons.computer,
      'label': 'Computadora',
      'color': Colors.blue,
    },
    {
      'id': 'printer',
      'icon': Icons.print,
      'label': 'Impresora',
      'color': Colors.grey,
    },
    {
      'id': 'network',
      'icon': Icons.wifi,
      'label': 'Red/Internet',
      'color': Colors.orange,
    },
    {
      'id': 'phone',
      'icon': Icons.phone,
      'label': 'Teléfono',
      'color': Colors.red,
    },
    {
      'id': 'software',
      'icon': Icons.bug_report,
      'label': 'Software',
      'color': Colors.green,
    },
    {
      'id': 'other',
      'icon': Icons.settings,
      'label': 'Otro',
      'color': Colors.purple,
    }
  ];

  final List<Map<String, dynamic>> _priorities = [
    {
      'value': 'low',
      'label': 'Baja',
      'description': 'Puede esperar',
      'color': Colors.blue,
    },
    {
      'value': 'medium',
      'label': 'Media',
      'description': 'Afecta mi trabajo',
      'color': Colors.orange,
    },
    {
      'value': 'high',
      'label': 'Alta',
      'description': 'No puedo trabajar',
      'color': Colors.red,
    },
  ];

  void _submitReport() {
    if (_selectedCategory == null ||
        _priority == null ||
        _titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar información del reporte (en una implementación real, aquí enviarías los datos al servidor)
    String attachmentsInfo = '';
    if (_selectedImages.isNotEmpty || _selectedFiles.isNotEmpty) {
      attachmentsInfo = '\n\nArchivos adjuntos: ${_selectedImages.length} imágenes, ${_selectedFiles.length} documentos';
    }

    // Aquí iría la lógica para enviar el reporte con todos los archivos
    print('Enviando reporte:');
    print('Categoría: $_selectedCategory');
    print('Prioridad: $_priority');
    print('Título: ${_titleController.text}');
    print('Ubicación: ${_locationController.text}');
    print('Descripción: ${_descriptionController.text}');
    print('Imágenes: ${_selectedImages.length}');
    print('Archivos: ${_selectedFiles.length}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reporte enviado exitosamente$attachmentsInfo'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Regresar a la pantalla anterior después de enviar
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto capturada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al capturar la foto: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _pickFile() async {
    try {
      // Mostrar opciones: Galería o Documentos
      await showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Seleccionar de Galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.insert_drive_file),
                  title: Text('Seleccionar Documento'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocument();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text('Cancelar'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen seleccionada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFiles.add(File(result.files.single.path!));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo seleccionado: ${result.files.single.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar archivo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Nuevo Reporte'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
            // Tipo de Problema
            _buildCategoryCard(),
            SizedBox(height: 16),
            
            // Título del Problema
            _buildTitleCard(),
            SizedBox(height: 16),
            
            // Prioridad
            _buildPriorityCard(),
            SizedBox(height: 16),
            
            // Ubicación
            _buildLocationCard(),
            SizedBox(height: 16),
            
            // Descripción Detallada
            _buildDescriptionCard(),
            SizedBox(height: 16),
            
            // Archivos Adjuntos
            _buildAttachmentsCard(),
            SizedBox(height: 24),
            
            // Botón Enviar
            _buildSubmitButton(),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCategoryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Problema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryItem(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final isSelected = _selectedCategory == category['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['id'];
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? category['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? category['color'].withOpacity(0.1) : Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category['color'],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                category['icon'],
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              category['label'],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título del Problema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Describe brevemente el problema',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Ej: Mi computadora se reinicia sola',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prioridad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: InputDecoration(
                labelText: 'Selecciona la prioridad',
                border: OutlineInputBorder(),
              ),
              items: _priorities.map((priority) {
                return DropdownMenuItem<String>(
                  value: priority['value'],
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priority['color'],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          priority['label'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(priority['description']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _priority = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '¿Dónde se encuentra el problema?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _locationController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Ej: Oficina 205, Piso 2',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descripción Detallada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Describe qué pasó, cuándo empezó, y qué estabas haciendo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Ejemplo: Estaba trabajando en Excel cuando de repente la pantalla se puso azul y la computadora se reinició. Esto ha pasado 3 veces hoy...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Archivos Adjuntos (Opcional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttachmentButton(
                    icon: Icons.camera_alt,
                    label: 'Tomar Foto',
                    onTap: () {
                      _takePicture();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildAttachmentButton(
                    icon: Icons.upload,
                    label: 'Subir Archivo',
                    onTap: () {
                      _pickFile();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Mostrar archivos seleccionados
            if (_selectedImages.isNotEmpty || _selectedFiles.isNotEmpty) ...[
              Text(
                'Archivos seleccionados:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              
              // Mostrar imágenes
              if (_selectedImages.isNotEmpty) ...[
                Text(
                  'Imágenes (${_selectedImages.length}):',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => _removeImage(index),
                                constraints: BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12),
              ],
              
              // Mostrar archivos
              if (_selectedFiles.isNotEmpty) ...[
                Text(
                  'Documentos (${_selectedFiles.length}):',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 8),
                ...(_selectedFiles.asMap().entries.map((entry) {
                  int index = entry.key;
                  File file = entry.value;
                  String fileName = file.path.split('/').last;
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            fileName,
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _removeFile(index),
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  );
                }).toList()),
              ],
            ] else ...[
              Text(
                'Las fotos ayudan a entender mejor el problema',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.grey[600]),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _titleController,
          builder: (context, titleValue, _) {
            return ValueListenableBuilder(
              valueListenable: _locationController,
              builder: (context, locationValue, _) {
                return ValueListenableBuilder(
                  valueListenable: _descriptionController,
                  builder: (context, descriptionValue, _) {
                    final isFormValid = _selectedCategory != null &&
                        _priority != null &&
                        _titleController.text.isNotEmpty &&
                        _locationController.text.isNotEmpty &&
                        _descriptionController.text.isNotEmpty;

                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isFormValid ? _submitReport : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFormValid ? Colors.blue : Colors.grey[400],
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: Text(
                          'Enviar Reporte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        SizedBox(height: 8),
        Text(
          'Recibirás una confirmación por email',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    // Limpiar listas de archivos
    _selectedImages.clear();
    _selectedFiles.clear();
    super.dispose();
  }
}