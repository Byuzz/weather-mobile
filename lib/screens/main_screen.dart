import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weathertech/providers/sensor_provider.dart';
import 'package:weathertech/screens/dashboard_tab.dart';
import 'package:weathertech/screens/gps_tab.dart';
import 'package:weathertech/screens/system_tab.dart';
import 'package:weathertech/screens/history_tab.dart';
import 'package:weathertech/screens/profile_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Tambahkan PageController
  late PageController _pageController;
  int _currentIndex = 0;
  
  final List<Widget> _tabs = [
    const DashboardTab(),
    const GpsTab(),
    const SystemTab(),
    const HistoryTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi PageController
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
      sensorProvider.fetchAllData();
      sensorProvider.startPolling();
    });
  }

  @override
  void dispose() {
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    sensorProvider.stopPolling();
    // Jangan lupa dispose controller
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi saat layar digeser (Swipe)
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Fungsi saat tombol navigasi ditekan
  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Pindah halaman dengan animasi
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1D3C),
              Color(0xFF152A5E),
              Color(0xFF1E3A8A),
            ],
          ),
        ),
        // GANTI INI: Gunakan PageView agar bisa di-swipe
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(), // Efek memantul saat mentok
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onBottomNavTapped, // Panggil fungsi animasi tap
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                label: 'GPS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety),
                label: 'System',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}