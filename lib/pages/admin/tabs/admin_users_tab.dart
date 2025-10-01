import 'package:flutter/material.dart';

class AdminUsersTab extends StatelessWidget {
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Carlos Mendez',
      'email': 'carlos@aditech.com',
      'role': 'Usuario',
      'status': 'Activo',
      'lastLogin': '2 min ago',
      'tickets': 5,
    },
    {
      'name': 'Ana García',
      'email': 'ana@aditech.com',
      'role': 'Usuario',
      'status': 'Activo',
      'lastLogin': '1 hora ago',
      'tickets': 12,
    },
    {
      'name': 'Luis Rodríguez',
      'email': 'luis@aditech.com',
      'role': 'Técnico',
      'status': 'Activo',
      'lastLogin': '30 min ago',
      'tickets': 8,
    },
    {
      'name': 'María González',
      'email': 'maria@aditech.com',
      'role': 'Usuario',
      'status': 'Inactivo',
      'lastLogin': '2 días ago',
      'tickets': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Usuarios',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${_users.length} usuarios registrados',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return _buildUserCard(user, context);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Añadir nuevo usuario
        },
        backgroundColor: Colors.orange,
        icon: Icon(Icons.person_add, color: Colors.white),
        label: Text('Nuevo Usuario', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, BuildContext context) {
    bool isActive = user['status'] == 'Activo';
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            user['role'] == 'Técnico' ? Icons.build : Icons.person,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          user['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email']),
            Row(
              children: [
                Text('${user['role']} • '),
                Text(
                  user['status'],
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${user['tickets']} tickets'),
            Text(
              user['lastLogin'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        onTap: () {
          _showUserDetails(context, user);
        },
      ),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles del Usuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text('Nombre: ${user['name']}'),
            Text('Email: ${user['email']}'),
            Text('Rol: ${user['role']}'),
            Text('Estado: ${user['status']}'),
            Text('Último acceso: ${user['lastLogin']}'),
            Text('Tickets creados: ${user['tickets']}'),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Editar usuario
                    },
                    child: Text('Editar'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Desactivar usuario
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Desactivar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}