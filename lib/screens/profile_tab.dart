import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weathertech/providers/auth_provider.dart';
import 'package:weathertech/providers/sensor_provider.dart';
import 'package:weathertech/screens/splash_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SensorProvider>(
      builder: (context, authProvider, sensorProvider, child) {
        final user = authProvider.user;
        final isOnline = sensorProvider.isDeviceOnline;
        
        return Container(
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
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Team & Project Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'WeatherTech Team - Innovating for Sustainable Environment',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Device Status Card
                  _buildDeviceStatusCard(isOnline),
                  
                  const SizedBox(height: 16),
                  
                  // Project Description Card
                  _buildProjectDescriptionCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Features Card
                  _buildFeaturesCard(),
                  
                  const SizedBox(height: 16),

                  // ========================================================
                  // NEW: TIM PENGEMBANG BLOCK
                  // ========================================================
                  _buildDeveloperTeamCard(),
                  
                  const SizedBox(height: 16),
                  
                  // User Info & Logout
                  _buildUserSection(user),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ... (Widget _buildDeviceStatusCard tetap sama) ...
  Widget _buildDeviceStatusCard(bool isOnline) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.device_hub, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Status Perangkat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem('Status', isOnline ? 'Online' : 'Offline', isOnline ? Colors.green : Colors.red),
              _buildStatusItem('Power Source', 'Panel Surya', Colors.blue),
              _buildStatusItem('Connection', isOnline ? 'Aktif' : 'Terputus', isOnline ? Colors.green : Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sistem berjalan dengan tenaga surya', style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 4),
              Text('Backup battery untuk operasi 24/7', style: TextStyle(color: Colors.white60, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
          child: Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ... (Widget _buildProjectDescriptionCard tetap sama) ...
  Widget _buildProjectDescriptionCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tentang Proyek', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Jaringan Sensor Cerdas Mandiri Energi untuk Pemantauan Iklim Mikro.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.withOpacity(0.3))),
            child: const Row(
              children: [
                Icon(Icons.energy_savings_leaf, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('Green Technology Implementation', style: TextStyle(color: Colors.green, fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (Widget _buildFeaturesCard tetap sama) ...
  Widget _buildFeaturesCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fitur Utama', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFeatureItem(checked: true, title: 'Mandiri Energi', description: 'Panel surya & backup baterai'),
          const SizedBox(height: 12),
          _buildFeatureItem(checked: true, title: 'Jangkauan Luas', description: 'Komunikasi LoRa jarak jauh'),
          const SizedBox(height: 12),
          _buildFeatureItem(checked: true, title: 'Real-time Monitor', description: 'Integrasi Dashboard & AI'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required bool checked, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, color: checked ? Colors.green : Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // WIDGET BARU: TIM PENGEMBANG
  // =========================================================================
  Widget _buildDeveloperTeamCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.groups, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                'Tim Pengembang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Logo & Nama Tim
          Center(
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/Witertek.jpg', // Sesuaikan path gambar Anda
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'WeatherTech Team',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Politeknik Negeri Jember',
                    style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          
          const Text(
            'Anggota Tim',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // DAFTAR ANGGOTA (Silakan edit nama/nim di sini)
          _buildMemberItem(
            name: "Ahmad Bayu Putra Dewantara", 
            role: "Teknik Komputer", 
            prodi: "Teknologi Informasi", 
            nim: "E32242382"
          ),
          _buildMemberItem(
            name: "Muhammad Rafi Bima Satriya", 
            role: "Teknik Komputer", 
            prodi: "Teknologi Informasi", 
            nim: "E32242225"
          ),
          _buildMemberItem(
            name: "Muhammad Fairuz Rizqi", 
            role: "Teknik Komputer", 
            prodi: "Teknologi Informasi", 
            nim: "E32242304"
          ),
          _buildMemberItem(
            name: "Cahya Qomariah Bella Andini", 
            role: "Teknik Komputer", 
            prodi: "Teknologi Informasi", 
            nim: "E32242240"
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem({
    required String name,
    required String role,
    required String prodi,
    required String nim,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prodi, // Menampilkan Prodi
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                Text(
                  role, // Menampilkan Role (Opsional)
                  style: TextStyle(
                    color: Colors.amber.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              nim, // Menampilkan NIM
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Widget _buildUserSection tetap sama) ...
  Widget _buildUserSection(Map<String, dynamic>? user) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?['username'] ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('WeatherTech Member', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
                child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.8), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('LOGOUT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]),
            ),
          ),
        ],
      ),
    );
  }
}