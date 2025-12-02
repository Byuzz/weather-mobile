import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weathertech/providers/sensor_provider.dart';

class SystemTab extends StatefulWidget {
  const SystemTab({super.key});

  @override
  State<SystemTab> createState() => _SystemTabState();
}

class _SystemTabState extends State<SystemTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
      sensorProvider.fetchSystemData();
    });
  }

  // --- HELPER: FORMAT TANGGAL RTC (Konsisten dengan Dashboard) ---
  DateTime? parseRtcTime(String rawTime) {
    try {
      if (rawTime.contains('-')) return DateTime.parse(rawTime);
      if (rawTime.contains('/')) {
        List<String> parts = rawTime.split(' ');
        if (parts.length == 2) {
          List<String> dateParts = parts[0].split('/');
          String timePart = parts[1];
          if (dateParts.length == 3) {
            String day = dateParts[0];
            String month = dateParts[1];
            String year = dateParts[2];
            String isoFormat = "$year-$month-$day $timePart";
            return DateTime.parse(isoFormat);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  String _formatTimeOnly(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return '--:--:--';
    DateTime? dt = parseRtcTime(rawTime);
    if (dt != null) {
      return "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}:${dt.second.toString().padLeft(2,'0')}";
    }
    if (rawTime.length > 10) {
       return rawTime.substring(11, 19);
    }
    return rawTime;
  }

  // Helper untuk format Uptime
  String _formatUptime(dynamic uptimeSec) {
    if (uptimeSec == null) return '--';
    int seconds = int.tryParse(uptimeSec.toString()) ?? 0;
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return '$hours Jam $minutes Menit';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, sensorProvider, child) {
        final isOnline = sensorProvider.isDeviceOnline;
        
        // 1. Ambil Data Sistem
        final sensorSys = (sensorProvider.sensorSystemData.isNotEmpty) 
            ? sensorProvider.sensorSystemData.first 
            : null;
        final gatewaySys = (sensorProvider.gatewaySystemData.isNotEmpty) 
            ? sensorProvider.gatewaySystemData.first 
            : null;

        // 2. AMBIL WAKTU DARI SENSOR UTAMA (Karena system tidak punya RTC)
        final latestSensor = sensorProvider.latestSensor;
        String rtcTimeDisplay = '--:--:--';
        
        if (latestSensor != null) {
          // Prioritas RTC dari data sensor, fallback ke timestamp server
          String raw = latestSensor['rtc_time']?.toString() ?? latestSensor['timestamp']?.toString() ?? '';
          rtcTimeDisplay = _formatTimeOnly(raw);
        }

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
            child: RefreshIndicator(
              onRefresh: () async {
                await sensorProvider.fetchSystemData();
                await sensorProvider.fetchSensorData(); // Refresh sensor juga untuk update waktu
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'System Monitor',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Transceiver & Gateway Monitoring',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildOnlineStatusCard(isOnline),
                    const SizedBox(height: 16),
                    
                    // Passing waktu RTC dari sensor ke card system
                    _buildTransceiverCard(sensorSys, rtcTimeDisplay, isOnline), 
                    const SizedBox(height: 16),
                    _buildGatewayCard(gatewaySys, rtcTimeDisplay, isOnline),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOnlineStatusCard(bool isOnline) {
    return Container(
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOnline ? Colors.green : Colors.red, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(isOnline ? Icons.check_circle : Icons.error, color: isOnline ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isOnline ? 'Device Online' : 'Device Offline', style: TextStyle(color: isOnline ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(isOnline ? 'Data terbaru tersedia' : 'Data lebih dari 1 menit - periksa koneksi device', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TRANSCEIVER CARD ---
  Widget _buildTransceiverCard(Map<String, dynamic>? data, String timeString, bool isOnline) {
    String cpuFreq = data?['cpu_freq']?.toString() ?? '--';
    String ramUsed = data?['ram_used']?.toString() ?? '--'; 
    
    if (data?['ram_used'] != null) {
      double ram = double.tryParse(ramUsed) ?? 0;
      ramUsed = "${(ram / 1024).toStringAsFixed(0)} KB";
    }

    String uptime = _formatUptime(data?['g_uptime_sec']);
    String packetCount = data?['id']?.toString() ?? '--'; 
    String health = isOnline ? '98%' : '--';

    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.sensors, size: 24, color: Colors.white), SizedBox(width: 12), Text('Transceiver Monitor', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('System Health', style: TextStyle(color: isOnline ? Colors.white70 : Colors.white38, fontSize: 14)), const SizedBox(height: 4), Text(health, style: TextStyle(color: isOnline ? Colors.white : Colors.white54, fontSize: 24, fontWeight: FontWeight.bold))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: isOnline ? Colors.green : Colors.red)), child: Text(isOnline ? 'Status: Excellent' : 'Status: Offline', style: TextStyle(color: isOnline ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 20),
            const Text('Resource Usage', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildResourceItem('CPU Freq', '$cpuFreq MHz', isOnline),
              _buildResourceItem('RAM Used', ramUsed, isOnline),
            ]),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Uptime', style: TextStyle(color: Colors.white70, fontSize: 12)), Text(uptime, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Packets', style: TextStyle(color: Colors.white70, fontSize: 12)), Text(packetCount, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]),
                
                // MENGGUNAKAN WAKTU DARI SENSOR UTAMA
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Updated', style: TextStyle(color: Colors.white70, fontSize: 12)), Text(timeString, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(String label, String value, bool isOnline) {
    return Column(children: [Text(label, style: TextStyle(color: isOnline ? Colors.white70 : Colors.white38, fontSize: 12)), const SizedBox(height: 4), Text(value, style: TextStyle(color: isOnline ? Colors.white : Colors.white54, fontSize: 14, fontWeight: FontWeight.bold))]);
  }

  // --- GATEWAY CARD ---
  Widget _buildGatewayCard(Map<String, dynamic>? data, String timeString, bool isOnline) {
    String cpuFreq = data?['g_cpu_freq']?.toString() ?? '--';
    String ramUsed = data?['g_ram_used']?.toString() ?? '--';
    
    if (data?['g_ram_used'] != null) {
      double ram = double.tryParse(ramUsed) ?? 0;
      ramUsed = "${(ram / 1024).toStringAsFixed(0)} KB";
    }

    String uptime = _formatUptime(data?['g_uptime_sec']);

    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.router, size: 24, color: Colors.white), SizedBox(width: 12), Text('Gateway Monitor', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 20),
            
            const Text('System Specifications', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildSpecItem('ESP32 Core', '$cpuFreq MHz', isOnline),
              _buildSpecItem('Memory Used', ramUsed, isOnline),
              _buildSpecItem('Uptime', uptime, isOnline),
            ]),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            const Text('MQTT Status', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Connection', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: isOnline ? Colors.green : Colors.red)), child: Text(isOnline ? 'Active' : 'Lost', style: TextStyle(color: isOnline ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold))),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Last Message', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  // MENGGUNAKAN WAKTU DARI SENSOR UTAMA
                  Text(timeString, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ]),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, bool isOnline) {
    return Column(children: [Text(label, style: TextStyle(color: isOnline ? Colors.white70 : Colors.white38, fontSize: 10)), const SizedBox(height: 4), Text(value, style: TextStyle(color: isOnline ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold))]);
  }
}