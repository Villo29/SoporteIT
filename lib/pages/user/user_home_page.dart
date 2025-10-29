import 'package:flutter/material.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/news_tab.dart';
import 'tabs/others_tab.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0;

  List<Widget> get _tabs => [
    DashboardTab(
      onTabChange: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    ),
    ReportsTab(
      onOpenTicketChat: (ticketId) {
      },
      onCreateReport: () {
      },
    ),
    NewsTab(),
    OthersTab(),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, size: 24),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper, size: 24),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, size: 24),
            label: 'Otros',
          ),
        ],
      ),
    );
  }
}