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
  // State untuk Dropdown Chart
  String _selectedTrendType = 'temperature';

  // =================================================================
  // A. HELPER FUNCTIONS
  // =================================================================

  // 1. Parsing Tanggal dari format RTC atau ISO
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
  
  // 2. Format Jam Saja (HH:mm:ss)
  String _formatTimeOnly(String rawTime) {
    DateTime? dt = parseRtcTime(rawTime);
    if (dt != null) {
      return "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}:${dt.second.toString().padLeft(2,'0')}";
    }
    if (rawTime.length > 10 && rawTime.contains(' ')) {
       return rawTime.split(' ').last;
    }
    return rawTime; 
  }

  // 3. Hitung Min/Max Data
  String _calculateMinMax(List<dynamic> trendData, String key, String unit) {
    if (trendData.isEmpty) return 'Min: -- Max: --';
    
    List<double> values = [];
    for (var item in trendData) {
      if (item[key] != null) {
        double? val = double.tryParse(item[key].toString());
        if (val != null && val != 0) { 
          values.add(val);
        }
      }
    }

    if (values.isEmpty) return 'Min: -- Max: --';

    values.sort();
    double min = values.first;
    double max = values.last;

    return 'Min: ${min.toStringAsFixed(1)}$unit  Max: ${max.toStringAsFixed(1)}$unit';
  }

  // =================================================================
  // B. MAIN UI BUILDER
  // =================================================================

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
                    // 1. HEADER
                    _buildHeader(isOnline),
                    
                    const SizedBox(height: 24),
                    
                    // 2. CHART (Trend Analysis)
                    _buildTrendAnalysisCard(trendData, isOnline),
                    
                    const SizedBox(height: 16),
                    
                    // 3. LIGHT INTENSITY CARD
                    _buildLightIntensityCard(latestData?['lux'], isOnline),
                    
                    const SizedBox(height: 16),
                    
                    // 4. SENSOR GRID
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
                          value: isOnline ? (latestData?['hum'] != null ? '${double.tryParse(latestData!['hum'].toString())?.toStringAsFixed(1)}%' : '--') : '--', 
                          minMax: isOnline ? _calculateMinMax(trendData, 'hum', '%') : 'Offline', 
                          color: Colors.blue, 
                          isOnline: isOnline
                        ),
                        _buildSensorCard(
                          icon: FontAwesomeIcons.weightHanging, 
                          title: 'Pressure', 
                          value: isOnline ? (latestData?['pres'] != null ? '${double.tryParse(latestData!['pres'].toString())?.toStringAsFixed(1)} hPa' : '--') : '--', 
                          minMax: isOnline ? _calculateMinMax(trendData, 'pres', ' hPa') : 'Offline', 
                          color: Colors.green, 
                          isOnline: isOnline
                        ),
                        _buildSensorCard(
                          icon: FontAwesomeIcons.temperatureHalf, 
                          title: 'Temperature', 
                          value: isOnline ? (latestData?['temp'] != null ? '${double.tryParse(latestData!['temp'].toString())?.toStringAsFixed(1)}°C' : '--') : '--', 
                          minMax: isOnline ? _calculateMinMax(trendData, 'temp', '°C') : 'Offline', 
                          color: Colors.orange, 
                          isOnline: isOnline
                        ),
                        _buildAirQualitySmallCard(latestData?['air_clean_perc'], isOnline),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 5. SYSTEM STATUS
                    _buildSystemStatusCard(latestData, isOnline),
                    
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
  // C. WIDGET COMPONENTS
  // =================================================================

  Widget _buildHeader(bool isOnline) {
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    final latestData = sensorProvider.latestSensor;
    
    String statusText = isOnline ? 'Online' : 'Offline';
    Color statusColor = isOnline ? Colors.green : Colors.red;
    
    String timeDisplay = "--:--:--";
    if (latestData != null) {
        String rawTime = latestData['rtc_time']?.toString() ?? latestData['timestamp']?.toString() ?? "";
        timeDisplay = _formatTimeOnly(rawTime);
    }
    
    String statusReason = isOnline ? 'Updated: $timeDisplay' : 'Last: $timeDisplay';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: statusColor.withOpacity(0.3))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Jaringan Sensor Cerdas', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text('Mandiri Energi - SDGs Supported', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(statusReason, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor)),
            child: Row(children: [
              Icon(isOnline ? Icons.wifi : Icons.wifi_off, size: 16, color: statusColor), 
              const SizedBox(width: 6), 
              Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold))
            ]),
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
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('Trend Analysis', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8), 
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)), 
                  child: DropdownButton<String>(
                    value: _selectedTrendType, 
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white), 
                    dropdownColor: const Color(0xFF152A5E), 
                    underline: Container(), 
                    style: const TextStyle(color: Colors.white, fontSize: 12), 
                    onChanged: isOnline ? (String? newValue) { setState(() { _selectedTrendType = newValue!; }); } : null, 
                    items: const [
                      DropdownMenuItem(value: 'temperature', child: Text('Temp')), 
                      DropdownMenuItem(value: 'humidity', child: Text('Humid')), 
                      DropdownMenuItem(value: 'pressure', child: Text('Press')), 
                      DropdownMenuItem(value: 'air_quality', child: Text('Air')), 
                      DropdownMenuItem(value: 'light', child: Text('Light'))
                    ]
                  )
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTrendChart(trendData, _selectedTrendType),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_getTrendTitle(_selectedTrendType), style: const TextStyle(color: Colors.white70, fontSize: 12)), 
              Row(children: [
                Container(width:8, height:8, decoration: BoxDecoration(color: _getTrendColor(_selectedTrendType), shape: BoxShape.circle)), 
                const SizedBox(width: 4), 
                const Text("Real-time", style: TextStyle(color: Colors.white54, fontSize: 10))
              ])
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<dynamic> trendData, String type) {
    if (trendData.isEmpty) {
      return Container(height: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('No trend data available', style: TextStyle(color: Colors.white54))));
    }
    final displayData = trendData.take(10).toList().reversed.toList();
    List<FlSpot> spots = [];
    List<String> timeLabels = [];
    for (int i = 0; i < displayData.length; i++) {
      double value = 0.0;
      switch (type) {
        case 'temperature': value = displayData[i]['temp']?.toDouble() ?? 0.0; break;
        case 'humidity': value = displayData[i]['hum']?.toDouble() ?? 0.0; break;
        case 'pressure': value = displayData[i]['pres']?.toDouble() ?? 0.0; break;
        case 'air_quality': value = displayData[i]['air_clean_perc']?.toDouble() ?? 0.0; break;
        case 'light': value = displayData[i]['lux']?.toDouble() ?? 0.0; break;
      }
      spots.add(FlSpot(i.toDouble(), value));
      String rawTime = displayData[i]['rtc_time']?.toString() ?? displayData[i]['timestamp']?.toString() ?? "";
      DateTime? dt = parseRtcTime(rawTime);
      if (dt != null) { timeLabels.add("${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}"); } else { timeLabels.add("--:--"); }
    }
    double minY = spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) : 0;
    double maxY = spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) : 10;
    double buffer = (maxY - minY) * 0.2;
    if (buffer == 0) buffer = 1.0; 
    minY -= buffer; maxY += buffer;
    double interval = (maxY - minY) / 4; 
    if (interval == 0) interval = 1.0;
    Color lineColor = _getTrendColor(type);

    return Container(
      height: 220,
      padding: const EdgeInsets.only(right: 16, left: 0, bottom: 0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: true, horizontalInterval: interval, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1), getDrawingVerticalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1)),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < timeLabels.length) {
                if (index % 2 == 0 || index == timeLabels.length - 1) { return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(timeLabels[index], style: const TextStyle(color: Colors.white54, fontSize: 10))); }
              }
              return const SizedBox();
            })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: interval, reservedSize: 40, getTitlesWidget: (value, meta) { return Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white54, fontSize: 10)); })),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.white10)),
          minY: minY, maxY: maxY,
          lineTouchData: LineTouchData(enabled: true, touchTooltipData: LineTouchTooltipData(tooltipBgColor: Colors.blueGrey.withOpacity(0.9), getTooltipItems: (List<LineBarSpot> touchedBarSpots) { return touchedBarSpots.map((barSpot) { int index = barSpot.x.toInt(); String time = (index >= 0 && index < timeLabels.length) ? timeLabels[index] : ""; return LineTooltipItem('$time\n', const TextStyle(color: Colors.white70, fontSize: 10), children: [TextSpan(text: '${barSpot.y.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]); }).toList(); })),
          lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: lineColor, barWidth: 3, isStrokeCapRound: true, dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) { return FlDotCirclePainter(radius: 3, color: lineColor, strokeWidth: 1, strokeColor: Colors.white); }), belowBarData: BarAreaData(show: true, color: lineColor.withOpacity(0.15)))],
        ),
      ),
    );
  }

  Color _getTrendColor(String type) {
    switch (type) {
      case 'temperature': return Colors.orange;
      case 'humidity': return Colors.blue;
      case 'pressure': return Colors.deepPurple;
      case 'air_quality': return Colors.green;
      case 'light': return Colors.amber;
      default: return Colors.white;
    }
  }

  String _getTrendTitle(String type) {
    switch (type) {
      case 'temperature': return 'Temperature Trend (°C)';
      case 'humidity': return 'Humidity Trend (%)';
      case 'pressure': return 'Pressure Trend (hPa)';
      case 'air_quality': return 'Air Quality Trend (%)';
      case 'light': return 'Light Intensity Trend (lux)';
      default: return 'Trend Analysis';
    }
  }

  Widget _buildLightIntensityCard(dynamic luxValue, bool isOnline) {
    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.amber.withOpacity(0.15), Colors.orange.withOpacity(0.1)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1)),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.lightbulb, color: Colors.amber, size: 24)), const SizedBox(width: 12), const Text('Light Intensity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            Center(child: Text(isOnline ? (luxValue != null ? '$luxValue lux' : '-- lux') : '-- lux', style: TextStyle(color: isOnline ? Colors.amber : Colors.amber.withOpacity(0.5), fontSize: 32, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            if (isOnline) Consumer<SensorProvider>(builder: (context, sensorProvider, child) { final recentLightData = sensorProvider.trendData.where((data) => data['lux'] != null).take(10).map((data) => data['lux'].toString()).toList(); return Wrap(spacing: 8, children: recentLightData.map((value) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12)))).toList()); }) else const Text('Device Offline - No recent data', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
      ),
    );
  }

  Widget _buildSensorCard({required IconData icon, required String title, required String value, required String minMax, required Color color, required bool isOnline}) {
    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(isOnline ? 0.15 : 0.08), color.withOpacity(isOnline ? 0.05 : 0.03)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(isOnline ? 0.3 : 0.1), width: 1)),
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(isOnline ? 0.2 : 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 20, color: color)), const SizedBox(width: 8), Text(title, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: isOnline ? Colors.white : Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(minMax, style: TextStyle(color: isOnline ? Colors.white60 : Colors.white38, fontSize: 10)),
          ]),
      ),
    );
  }

  Widget _buildAirQualitySmallCard(dynamic airQuality, bool isOnline) {
    int? airValue = isOnline ? (airQuality != null ? int.tryParse(airQuality.toString()) : null) : null;
    String qualityText = isOnline ? 'Seeking' : 'Offline';
    Color qualityColor = isOnline ? Colors.grey : Colors.grey;
    if (isOnline && airValue != null) { if (airValue >= 80) { qualityText = 'Excellent'; qualityColor = Colors.green; } else if (airValue >= 60) { qualityText = 'Good'; qualityColor = Colors.lightGreen; } else if (airValue >= 40) { qualityText = 'Moderate'; qualityColor = Colors.amber; } else if (airValue >= 20) { qualityText = 'Poor'; qualityColor = Colors.orange; } else { qualityText = 'Very Poor'; qualityColor = Colors.red; } }
    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [qualityColor.withOpacity(isOnline ? 0.15 : 0.08), qualityColor.withOpacity(isOnline ? 0.05 : 0.03)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: qualityColor.withOpacity(isOnline ? 0.3 : 0.1), width: 1)),
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: qualityColor.withOpacity(isOnline ? 0.2 : 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.air, size: 20, color: isOnline ? Colors.cyan : Colors.grey)), const SizedBox(width: 8), Text('Air Quality', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            Text(isOnline ? (airValue != null ? '$airValue%' : '--%') : '--%', style: TextStyle(color: isOnline ? Colors.white : Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(qualityText, style: TextStyle(color: isOnline ? qualityColor : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
          ]),
      ),
    );
  }

  Widget _buildSystemStatusCard(Map<String, dynamic>? data, bool isOnline) {
    String rtcTime = '--';
    String dataCount = '--';

    if (isOnline && data != null) {
      String rawTime = data['rtc_time']?.toString() ?? data['timestamp']?.toString() ?? '--';
      rtcTime = rawTime; 
      dataCount = '#${data['id']?.toString() ?? data['eeprom_count']?.toString() ?? '--'}';
    }

    return Opacity(
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Status System', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _buildSystemInfo('RTC', rtcTime, isOnline),
                _buildSystemInfo('Count', dataCount, isOnline),
                _buildSystemInfo('Update', isOnline ? 'Online' : 'Offline', isOnline),
              ]),
          ]),
      ),
    );
  }

  Widget _buildSystemInfo(String label, String value, bool isOnline) {
    return Column(children: [Text(label, style: TextStyle(color: isOnline ? Colors.white70 : Colors.white38, fontSize: 12)), const SizedBox(height: 4), Text(value, style: TextStyle(color: isOnline ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold))]);
  }
}