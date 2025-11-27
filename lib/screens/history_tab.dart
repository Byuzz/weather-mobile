import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weathertech/providers/sensor_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  
  // State untuk Dropdown
  String _selectedTrendType = 'temperature'; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
      sensorProvider.fetchHistoryData(page: _currentPage, limit: _itemsPerPage);
    });
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
    });
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    sensorProvider.fetchHistoryData(page: page, limit: _itemsPerPage);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, sensorProvider, child) {
        final historyData = sensorProvider.historyData;
        final paginationInfo = sensorProvider.paginationInfo;
        final totalPages = paginationInfo?['totalPages'] ?? 1;
        final totalLogs = paginationInfo?['totalLogs'] ?? 0;
        
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
              onRefresh: () => sensorProvider.fetchHistoryData(page: _currentPage, limit: _itemsPerPage),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text('Historical Data & Analytics', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Data historis dan analisis tren lingkungan', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 24),
                    _buildTotalDataCard(totalLogs),
                    const SizedBox(height: 16),
                    
                    // Chart dengan Dropdown
                    _buildTrendAnalysisCard(historyData),
                    
                    const SizedBox(height: 16),
                    _buildDataLogsCard(historyData, _currentPage, totalPages, totalLogs),
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

  Widget _buildTotalDataCard(int totalLogs) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Total Data Points', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAverageItem('$totalLogs', 'Data Points'),
              _buildAverageItem('29.3°C', 'Avg Temp'),
              _buildAverageItem('88.5%', 'Avg Humidity'),
              _buildAverageItem('15%', 'Avg Air Quality'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAverageItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  // ==========================================
  // CHART LOGIC UNTUK HISTORY (WITH DROPDOWN)
  // ==========================================
  Widget _buildTrendAnalysisCard(List<dynamic> historyData) {
    final trendData = historyData.take(10).toList().reversed.toList();
    List<FlSpot> spots = [];
    List<String> timeLabels = [];

    for (int i = 0; i < trendData.length; i++) {
      final data = trendData[i];
      double val = 0.0;
      
      switch (_selectedTrendType) {
        case 'temperature': val = data['temp']?.toDouble() ?? 0.0; break;
        case 'humidity': val = data['hum']?.toDouble() ?? 0.0; break;
        case 'pressure': val = data['pres']?.toDouble() ?? 0.0; break; // Added Pressure
        case 'air_quality': val = data['air_clean_perc']?.toDouble() ?? 0.0; break;
        case 'light': val = data['lux']?.toDouble() ?? 0.0; break;
      }
      
      spots.add(FlSpot(i.toDouble(), val));

      String rawTime = data['timestamp']?.toString() ?? "";
      if (rawTime.length >= 16) {
        try {
           DateTime dt = DateTime.parse(rawTime);
           timeLabels.add("${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}");
        } catch(e) {
           timeLabels.add("--:--");
        }
      } else {
        timeLabels.add("--:--");
      }
    }

    double minY = spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) : 0;
    double maxY = spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) : 10;
    double buffer = (maxY - minY) * 0.2;
    if (buffer == 0) buffer = 1.0;
    minY -= buffer;
    maxY += buffer;
    
    double interval = (maxY - minY) / 4; 
    if (interval == 0) interval = 1.0;
    
    Color lineColor = _getTrendColor(_selectedTrendType);

    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CARD DENGAN DROPDOWN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trend Analysis', 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              
              // DROPDOWN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24)
                ),
                child: DropdownButton<String>(
                  value: _selectedTrendType,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  dropdownColor: const Color(0xFF152A5E),
                  underline: Container(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTrendType = newValue;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'temperature', child: Row(children: [Icon(Icons.thermostat, size: 14, color: Colors.orange), SizedBox(width: 8), Text('Suhu')])),
                    DropdownMenuItem(value: 'humidity', child: Row(children: [Icon(Icons.water_drop, size: 14, color: Colors.blue), SizedBox(width: 8), Text('Kelembaban')])),
                    DropdownMenuItem(value: 'pressure', child: Row(children: [Icon(Icons.speed, size: 14, color: Colors.deepPurple), SizedBox(width: 8), Text('Tekanan')])), // Opsi Pressure
                    DropdownMenuItem(value: 'air_quality', child: Row(children: [Icon(Icons.air, size: 14, color: Colors.green), SizedBox(width: 8), Text('Udara')])),
                    DropdownMenuItem(value: 'light', child: Row(children: [Icon(Icons.lightbulb, size: 14, color: Colors.amber), SizedBox(width: 8), Text('Cahaya')])),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: true,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                  getDrawingVerticalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1, 
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < timeLabels.length) {
                          if (index % 2 == 0 || index == timeLabels.length - 1) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(timeLabels[index], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                            );
                          }
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white54, fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.white10)),
                minY: minY,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        int index = barSpot.x.toInt();
                        String time = (index >= 0 && index < timeLabels.length) ? timeLabels[index] : "";
                        return LineTooltipItem('$time\n', const TextStyle(color: Colors.white70, fontSize: 10), children: [TextSpan(text: '${barSpot.y.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]);
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(radius: 4, color: lineColor, strokeWidth: 1, strokeColor: Colors.white);
                    }),
                    belowBarData: BarAreaData(show: true, color: lineColor.withOpacity(0.15)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_getTrendTitle(_selectedTrendType), style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Text('10 Data Terbaru', style: TextStyle(color: Colors.white60, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getTrendColor(String type) {
    switch (type) {
      case 'temperature': return Colors.orange;
      case 'humidity': return Colors.blue;
      case 'pressure': return Colors.deepPurple; // Warna Pressure
      case 'air_quality': return Colors.green;
      case 'light': return Colors.amber;
      default: return Colors.white;
    }
  }

  String _getTrendTitle(String type) {
    switch (type) {
      case 'temperature': return 'Temperature Trend (°C)';
      case 'humidity': return 'Humidity Trend (%)';
      case 'pressure': return 'Pressure Trend (hPa)'; // Judul Pressure
      case 'air_quality': return 'Air Quality Trend (%)';
      case 'light': return 'Light Intensity Trend (lux)';
      default: return 'Trend Analysis';
    }
  }

  Widget _buildDataLogsCard(List<dynamic> data, int currentPage, int totalPages, int totalLogs) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detailed Data Logs', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Halaman $currentPage dari $totalPages', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Total: $totalLogs data', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 700, 
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: _HeaderCell('Timestamp')),
                      Expanded(child: _HeaderCell('Temp (°C)')),
                      Expanded(child: _HeaderCell('Hum (%)')),
                      Expanded(child: _HeaderCell('Press (hPa)')),
                      Expanded(child: _HeaderCell('Lux')),
                      Expanded(child: _HeaderCell('Air (%)')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  if (data.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No data available', style: TextStyle(color: Colors.white70))))
                  else
                    Column(
                      children: data.map<Widget>((log) => _buildDataLogRow(
                        timestamp: log['timestamp']?.toString() ?? '--',
                        temp: log['temp']?.toString() ?? '--',
                        hum: log['hum']?.toString() ?? '--',
                        press: log['pres']?.toString() ?? '--',
                        lux: log['lux']?.toString() ?? '--',
                        air: log['air_clean_perc']?.toString() ?? '--',
                      )).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          _buildPaginationControls(currentPage, totalPages),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int currentPage, int totalPages) {
    const int windowSize = 5;
    int startPage;
    if (totalPages <= windowSize) {
      startPage = 1;
    } else {
      startPage = currentPage - (windowSize ~/ 2);
      if (startPage < 1) startPage = 1;
      if (startPage + windowSize - 1 > totalPages) startPage = totalPages - windowSize + 1;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1 ? () => _loadPage(currentPage - 1) : null,
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          color: currentPage > 1 ? Colors.white : Colors.white54,
        ),
        Row(
          children: List.generate(
            totalPages > windowSize ? windowSize : totalPages, 
            (index) {
              final int displayPage = startPage + index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => _loadPage(displayPage),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: currentPage == displayPage ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: currentPage == displayPage ? Colors.blue : Colors.white30),
                    ),
                    child: Center(
                      child: Text(
                        '$displayPage',
                        style: TextStyle(color: currentPage == displayPage ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        IconButton(
          onPressed: currentPage < totalPages ? () => _loadPage(currentPage + 1) : null,
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          color: currentPage < totalPages ? Colors.white : Colors.white54,
        ),
      ],
    );
  }

  Widget _buildDataLogRow({required String timestamp, required String temp, required String hum, required String press, required String lux, required String air}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text(timestamp.length > 16 ? timestamp.substring(0, 16) : timestamp, style: const TextStyle(color: Colors.white, fontSize: 10))),
          Expanded(child: Text('$temp °C', style: const TextStyle(color: Colors.white, fontSize: 10))),
          Expanded(child: Text('$hum %', style: const TextStyle(color: Colors.white, fontSize: 10))),
          Expanded(child: Text(press, style: const TextStyle(color: Colors.white, fontSize: 10))),
          Expanded(child: Text(lux, style: const TextStyle(color: Colors.white, fontSize: 10))),
          Expanded(child: Text('$air%', style: const TextStyle(color: Colors.white, fontSize: 10))),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold));
  }
}

class _buildDataLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _buildDataLabel(this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}