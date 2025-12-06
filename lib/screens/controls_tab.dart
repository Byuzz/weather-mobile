import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weathertech/providers/sensor_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ControlsTab extends StatefulWidget {
  const ControlsTab({super.key});

  @override
  State<ControlsTab> createState() => _ControlsTabState();
}

class _ControlsTabState extends State<ControlsTab> {
  // Local state untuk slider (agar UI responsif saat digeser)
  double _localFanThres = 30.0;
  double _localLedThres = 20.0;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final provider = Provider.of<SensorProvider>(context, listen: false);
      provider.fetchSettings().then((_) {
        setState(() {
          _localFanThres = provider.fanThreshold;
          _localLedThres = provider.ledThreshold;
        });
      });
      _isInit = false;
    }
  }

  Future<void> _saveConfig() async {
    final provider = Provider.of<SensorProvider>(context, listen: false);
    bool success = await provider.saveSettings(_localFanThres, _localLedThres);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Setting tersimpan & dikirim ke alat!' : 'Gagal menyimpan setting'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // Helper Logic Button Control
  Future<void> _triggerAction(String type, String action) async {
    final provider = Provider.of<SensorProvider>(context, listen: false);
    bool success;
    if (type == 'FAN') {
      success = await provider.controlFan(action);
    } else {
      success = await provider.controlLed(action);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '$type set to $action' : 'Failed'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SensorProvider>(context);
    final isOnline = provider.isDeviceOnline;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1D3C), Color(0xFF152A5E), Color(0xFF1E3A8A)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Device Controls', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Kendali Manual & Konfigurasi Otomatis', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),

              // 1. KARTU KIPAS
              _buildControlCard(
                title: "Fan Cooling System",
                icon: FontAwesomeIcons.fan,
                iconColor: Colors.purple,
                isOnline: isOnline,
                onTapAction: (act) => _triggerAction('FAN', act),
                thresholdLabel: "Batas Suhu Panas (ON > X)",
                sliderValue: _localFanThres,
                sliderColor: Colors.redAccent,
                onSliderChanged: (val) => setState(() => _localFanThres = val),
              ),

              const SizedBox(height: 20),

              // 2. KARTU LED (HEATER)
              _buildControlCard(
                title: "LED Heater System",
                icon: Icons.lightbulb,
                iconColor: Colors.amber,
                isOnline: isOnline,
                onTapAction: (act) => _triggerAction('LED', act),
                thresholdLabel: "Batas Suhu Dingin (ON < X)",
                sliderValue: _localLedThres,
                sliderColor: Colors.blueAccent,
                onSliderChanged: (val) => setState(() => _localLedThres = val),
              ),

              const SizedBox(height: 24),

              // 3. TOMBOL SAVE GLOBAL
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (isOnline && !provider.isSaving) ? _saveConfig : null,
                  icon: provider.isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Icon(Icons.save),
                  label: Text(provider.isSaving ? "Menyimpan..." : "SIMPAN KONFIGURASI OTOMATIS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isOnline,
    required Function(String) onTapAction,
    required String thresholdLabel,
    required double sliderValue,
    required Color sliderColor,
    required Function(double) onSliderChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 24)),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),

          // Tombol Manual
          const Text("Mode Operasi:", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildBtn("ON", Colors.green, () => onTapAction("ON"), isOnline, Icons.power_settings_new)),
              const SizedBox(width: 8),
              Expanded(child: _buildBtn("AUTO", Colors.blue, () => onTapAction("AUTO"), isOnline, Icons.hdr_auto)),
              const SizedBox(width: 8),
              Expanded(child: _buildBtn("OFF", Colors.red, () => onTapAction("OFF"), isOnline, Icons.power_off)),
            ],
          ),
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),

          // Slider Threshold
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(thresholdLabel, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text("${sliderValue.toStringAsFixed(1)}°C", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: sliderColor,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              overlayColor: sliderColor.withOpacity(0.2),
              valueIndicatorColor: sliderColor,
            ),
            child: Slider(
              value: sliderValue,
              min: 0.0,
              max: 50.0,
              divisions: 100,
              label: sliderValue.toStringAsFixed(1),
              onChanged: isOnline ? onSliderChanged : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(String text, Color color, VoidCallback onTap, bool isOnline, IconData icon) {
    return ElevatedButton(
      onPressed: isOnline ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: color.withOpacity(0.5))),
        elevation: 0,
      ),
      child: Column(
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}