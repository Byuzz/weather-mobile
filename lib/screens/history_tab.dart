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
                    const Text(
                      'Historical Data & Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Data historis dan analisis tren lingkungan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Total Data Points Card
                    _buildTotalDataCard(totalLogs),
                    
                    const SizedBox(height: 16),
                    
                    // Trend Analysis Chart
                    _buildTrendAnalysisCard(historyData),
                    
                    const SizedBox(height: 16),
                    
                    // Detailed Data Logs
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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Total Data Points',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
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
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendAnalysisCard(List<dynamic> historyData) {
    final trendData = historyData.take(10).toList();
    
    List<FlSpot> spots = [];
    for (int i = 0; i < trendData.length; i++) {
      final data = trendData[i];
      spots.add(FlSpot(
        i.toDouble(), 
        data['temp']?.toDouble() ?? 0.0
      ));
    }

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
          const Text(
            'Trend Analysis - 10 Data Terbaru',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2 : 0,
                maxY: spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2 : 40,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temperature Trend (°C)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                '10 Data Points Terbaru',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataLogsCard(List<dynamic> data, int currentPage, int totalPages, int totalLogs) {
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
          const Text(
            'Detailed Data Logs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Pagination Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Halaman $currentPage dari $totalPages',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                'Total: $totalLogs data',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Table Header + Data dengan Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 700, 
              child: Column(
                children: [
                  // Table Header
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
                  
                  // Data Rows
                  if (data.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
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
          
          // Pagination Controls
          _buildPaginationControls(currentPage, totalPages),
          
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          
          // Data Labels
          const Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildDataLabel('Aktivity', Colors.blue),
              _buildDataLabel('Sensitivity', Colors.green),
              _buildDataLabel('Fidelity', Colors.orange),
              _buildDataLabel('Risk', Colors.red),
              _buildDataLabel('Value', Colors.purple),
              _buildDataLabel('Total', Colors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // FIX: LOGIKA PAGINATION YANG DINAMIS (Sliding Window)
  // =========================================================================
  Widget _buildPaginationControls(int currentPage, int totalPages) {
    // Kita ingin menampilkan 5 halaman sekaligus
    const int windowSize = 5;
    
    // Tentukan halaman awal (startPage)
    int startPage;
    
    if (totalPages <= windowSize) {
      // Jika total halaman sedikit, mulai dari 1
      startPage = 1;
    } else {
      // Jika halaman banyak, coba posisikan halaman saat ini di tengah
      // currentPage - 2
      startPage = currentPage - (windowSize ~/ 2);
      
      // Koreksi batas bawah (tidak boleh kurang dari 1)
      if (startPage < 1) {
        startPage = 1;
      }
      
      // Koreksi batas atas (jangan sampai startPage + 5 melebihi totalPages)
      if (startPage + windowSize - 1 > totalPages) {
        startPage = totalPages - windowSize + 1;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Button
        IconButton(
          onPressed: currentPage > 1 ? () => _loadPage(currentPage - 1) : null,
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          color: currentPage > 1 ? Colors.white : Colors.white54,
        ),
        
        // Page Numbers (Dinamis berdasarkan startPage)
        Row(
          children: List.generate(
            // Tampilkan jumlah tombol sesuai windowSize atau totalPages jika lebih kecil
            totalPages > windowSize ? windowSize : totalPages, 
            (index) {
              // Ini kuncinya: displayPage bukan index + 1, tapi startPage + index
              final int displayPage = startPage + index;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => _loadPage(displayPage),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: currentPage == displayPage 
                          ? Colors.blue.withOpacity(0.3) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: currentPage == displayPage ? Colors.blue : Colors.white30,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$displayPage',
                        style: TextStyle(
                          color: currentPage == displayPage ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Next Button
        IconButton(
          onPressed: currentPage < totalPages ? () => _loadPage(currentPage + 1) : null,
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          color: currentPage < totalPages ? Colors.white : Colors.white54,
        ),
      ],
    );
  }

  Widget _buildDataLogRow({
    required String timestamp,
    required String temp,
    required String hum,
    required String press,
    required String lux,
    required String air,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              timestamp.length > 16 ? timestamp.substring(0, 16) : timestamp,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
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

// Helper Widgets
class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
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
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}