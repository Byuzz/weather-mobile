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

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, sensorProvider, child) {
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
            child: RefreshIndicator(
              onRefresh: () => sensorProvider.fetchSystemData(),
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
                    
                    // Online Status Indicator
                    _buildOnlineStatusCard(isOnline),
                    
                    const SizedBox(height: 16),
                    
                    // Transceiver Monitor Card
                    _buildTransceiverCard(isOnline),
                    
                    const SizedBox(height: 16),
                    
                    // Gateway Monitor Card
                    _buildGatewayCard(isOnline),
                    
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
        border: Border.all(
          color: isOnline ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.check_circle : Icons.error,
            color: isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Device Online' : 'Device Offline',
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isOnline 
                    ? 'Data terbaru tersedia' 
                    : 'Data lebih dari 1 menit - periksa koneksi device',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransceiverCard(bool isOnline) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sensors, size: 24, color: isOnline ? Colors.white : Colors.white54),
                const SizedBox(width: 12),
                Text(
                  'Transceiver Monitor',
                  style: TextStyle(
                    color: isOnline ? Colors.white : Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // System Health
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Health',
                      style: TextStyle(
                        color: isOnline ? Colors.white70 : Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline ? '69%' : '--',
                      style: TextStyle(
                        color: isOnline ? Colors.white : Colors.white54,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isOnline ? Colors.green : Colors.red),
                  ),
                  child: Text(
                    isOnline ? 'Status: Excellent' : 'Status: Offline',
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Resource Usage
            Text(
              'Resource Usage',
              style: TextStyle(
                color: isOnline ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResourceItem('CPU Load', isOnline ? '240 MHz' : '--', isOnline),
                _buildResourceItem('RAM Usage', isOnline ? 'Free 240 MHz' : '--', isOnline),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // LoRa Connectivity
            Text(
              'LoRa Connectivity',
              style: TextStyle(
                color: isOnline ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Signal Strength',
                  style: TextStyle(
                    color: isOnline ? Colors.white70 : Colors.white38,
                    fontSize: 14,
                  ),
                ),
                Container(
                  width: 100,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: isOnline ? 4 : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: isOnline ? 1 : 10,
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Packet:',
                  style: TextStyle(
                    color: isOnline ? Colors.white70 : Colors.white38,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isOnline ? '22.33.38' : '--',
                  style: TextStyle(
                    color: isOnline ? Colors.white : Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // System Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uptime',
                      style: TextStyle(
                        color: isOnline ? Colors.white70 : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      isOnline ? '2 Jam 41 Menit' : '--',
                      style: TextStyle(
                        color: isOnline ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Process Sent',
                      style: TextStyle(
                        color: isOnline ? Colors.white70 : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      isOnline ? '12.924' : '--',
                      style: TextStyle(
                        color: isOnline ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature',
                      style: TextStyle(
                        color: isOnline ? Colors.white70 : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      isOnline ? '43.7°C' : '--',
                      style: TextStyle(
                        color: isOnline ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(String label, String value, bool isOnline) {
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGatewayCard(bool isOnline) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.router, size: 24, color: isOnline ? Colors.white : Colors.white54),
                const SizedBox(width: 12),
                Text(
                  'Gateway Monitor',
                  style: TextStyle(
                    color: isOnline ? Colors.white : Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Gateway Volume
            Center(
              child: Column(
                children: [
                  Text(
                    'Gateway Volume',
                    style: TextStyle(
                      color: isOnline ? Colors.white70 : Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOnline ? '38m' : '--',
                    style: TextStyle(
                      color: isOnline ? Colors.white : Colors.white54,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isOnline ? '(Store Len: Microsoft)' : 'Device Offline',
                    style: TextStyle(
                      color: isOnline ? Colors.white60 : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // System Specifications
            Text(
              'System Specifications',
              style: TextStyle(
                color: isOnline ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSpecItem('ESP32 Core', isOnline ? '240 MHz' : '--', isOnline),
                _buildSpecItem('Memory', isOnline ? '4 MB' : '--', isOnline),
                _buildSpecItem('LoRa SX1278', isOnline ? 'Rollo' : '--', isOnline),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // MQTT Broker
            Text(
              'MQTT Broker',
              style: TextStyle(
                color: isOnline ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        color: isOnline ? Colors.white70 : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isOnline ? Colors.green : Colors.red),
                      ),
                      child: Text(
                        isOnline ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latency',
                      style: TextStyle(
                        color: isOnline ? Colors.white70 : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      isOnline ? '45 ms' : '--',
                      style: TextStyle(
                        color: isOnline ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Message',
                      style: TextStyle(
                        color: isOnline ? Colors.white70 : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      isOnline ? '22,333.59' : '--',
                      style: TextStyle(
                        color: isOnline ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            
            // Gateway Memory
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gateway Memory Used:',
                  style: TextStyle(
                    color: isOnline ? Colors.white70 : Colors.white38,
                    fontSize: 12,
                  ),
                ),
                Text(
                  isOnline ? '178 KB' : '--',
                  style: TextStyle(
                    color: isOnline ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Updated:',
                  style: TextStyle(
                    color: isOnline ? Colors.white70 : Colors.white38,
                    fontSize: 12,
                  ),
                ),
                Text(
                  isOnline ? '22:33:39' : '--',
                  style: TextStyle(
                    color: isOnline ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, bool isOnline) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isOnline ? Colors.white70 : Colors.white38,
            fontSize: 10,
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
}