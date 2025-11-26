import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weathertech/providers/sensor_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _fanLoading = false;
  String _selectedTrendType = 'temperature';

  Future<void> _controlFan(String action) async {
    setState(() {
      _fanLoading = true;
    });

    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    final success = await sensorProvider.controlFan(action);

    setState(() {
      _fanLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Fan turned $action successfully' : 'Failed to control fan',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Widget _buildTrendChart(List<dynamic> trendData, String type) {
    if (trendData.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No trend data available',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    // Take last 10 data points for trend analysis
    final displayData = trendData.take(10).toList();
    
    List<FlSpot> spots = [];
    for (int i = 0; i < displayData.length; i++) {
      double value = 0.0;
      switch (type) {
        case 'temperature':
          value = displayData[i]['temp']?.toDouble() ?? 0.0;
          break;
        case 'humidity':
          value = displayData[i]['hum']?.toDouble() ?? 0.0;
          break;
        case 'air_quality':
          value = displayData[i]['air_clean_perc']?.toDouble() ?? 0.0;
          break;
        case 'light':
          value = displayData[i]['lux']?.toDouble() ?? 0.0;
          break;
      }
      spots.add(FlSpot(i.toDouble(), value));
    }

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 2,
          maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 2,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: _getTrendColor(type),
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor(String type) {
    switch (type) {
      case 'temperature':
        return Colors.orange;
      case 'humidity':
        return Colors.blue;
      case 'air_quality':
        return Colors.green;
      case 'light':
        return Colors.amber;
      default:
        return Colors.white;
    }
  }

  String _getTrendTitle(String type) {
    switch (type) {
      case 'temperature':
        return 'Temperature Trend (°C)';
      case 'humidity':
        return 'Humidity Trend (%)';
      case 'air_quality':
        return 'Air Quality Trend (%)';
      case 'light':
        return 'Light Intensity Trend (lux)';
      default:
        return 'Trend Analysis';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, sensorProvider, child) {
        final latestData = sensorProvider.latestSensor;
        final isOnline = sensorProvider.isDeviceOnline;
        final trendData = sensorProvider.trendData;
        
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
              onRefresh: () => sensorProvider.fetchSensorData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan status online yang diperbarui (LOGIKA BARU)
                    _buildHeader(isOnline),
                    const SizedBox(height: 24),
                  
                    // Trend Analysis Card dengan 10 data terbaru
                    _buildTrendAnalysisCard(trendData, isOnline),
                    const SizedBox(height: 16),
                  
                    // Light Intensity Card
                    _buildLightIntensityCard(latestData?['lux'], isOnline),
                    const SizedBox(height: 16),
                  
                    // Sensor Cards Grid 2x2
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildSensorCard(
                          icon: FontAwesomeIcons.droplet,
                          title: 'Humidity',
                          value: isOnline ? (latestData?['hum'] != null 
                              ? '${latestData!['hum']}%'
                              : '--') : '--',
                          minMax: isOnline ? 'Min: 85.1%  Max: 85.3%' : 'Device Offline',
                          color: Colors.blue,
                          isOnline: isOnline,
                        ),
                        _buildSensorCard(
                          icon: FontAwesomeIcons.weightHanging,
                          title: 'Pressure',
                          value: isOnline ? (latestData?['pres'] != null 
                              ? '${latestData!['pres']} hPa'
                              : '--') : '--',
                          minMax: isOnline ? '995.8 hPa - 100.7 hPa' : 'Device Offline',
                          color: Colors.green,
                          isOnline: isOnline,
                        ),
                        _buildSensorCard(
                          icon: FontAwesomeIcons.temperatureHalf,
                          title: 'Temperature',
                          value: isOnline ? (latestData?['temp'] != null 
                              ? '${latestData!['temp']}°C'
                              : '--') : '--',
                          minMax: isOnline ? 'Avg: 29.3°C' : 'Device Offline',
                          color: Colors.orange,
                          isOnline: isOnline,
                        ),
                        _buildAirQualitySmallCard(latestData?['air_clean_perc'], isOnline),
                      ],
                    ),
                  
                    const SizedBox(height: 16),
                  
                    // System Status Card yang diperbarui
                    _buildSystemStatusCard(isOnline),
                  
                    const SizedBox(height: 16),
                  
                    // Fan Control Card
                    _buildFanControlCard(isOnline),
                  
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

  // =================================================================
  // UPDATE PENTING: HEADER LOGIC (Adaptasi Sensors.js)
  // =================================================================
  Widget _buildHeader(bool isOnline) {
    // Kita ambil provider untuk akses property 'lastSeenText' yang baru
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    
    String statusText = isOnline ? 'Online' : 'Offline';
    Color statusColor = isOnline ? Colors.green : Colors.red;
    
    // Logic Pesan Status Dinamis
    String statusReason;
    if (isOnline) {
      statusReason = 'Data Real-time (Updated: ${sensorProvider.lastSeenText})';
    } else {
      statusReason = 'Device Mati/Hilang Sinyal (Last: ${sensorProvider.lastSeenText})';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // Expanded agar teks panjang tidak overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jaringan Sensor Cerdas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mandiri Energi - SDGs Supported',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 4),
                // Menampilkan alasan/waktu spesifik
                Text(
                  statusReason,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysisCard(List<dynamic> trendData, bool isOnline) {
    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Trend Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _selectedTrendType,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  dropdownColor: const Color(0xFF0A1D3C),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  onChanged: isOnline ? (String? newValue) {
                    setState(() {
                      _selectedTrendType = newValue!;
                    });
                  } : null,
                  items: const [
                    DropdownMenuItem(value: 'temperature', child: Text('Temperature')),
                    DropdownMenuItem(value: 'humidity', child: Text('Humidity')),
                    DropdownMenuItem(value: 'air_quality', child: Text('Air Quality')),
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTrendChart(trendData, _selectedTrendType),
            const SizedBox(height: 8),
            Text(
              _getTrendTitle(_selectedTrendType),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '10 Data Terbaru - Real Time',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightIntensityCard(dynamic luxValue, bool isOnline) {
    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withOpacity(0.15),
              Colors.orange.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Light Intensity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                isOnline ? (luxValue != null ? '$luxValue lux' : '-- lux') : '-- lux',
                style: TextStyle(
                  color: isOnline ? Colors.amber : Colors.amber.withOpacity(0.5),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Historical data points - menggunakan 10 data terbaru
            if (isOnline)
              Consumer<SensorProvider>(
                builder: (context, sensorProvider, child) {
                  final recentLightData = sensorProvider.trendData
                      .where((data) => data['lux'] != null)
                      .take(10)
                      .map((data) => data['lux'].toString())
                      .toList();
                  
                  return Wrap(
                    spacing: 8,
                    children: recentLightData.map((value) => _buildDataPoint(value)).toList(),
                  );
                },
              )
            else
              const Text(
                'Device Offline - No recent data',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPoint(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required String minMax,
    required Color color,
    required bool isOnline,
  }) {
    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(isOnline ? 0.15 : 0.08),
              color.withOpacity(isOnline ? 0.05 : 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(isOnline ? 0.3 : 0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isOnline ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: isOnline ? Colors.white : Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              minMax,
              style: TextStyle(
                color: isOnline ? Colors.white60 : Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirQualitySmallCard(dynamic airQuality, bool isOnline) {
    int? airValue = isOnline ? (airQuality != null ? int.tryParse(airQuality.toString()) : null) : null;
    String qualityText = isOnline ? 'Seeking' : 'Offline';
    Color qualityColor = isOnline ? Colors.grey : Colors.grey;

    if (isOnline && airValue != null) {
      if (airValue >= 80) {
        qualityText = 'Excellent';
        qualityColor = Colors.green;
      } else if (airValue >= 60) {
        qualityText = 'Good';
        qualityColor = Colors.lightGreen;
      } else if (airValue >= 40) {
        qualityText = 'Moderate';
        qualityColor = Colors.amber;
      } else if (airValue >= 20) {
        qualityText = 'Poor';
        qualityColor = Colors.orange;
      } else {
        qualityText = 'Very Poor';
        qualityColor = Colors.red;
      }
    }

    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              qualityColor.withOpacity(isOnline ? 0.15 : 0.08),
              qualityColor.withOpacity(isOnline ? 0.05 : 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: qualityColor.withOpacity(isOnline ? 0.3 : 0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: qualityColor.withOpacity(isOnline ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.air, size: 20, color: isOnline ? Colors.cyan : Colors.grey),
                ),
                const SizedBox(width: 8),
                Text(
                  'Air Quality',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isOnline ? (airValue != null ? '$airValue%' : '--%') : '--%',
              style: TextStyle(
                color: isOnline ? Colors.white : Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              qualityText,
              style: TextStyle(
                color: isOnline ? qualityColor : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard(bool isOnline) {
    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSystemInfo('RTC', isOnline ? '23/11/2025 11:21:21' : '--', isOnline),
                _buildSystemInfo('Count', isOnline ? '#33633' : '--', isOnline),
                _buildSystemInfo('Update', isOnline ? 'Online' : 'Offline', isOnline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfo(String label, String value, bool isOnline) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isOnline ? Colors.white70 : Colors.white38,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isOnline ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFanControlCard(bool isOnline) {
    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(isOnline ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(FontAwesomeIcons.fan, size: 20, color: isOnline ? Colors.purple : Colors.grey),
                ),
                const SizedBox(width: 8),
                Text(
                  'Fan Control',
                  style: TextStyle(
                    color: isOnline ? Colors.white : Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_fanLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFanButton(
                    text: 'TURN ON',
                    color: Colors.green,
                    action: 'ON',
                    isOnline: isOnline,
                  ),
                  _buildFanButton(
                    text: 'TURN OFF',
                    color: Colors.red,
                    action: 'OFF',
                    isOnline: isOnline,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFanButton({
    required String text,
    required Color color,
    required String action,
    required bool isOnline,
  }) {
    return SizedBox(
      width: 120,
      height: 40,
      child: ElevatedButton(
        onPressed: isOnline ? () => _controlFan(action) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOnline ? color : color.withOpacity(0.3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}