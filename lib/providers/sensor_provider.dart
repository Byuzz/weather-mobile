import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weathertech/services/api_service.dart';

class SensorProvider extends ChangeNotifier {
  List<dynamic> _sensorData = [];
  List<dynamic> _sensorSystemData = [];
  List<dynamic> _gatewaySystemData = [];
  List<dynamic> _historyData = [];
  List<dynamic> _trendData = [];
  Map<String, dynamic>? _paginationInfo;
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  DateTime? _lastFetchTime;
  
  // [BARU] Variabel Settings
  double _fanThreshold = 30.0;
  double _ledThreshold = 20.0;
  bool _isSaving = false;
  
  // Getters
  List<dynamic> get sensorData => _sensorData;
  List<dynamic> get sensorSystemData => _sensorSystemData;
  List<dynamic> get gatewaySystemData => _gatewaySystemData;
  List<dynamic> get historyData => _historyData;
  List<dynamic> get trendData => _trendData;
  Map<String, dynamic>? get paginationInfo => _paginationInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // [BARU] Getters Settings
  double get fanThreshold => _fanThreshold;
  double get ledThreshold => _ledThreshold;
  bool get isSaving => _isSaving;
  
  // LOGIKA ONLINE/OFFLINE
  bool get isDeviceOnline {
    if (_sensorData.isEmpty) return false;
    try {
      final latest = _sensorData.first;
      if (latest['timestamp'] == null) return false;
      final dataTime = DateTime.parse(latest['timestamp'].toString());
      final now = DateTime.now();
      final diffSeconds = now.difference(dataTime).inSeconds.abs();
      return diffSeconds <= 70; 
    } catch (e) {
      return false;
    }
  }
  
  String get lastSeenText {
    if (_sensorData.isEmpty || _sensorData.first['timestamp'] == null) return "Never";
    try {
      final dataTime = DateTime.parse(_sensorData.first['timestamp'].toString());
      return "${dataTime.hour.toString().padLeft(2, '0')}:${dataTime.minute.toString().padLeft(2, '0')}:${dataTime.second.toString().padLeft(2, '0')}";
    } catch (e) {
      return "--:--:--";
    }
  }

  Map<String, dynamic>? get latestSensor {
    if (_sensorData.isNotEmpty) return _sensorData.first;
    return null;
  }
  
  Map<String, dynamic>? get latestGPS {
    if (_sensorSystemData.isNotEmpty) {
      final data = _sensorSystemData.first;
      if (data['latitude'] != null && data['longitude'] != null) {
        return {
          'latitude': double.tryParse(data['latitude'].toString()) ?? 0.0,
          'longitude': double.tryParse(data['longitude'].toString()) ?? 0.0,
        };
      }
    }
    return null;
  }

  // --- FETCHING DATA ---

  Future<void> fetchSensorData() async {
    try {
      _sensorData = await ApiService.getLatestSensorData();
      _lastFetchTime = DateTime.now(); 
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchTrendData() async {
    try {
      final history = await ApiService.getHistoryData();
      _trendData = history.take(10).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch trend data: $e';
    }
  }

  Future<void> fetchHistoryData({int page = 1, int limit = 10}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final allHistory = await ApiService.getHistoryData();
      final totalLogs = allHistory.length;
      final totalPages = (totalLogs / limit).ceil();
      
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      
      _historyData = allHistory.sublist(
        startIndex.clamp(0, totalLogs), 
        endIndex.clamp(0, totalLogs)
      );
      
      _paginationInfo = {
        'currentPage': page,
        'totalPages': totalPages,
        'totalLogs': totalLogs,
        'hasNext': page < totalPages,
        'hasPrev': page > 1,
      };
    } catch (e) {
      _error = 'Failed to fetch history data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // [UPDATE] Fetch Settings juga di awal
      await fetchSettings();
      
      final results = await Future.wait([
        ApiService.getLatestSensorData(),
        ApiService.getSensorSystemData(),
        ApiService.getGatewaySystemData(),
        ApiService.getHistoryData(),
      ]);
      
      _sensorData = results[0];
      _sensorSystemData = results[1];
      _gatewaySystemData = results[2];
      _historyData = results[3].take(50).toList(); 
      _trendData = results[3].take(10).toList(); 
      _lastFetchTime = DateTime.now(); 
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchSystemData() async {
    try {
      final results = await Future.wait([
        ApiService.getSensorSystemData(),
        ApiService.getGatewaySystemData(),
      ]);
      
      _sensorSystemData = results[0];
      _gatewaySystemData = results[1];
      _lastFetchTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // --- CONTROLS ---

  Future<bool> controlFan(String action) async {
    try {
      final response = await ApiService.controlFan(action);
      if (response['status'] == 'success') {
        _lastFetchTime = DateTime.now();
        notifyListeners();
      }
      return response['status'] == 'success';
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> controlLed(String action) async {
    try {
      final response = await ApiService.controlLed(action);
      notifyListeners();
      return response['status'] == 'success';
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================================================
  // [BARU] SETTINGS LOGIC
  // ==================================================
  
  Future<void> fetchSettings() async {
    try {
      final data = await ApiService.getSettings();
      _fanThreshold = double.tryParse(data['fan'].toString()) ?? 30.0;
      _ledThreshold = double.tryParse(data['led'].toString()) ?? 20.0;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching settings: $e");
    }
  }

  Future<bool> saveSettings(double newFan, double newLed) async {
    _isSaving = true;
    notifyListeners();
    try {
      final response = await ApiService.updateSettings(newFan, newLed);
      if (response['status'] == 'success') {
        _fanThreshold = newFan;
        _ledThreshold = newLed;
        _isSaving = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = "Gagal menyimpan setting: $e";
    }
    _isSaving = false;
    notifyListeners();
    return false;
  }
  
  // --- POLLING ---

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) { 
      fetchSensorData();
      if (timer.tick % 3 == 0) { 
        fetchTrendData();
      }
    });
  }
  
  void stopPolling() {
    _pollingTimer?.cancel();
  }
  
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}