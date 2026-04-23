// lib/screens/dashboard_screen.dart
// System Dashboard with Live Stats

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/colors.dart';
import '../services/device/system_monitor.dart';
import '../widgets/glassmorphic_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SystemMonitorService _monitor = SystemMonitorService();
  PerformanceData? _currentData;
  List<PerformanceData> _history = [];
  
  @override
  void initState() {
    super.initState();
    _monitor.startMonitoring();
    _monitor.performanceStream.listen((data) {
      setState(() {
        _currentData = data;
        _history = _monitor.getHistory(limit: 30);
      });
    });
  }
  
  @override
  void dispose() {
    _monitor.stopMonitoring();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      appBar: AppBar(
        title: const Text('System Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Health Score Card
              _buildHealthCard(),
              const SizedBox(height: 16),
              
              // Stats Grid
              _buildStatsGrid(),
              const SizedBox(height: 16),
              
              // CPU Usage Chart
              _buildCPUChart(),
              const SizedBox(height: 16),
              
              // Memory Usage
              _buildMemoryCard(),
              const SizedBox(height: 16),
              
              // Storage Usage
              _buildStorageCard(),
              const SizedBox(height: 16),
              
              // Network Info
              _buildNetworkCard(),
              const SizedBox(height: 16),
              
              // Process Info
              _buildProcessCard(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHealthCard() {
    final healthScore = _monitor.getHealthScore();
    return GlassmorphicCard(
      child: Column(
        children: [
          const Text(
            'System Health',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _currentData != null 
                      ? (100 - _currentData!.cpuUsage) / 100 
                      : 0.8,
                  strokeWidth: 8,
                  backgroundColor: JarvisColors.textHint.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getHealthColor(healthScore),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    healthScore,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _monitor.getHealthScore(),
                    style: TextStyle(fontSize: 12, color: _getHealthColor(healthScore)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentData != null 
                ? 'Last updated: ${_currentData!.getFormattedTimestamp()}'
                : 'Waiting for data...',
            style: TextStyle(fontSize: 10, color: JarvisColors.textHint),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard('CPU Usage', _currentData?.cpuUsage ?? 0, '%', Icons.memory),
        _buildStatCard('RAM Usage', _currentData?.ramUsage ?? 0, '%', Icons.storage),
        _buildStatCard('Battery', _currentData?.batteryLevel ?? 0, '%', Icons.battery_charging_full),
        _buildStatCard('Temperature', _currentData?.batteryTemperature ?? 25, '°C', Icons.thermostat),
      ],
    );
  }
  
  Widget _buildStatCard(String title, double value, String unit, IconData icon) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: JarvisColors.accentCyan),
          const SizedBox(height: 8),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: JarvisColors.textSecondary),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCPUChart() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CPU Usage History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _history.asMap().entries.map((e) => 
                      FlSpot(e.key.toDouble(), e.value.cpuUsage)
                    ).toList(),
                    isCurved: true,
                    color: JarvisColors.accentCyan,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMemoryCard() {
    final usedPercent = _currentData?.ramUsage ?? 0;
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Memory Usage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: usedPercent / 100,
            backgroundColor: JarvisColors.textHint.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              usedPercent > 80 ? Colors.red : JarvisColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: ${(usedPercent).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Free: ${(100 - usedPercent).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, color: JarvisColors.textSecondary),
              ),
            ],
          ),
          if (_currentData != null)
            Text(
              '${_currentData!.getRamFormatted()}',
              style: const TextStyle(fontSize: 11, color: JarvisColors.textHint),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStorageCard() {
    final usedPercent = _currentData?.storageUsed ?? 0;
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Storage Usage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: usedPercent / 100,
            backgroundColor: JarvisColors.textHint.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              usedPercent > 85 ? Colors.red : JarvisColors.warning,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: ${usedPercent.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Free: ${(100 - usedPercent).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, color: JarvisColors.textSecondary),
              ),
            ],
          ),
          if (_currentData != null)
            Text(
              _currentData!.getStorageFormatted(),
              style: const TextStyle(fontSize: 11, color: JarvisColors.textHint),
            ),
        ],
      ),
    );
  }
  
  Widget _buildNetworkCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Network Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _currentData?.networkType == 'wifi' ? Icons.wifi : Icons.signal_cellular_alt,
                color: JarvisColors.accentCyan,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentData?.networkType?.toUpperCase() ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Signal: ${_currentData?.networkStrength ?? 0}%',
                      style: TextStyle(fontSize: 12, color: JarvisColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: JarvisColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Connected', style: TextStyle(fontSize: 10, color: JarvisColors.success)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProcessCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Processes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProcessStat('Active', _currentData?.activeProcesses ?? 0),
              _buildProcessStat('Total', _currentData?.totalProcesses ?? 0),
              _buildProcessStat('System', (_currentData?.totalProcesses ?? 0) - (_currentData?.activeProcesses ?? 0)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProcessStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: JarvisColors.textSecondary),
        ),
      ],
    );
  }
  
  Color _getHealthColor(String health) {
    switch (health) {
      case 'Excellent':
        return JarvisColors.success;
      case 'Good':
        return Colors.lightGreen;
      case 'Fair':
        return JarvisColors.warning;
      case 'Poor':
        return JarvisColors.error;
      default:
        return JarvisColors.accentCyan;
    }
  }
}