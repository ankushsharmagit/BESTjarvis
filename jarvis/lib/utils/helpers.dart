// lib/utils/helpers.dart
// General Helper Functions

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // ============ DATE & TIME ============
  
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static String formatDateTime(DateTime datetime) {
    return DateFormat('MMM dd, h:mm a').format(datetime);
  }
  
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
  
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
  
  static String formatNumber(int number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(1)}Cr';
    }
    if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  // ============ STRING MANIPULATION ============
  
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map(capitalize).join(' ');
  }
  
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[6-9]\d{9}$|^\+91[6-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }
  
  static String maskString(String input, int visibleStart, int visibleEnd) {
    if (input.length <= visibleStart + visibleEnd) return input;
    final start = input.substring(0, visibleStart);
    final end = input.substring(input.length - visibleEnd);
    final maskedLength = input.length - visibleStart - visibleEnd;
    return '$start${'*' * maskedLength}$end';
  }
  
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(10000).toString();
  }
  
  static String toSlug(String text) {
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
  
  // ============ UI HELPERS ============
  
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  static void showSnackBar(BuildContext context, String message, 
      {bool isError = false, Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static Future<void> showDialog(BuildContext context, String title, String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  static Future<bool> showConfirmDialog(BuildContext context, String title, String message) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  static Future<String?> showInputDialog(BuildContext context, String title, String hint) async {
    final controller = TextEditingController();
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  // ============ LANGUAGE HELPERS ============
  
  static String extractNumbers(String text) {
    final regex = RegExp(r'\d+');
    return regex.allMatches(text).map((m) => m.group(0)).join();
  }
  
  static bool containsChinese(String text) {
    return RegExp(r'[\u4e00-\u9fff]').hasMatch(text);
  }
  
  static bool containsHindi(String text) {
    return RegExp(r'[\u0900-\u097F]').hasMatch(text);
  }
  
  static String toHinglish(String text) {
    Map<String, String> hindiWords = {
      'hello': 'namaste',
      'how are you': 'aap kaise hain',
      'thank you': 'dhanyavaad',
      'good morning': 'suprabhat',
      'good night': 'shubh ratri',
      'yes': 'haan',
      'no': 'nahi',
      'please': 'kripya',
      'sorry': 'maaf karo',
      'what': 'kya',
      'where': 'kahan',
      'when': 'kab',
      'why': 'kyun',
      'who': 'kaun',
      'tell me': 'mujhe batao',
      'show me': 'mujhe dikhao',
      'open': 'kholo',
      'close': 'band karo',
      'call': 'phone karo',
      'message': 'message karo',
      'send': 'bhejo',
    };
    
    var result = text.toLowerCase();
    hindiWords.forEach((eng, hin) {
      result = result.replaceAll(eng, hin);
    });
    return result;
  }
  
  static String detectLanguage(String text) {
    if (containsHindi(text)) return 'hi';
    if (containsChinese(text)) return 'zh';
    return 'en';
  }
  
  // ============ GREETINGS ============
  
  static String getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
  
  static String getHindiGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Suprabhat';
    if (hour < 17) return 'Namaste';
    return 'Shubh Ratri';
  }
  
  static String getIslamicGreeting() {
    return 'Assalamualaikum';
  }
  
  // ============ TEXT PROCESSING ============
  
  static List<String> splitIntoChunks(String text, int chunkSize) {
    final chunks = <String>[];
    for (var i = 0; i < text.length; i += chunkSize) {
      chunks.add(text.substring(i, min(i + chunkSize, text.length)));
    }
    return chunks;
  }
  
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }
  
  static String removeEmojis(String text) {
    final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
        unicode: true);
    return text.replaceAll(emojiRegex, '');
  }
  
  static String extractEmojis(String text) {
    final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
        unicode: true);
    return emojiRegex.allMatches(text).map((m) => m.group(0)).join();
  }
  
  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '');
  }
  
  static String normalizeText(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  // ============ ENCRYPTION HELPERS ============
  
  static String base64EncodeString(String text) {
    final bytes = utf8.encode(text);
    return base64.encode(bytes);
  }
  
  static String base64DecodeString(String text) {
    final bytes = base64.decode(text);
    return utf8.decode(bytes);
  }
  
  static String simpleHash(String text) {
    var hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = (hash ^ text.codeUnitAt(i)) * 31;
    }
    return hash.abs().toRadixString(16);
  }
  
  // ============ DEVICE INFO ============
  
  static String getDeviceType() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Web';
  }
  
  static bool isEmulator() {
    // This would use device_info_plus to detect emulator
    return false;
  }
  
  // ============ COLOR HELPERS ============
  
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
  
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
  
  static Color blendColors(Color color1, Color color2, double ratio) {
    final r = (color1.red * (1 - ratio) + color2.red * ratio).round();
    final g = (color1.green * (1 - ratio) + color2.green * ratio).round();
    final b = (color1.blue * (1 - ratio) + color2.blue * ratio).round();
    return Color.fromARGB(255, r, g, b);
  }
  
  static Color getContrastColor(Color color) {
    final brightness = (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114);
    return brightness > 128 ? Colors.black : Colors.white;
  }
  
  static Color getRandomColor() {
    return Color(Random().nextInt(0xFFFFFFFF));
  }
}

class MathHelper {
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }
  
  static double roundToDecimal(double value, int decimals) {
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }
  
  static bool isPrime(int number) {
    if (number < 2) return false;
    for (var i = 2; i <= sqrt(number); i++) {
      if (number % i == 0) return false;
    }
    return true;
  }
  
  static int factorial(int n) {
    if (n < 0) throw Exception('Factorial not defined for negative numbers');
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  }
  
  static int fibonacci(int n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
  }
  
  static double calculateBMI(double weightKg, double heightM) {
    if (heightM == 0) return 0;
    return weightKg / (heightM * heightM);
  }
  
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
  
  static double calculateEMI(double principal, double ratePerAnnum, int months) {
    final monthlyRate = ratePerAnnum / 12 / 100;
    if (monthlyRate == 0) return principal / months;
    final denominator = 1 - pow(1 + monthlyRate, -months);
    return principal * monthlyRate / denominator;
  }
  
  static double calculateLoanInterest(double principal, double rate, int years) {
    return principal * rate * years / 100;
  }
  
  static double calculateCompoundInterest(double principal, double rate, int years, int compoundsPerYear) {
    return principal * pow(1 + (rate / 100) / compoundsPerYear, compoundsPerYear * years);
  }
  
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }
}

class NetworkHelper {
  static bool isWifiConnection(String type) {
    return type.toLowerCase().contains('wifi');
  }
  
  static bool isMobileConnection(String type) {
    return type.toLowerCase().contains('mobile') || 
           type.toLowerCase().contains('cellular');
  }
  
  static String getConnectionIcon(String type) {
    if (isWifiConnection(type)) return '📶';
    if (isMobileConnection(type)) return '📱';
    return '🌐';
  }
  
  static String getSpeedIcon(double speedMbps) {
    if (speedMbps > 50) return '🚀';
    if (speedMbps > 20) return '⚡';
    if (speedMbps > 5) return '👍';
    return '🐢';
  }
  
  static String formatSpeed(double speedMbps) {
    if (speedMbps >= 1000) {
      return '${(speedMbps / 1000).toStringAsFixed(1)} Gbps';
    }
    return '${speedMbps.toStringAsFixed(1)} Mbps';
  }
}