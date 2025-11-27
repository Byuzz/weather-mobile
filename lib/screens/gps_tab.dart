import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:weathertech/providers/sensor_provider.dart';

class GpsTab extends StatefulWidget {
  const GpsTab({super.key});

  @override
  State<GpsTab> createState() => _GpsTabState();
}

class _GpsTabState extends State<GpsTab> {
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
        final gpsData = sensorProvider.latestGPS;
        final isOnline = sensorProvider.isDeviceOnline;
        final coordinates = gpsData != null 
            ? LatLng(gpsData['latitude'], gpsData['longitude'])
            : const LatLng(-8.178840, 113.726000);

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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Pemantauan Lokasi GPS',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time location tracking dengan GPS',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Current Coordinates Card
                  _buildCoordinatesCard(gpsData, isOnline),
                  
                  const SizedBox(height: 16),
                  
                  // Signal Status Card
                  _buildSignalStatusCard(isOnline),
                  
                  const SizedBox(height: 16),
                  
                  // Map
                  Expanded(
                    child: Opacity(
                      opacity: isOnline ? 1.0 : 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FlutterMap(
                            options: MapOptions(
                              center: coordinates,
                              zoom: 15.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c'],
                                userAgentPackageName: 'com.example.weathertech',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: coordinates,
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.location_pin,
                                      color: isOnline ? Colors.red : Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoordinatesCard(Map<String, dynamic>? gpsData, bool isOnline) {
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
                Icon(Icons.gps_fixed, size: 24, color: isOnline ? Colors.white : Colors.white54),
                const SizedBox(width: 12),
                Text(
                  'Koordinat Saat ini',
                  style: TextStyle(
                    color: isOnline ? Colors.white : Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude',
                      style: TextStyle(
                        color: isOnline ? Colors.white70 : Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      isOnline ? (gpsData?['latitude']?.toStringAsFixed(6) ?? '-8.178840') : '--',
                      style: TextStyle(
                        color: isOnline ? Colors.white : Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Longitude',
                      style: TextStyle(
                        color: isOnline ? Colors.white70 : Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      isOnline ? (gpsData?['longitude']?.toStringAsFixed(6) ?? '113.726000') : '--',
                      style: TextStyle(
                        color: isOnline ? Colors.white : Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOnline ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Text(
                isOnline ? 'GPS Active' : 'GPS Offline',
                style: TextStyle(
                  color: isOnline ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalStatusCard(bool isOnline) {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status:',
                  style: TextStyle(
                    color: isOnline ? Colors.white70 : Colors.white38,
                    fontSize: 14,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isOnline ? Colors.green : Colors.red),
                  ),
                  child: Text(
                    isOnline ? 'Terkunci (SD)' : 'Offline',
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.red,
                      fontSize: 12,
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
                  'Satellite:',
                  style: TextStyle(
                    color: isOnline ? Colors.white70 : Colors.white38,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? 'Unknown' : '--',
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
                  'Akurasi:',
                  style: TextStyle(
                    color: isOnline ? Colors.white70 : Colors.white38,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? '~2.5 Meter' : '--',
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
      ),
    );
  }
}