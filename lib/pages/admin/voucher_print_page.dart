import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoucherPrintPage extends StatelessWidget {
  const VoucherPrintPage({super.key, required this.ticket});
  final Map<String, dynamic> ticket;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher de Servicio'),
        backgroundColor: const Color(0xFF1C9985),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _simulatePrint(context),
            icon: const Icon(Icons.print),
            tooltip: 'Imprimir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header del voucher
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1C9985),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'VOUCHER DE SERVICIO TÉCNICO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ticket: ${ticket['id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido del voucher
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del ticket
                    _VoucherSection(
                      title: 'INFORMACIÓN DEL SERVICIO',
                      children: [
                        _VoucherRow('Fecha de Servicio:', ticket['resolutionDate'] ?? currentDate),
                        _VoucherRow('Usuario:', ticket['user']),
                        _VoucherRow('Email:', ticket['userEmail']),
                        _VoucherRow('Categoría:', ticket['category']),
                        _VoucherRow('Prioridad:', ticket['priority']),
                        _VoucherRow('Técnico Asignado:', ticket['assignedTo'] ?? 'N/A'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Descripción del problema
                    _VoucherSection(
                      title: 'DESCRIPCIÓN DEL PROBLEMA',
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            ticket['title'],
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(ticket['description']),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Solución aplicada
                    _VoucherSection(
                      title: 'SOLUCIÓN APLICADA',
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            ticket['solution'] ?? 'No se ha registrado solución',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sección de firmas
                    _VoucherSection(
                      title: 'FIRMAS Y CONFORMIDAD',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Firma del Empleado',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    ticket['user'],
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const Text('Cliente'),
                                  const SizedBox(height: 8),
                                  const Text('Fecha: _____________'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Firma del Técnico',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    ticket['assignedTo'] ?? 'N/A',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const Text('Técnico de Soporte'),
                                  const SizedBox(height: 8),
                                  const Text('Fecha: _____________'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Gracias por usar nuestros servicios de soporte técnico',
                            style: TextStyle(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Generado el $currentDate',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulatePrint(BuildContext context) {
    // Simular impresión
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📄 Voucher enviado a la impresora'),
        backgroundColor: Color(0xFF1C9985),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Vibración simulada
    HapticFeedback.mediumImpact();
  }
}

class _VoucherSection extends StatelessWidget {
  const _VoucherSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C9985),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _VoucherRow extends StatelessWidget {
  const _VoucherRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}