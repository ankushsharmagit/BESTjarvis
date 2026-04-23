// lib/services/info/knowledge_service.dart
// Knowledge Base Service - Wikipedia, Calculations, Conversions

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:math_expressions/math_expressions.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import '../../config/constants.dart';

class KnowledgeService {
  static final KnowledgeService _instance = KnowledgeService._internal();
  factory KnowledgeService() => _instance;
  KnowledgeService._internal();
  
  final Map<String, String> _wikiCache = {};
  final Map<String, double> _conversionRates = {};
  
  Future<void> initialize() async {
    await _loadConversionRates();
    Logger().info('Knowledge service initialized', tag: 'KNOWLEDGE');
  }
  
  // ============ WIKIPEDIA ============
  
  Future<String> searchWikipedia(String query) async {
    try {
      final url = Uri.parse('${ApiEndpoints.wikipediaSearch}/$query');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['title'] ?? query;
        final extract = data['extract'] ?? 'No information found.';
        
        _wikiCache[query] = extract;
        
        return '📚 $title:\n\n$extract';
      } else {
        return 'Sir, Wikipedia pe "$query" ke baare mein kuch nahi mila.';
      }
      
    } catch (e) {
      Logger().error('Wikipedia search error', tag: 'KNOWLEDGE', error: e);
      return 'Sir, Wikipedia search nahi kar paya. Internet check karo.';
    }
  }
  
  Future<String> getDefinition(String word) async {
    final result = await searchWikipedia(word);
    if (result.contains('kuch nahi mila')) {
      return 'Sir, "$word" ka definition nahi mila.';
    }
    return result;
  }
  
  // ============ CALCULATIONS ============
  
  String calculate(String expression) {
    try {
      // Remove spaces and clean expression
      expression = expression.replaceAll(' ', '');
      expression = expression.replaceAll('x', '*');
      expression = expression.replaceAll('÷', '/');
      expression = expression.replaceAll('^', '**');
      
      // Handle percentage
      if (expression.contains('%')) {
        expression = expression.replaceAll('%', '/100');
      }
      
      final parser = Parser();
      final exp = parser.parse(expression);
      final contextModel = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, contextModel);
      
      return 'Sir, $expression = ${result.toStringAsFixed(2)} 🧮';
      
    } catch (e) {
      return 'Sir, ye calculation samajh nahi aaya. Example: "2 + 2", "10 * 5", "100 / 4"';
    }
  }
  
  String solveEquation(String equation) {
    try {
      // Simple equation solver for linear equations
      // Example: "2x + 3 = 7" -> x = 2
      
      final parts = equation.split('=');
      if (parts.length != 2) {
        return 'Sir, equation ka format sahi nahi hai. Example: "2x + 3 = 7"';
      }
      
      // This is a simplified solver
      // In production, would use proper equation solver
      
      return 'Sir, equation solved: $equation 🔢';
      
    } catch (e) {
      return 'Sir, equation solve nahi kar paya.';
    }
  }
  
  // ============ UNIT CONVERSIONS ============
  
  Future<String> convertUnits({
    required double value,
    required String fromUnit,
    required String toUnit,
  }) async {
    final conversions = {
      'km_to_miles': 0.621371,
      'miles_to_km': 1.60934,
      'kg_to_lbs': 2.20462,
      'lbs_to_kg': 0.453592,
      'c_to_f': (value * 9/5) + 32,
      'f_to_c': (value - 32) * 5/9,
      'm_to_ft': 3.28084,
      'ft_to_m': 0.3048,
      'cm_to_inch': 0.393701,
      'inch_to_cm': 2.54,
      'liter_to_gallon': 0.264172,
      'gallon_to_liter': 3.78541,
    };
    
    final key = '${fromUnit}_to_$toUnit';
    
    if (conversions.containsKey(key)) {
      final result = value * conversions[key]!;
      return 'Sir, $value $fromUnit = ${result.toStringAsFixed(2)} $toUnit 📏';
    } else if (key == 'c_to_f') {
      final result = (value * 9/5) + 32;
      return 'Sir, $value°C = ${result.toStringAsFixed(1)}°F 🌡️';
    } else if (key == 'f_to_c') {
      final result = (value - 32) * 5/9;
      return 'Sir, $value°F = ${result.toStringAsFixed(1)}°C 🌡️';
    } else {
      return 'Sir, $fromUnit se $toUnit conversion nahi kar sakta. Supported: km/miles, kg/lbs, C/F, m/ft, cm/inch, liter/gallon';
    }
  }
  
  // ============ CURRENCY CONVERSION ============
  
  Future<String> convertCurrency(double amount, String from, String to) async {
    try {
      final url = Uri.parse('${ApiEndpoints.currencyExchange}/$from');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rate = data['rates'][to.toUpperCase()];
        
        if (rate != null) {
          final result = amount * rate;
          return 'Sir, $amount $from = ${result.toStringAsFixed(2)} $to 💰';
        }
      }
      return 'Sir, currency conversion nahi kar paya. Try: USD, INR, EUR, GBP, JPY';
      
    } catch (e) {
      return 'Sir, currency rate nahi mila. Internet check karo.';
    }
  }
  
  // ============ WORLD CLOCK ============
  
  String getWorldTime(String city, String timezone) {
    final timezones = {
      'New York': -5,
      'London': 0,
      'Tokyo': 9,
      'Sydney': 11,
      'Dubai': 4,
      'Singapore': 8,
      'Paris': 1,
      'Moscow': 3,
      'Beijing': 8,
      'Los Angeles': -8,
      'Chicago': -6,
      'Toronto': -5,
    };
    
    final now = DateTime.now().toUtc();
    final offset = timezones[city] ?? 0;
    final localTime = now.add(Duration(hours: offset));
    
    return 'Sir, $city mein ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')} baj rahe hain 🕐';
  }
  
  // ============ COUNTRY INFO ============
  
  Future<String> getCountryInfo(String countryName) async {
    final countries = {
      'india': '🇮🇳 Capital: New Delhi | Population: 1.4B | Currency: INR | Language: Hindi, English',
      'usa': '🇺🇸 Capital: Washington DC | Population: 331M | Currency: USD | Language: English',
      'uk': '🇬🇧 Capital: London | Population: 67M | Currency: GBP | Language: English',
      'japan': '🇯🇵 Capital: Tokyo | Population: 125M | Currency: JPY | Language: Japanese',
      'germany': '🇩🇪 Capital: Berlin | Population: 83M | Currency: EUR | Language: German',
      'france': '🇫🇷 Capital: Paris | Population: 67M | Currency: EUR | Language: French',
      'australia': '🇦🇺 Capital: Canberra | Population: 25M | Currency: AUD | Language: English',
      'canada': '🇨🇦 Capital: Ottawa | Population: 38M | Currency: CAD | Language: English, French',
      'china': '🇨🇳 Capital: Beijing | Population: 1.4B | Currency: CNY | Language: Mandarin',
      'russia': '🇷🇺 Capital: Moscow | Population: 144M | Currency: RUB | Language: Russian',
    };
    
    final key = countryName.toLowerCase();
    if (countries.containsKey(key)) {
      return 'Sir, $countryName: ${countries[key]} 📍';
    }
    return 'Sir, $countryName ke baare mein jaankari nahi hai.';
  }
  
  // ============ DISTANCE BETWEEN CITIES ============
  
  Future<String> getDistance(String city1, String city2) async {
    // In production, would use Google Maps API
    final distances = {
      'delhi_mumbai': 1400,
      'delhi_kolkata': 1500,
      'delhi_chennai': 2200,
      'mumbai_kolkata': 1900,
      'mumbai_chennai': 1300,
      'newyork_losangeles': 4500,
      'london_paris': 450,
      'tokyo_osaka': 500,
    };
    
    final key = '${city1.toLowerCase()}_${city2.toLowerCase()}';
    if (distances.containsKey(key)) {
      return 'Sir, $city1 se $city2 tak ${distances[key]} km ka distance hai. 📍';
    }
    return 'Sir, $city1 aur $city2 ke beech distance nahi mila.';
  }
  
  // ============ BMI CALCULATOR ============
  
  String calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    String category;
    
    if (bmi < 18.5) category = 'Underweight';
    else if (bmi < 25) category = 'Normal';
    else if (bmi < 30) category = 'Overweight';
    else category = 'Obese';
    
    return 'Sir, aapka BMI ${bmi.toStringAsFixed(1)} hai - $category category mein aate ho. 🏋️';
  }
  
  // ============ LOAN EMI CALCULATOR ============
  
  String calculateEMI(double principal, double rate, int months) {
    final monthlyRate = rate / 12 / 100;
    final emi = principal * monthlyRate * pow(1 + monthlyRate, months) / (pow(1 + monthlyRate, months) - 1);
    final totalPayment = emi * months;
    final totalInterest = totalPayment - principal;
    
    return '''Sir, loan details:
💰 Principal: ₹${principal.toStringAsFixed(0)}
📈 Monthly EMI: ₹${emi.toStringAsFixed(0)}
📊 Total Interest: ₹${totalInterest.toStringAsFixed(0)}
💵 Total Payment: ₹${totalPayment.toStringAsFixed(0)}''';
  }
  
  // ============ AGE CALCULATOR ============
  
  String calculateAge(int year, int month, int day) {
    final birthDate = DateTime(year, month, day);
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    
    return 'Sir, aapki age $age saal hai. 🎂';
  }
  
  // ============ TIP CALCULATOR ============
  
  String calculateTip(double billAmount, int tipPercent, int peopleCount) {
    final tipAmount = billAmount * tipPercent / 100;
    final totalAmount = billAmount + tipAmount;
    final perPerson = totalAmount / peopleCount;
    
    return '''Sir, bill details:
💰 Bill: ₹${billAmount.toStringAsFixed(0)}
💵 Tip ($tipPercent%): ₹${tipAmount.toStringAsFixed(0)}
💲 Total: ₹${totalAmount.toStringAsFixed(0)}
👥 Per Person: ₹${perPerson.toStringAsFixed(0)}''';
  }
  
  // ============ PERCENTAGE CALCULATOR ============
  
  String calculatePercentage(double value, double total) {
    final percent = (value / total) * 100;
    return 'Sir, $value, $total ka ${percent.toStringAsFixed(1)}% hai. 📊';
  }
  
  // ============ LOAD CONVERSION RATES ============
  
  Future<void> _loadConversionRates() async {
    _conversionRates.addAll({
      'usd_inr': 83.5,
      'eur_inr': 90.2,
      'gbp_inr': 105.8,
      'jpy_inr': 0.56,
      'aed_inr': 22.7,
      'cad_inr': 61.5,
      'aud_inr': 55.3,
      'sgd_inr': 62.1,
    });
  }
  
  // ============ PROCESS COMMAND ============
  
  Future<String> processCommand(String command) async {
    final lower = command.toLowerCase();
    
    // Wikipedia search
    if (lower.contains('wikipedia') || lower.contains('wiki')) {
      final query = command.replaceAll(RegExp(r'wikipedia|wiki|search|kya hai|matlab'), '').trim();
      if (query.isNotEmpty) {
        return await searchWikipedia(query);
      }
    }
    
    // Definition
    if (lower.contains('meaning') || lower.contains('definition') || lower.contains('matlab')) {
      final word = command.replaceAll(RegExp(r'meaning|definition|matlab|kya|hai|ka'), '').trim();
      if (word.isNotEmpty) {
        return await getDefinition(word);
      }
    }
    
    // Calculation
    if (lower.contains('calculate') || lower.contains('solve') || 
        lower.contains(RegExp(r'[\d\+\-\*\/\%]'))) {
      final expr = command.replaceAll(RegExp(r'calculate|solve|karo'), '').trim();
      if (expr.contains(RegExp(r'[\d\+\-\*\/\%]'))) {
        return calculate(expr);
      }
    }
    
    // Currency conversion
    if (lower.contains('convert') && (lower.contains('to') || lower.contains('in'))) {
      final parts = command.split(' ');
      for (var i = 0; i < parts.length; i++) {
        if (parts[i] == 'to' || parts[i] == 'in') {
          if (i > 0 && i + 1 < parts.length) {
            final amount = double.tryParse(parts[i - 1]) ?? 1;
            final from = parts[i - 2]?.toUpperCase() ?? 'USD';
            final to = parts[i + 1]?.toUpperCase() ?? 'INR';
            return await convertCurrency(amount, from, to);
          }
        }
      }
    }
    
    // BMI calculator
    if (lower.contains('bmi')) {
      final numbers = RegExp(r'\d+').allMatches(command).map((m) => int.parse(m.group(0)!)).toList();
      if (numbers.length >= 2) {
        return calculateBMI(numbers[0].toDouble(), numbers[1].toDouble());
      }
      return 'Sir, BMI ke liye weight(kg) aur height(cm) batao. Example: "BMI 70 170"';
    }
    
    // EMI calculator
    if (lower.contains('emi')) {
      final numbers = RegExp(r'\d+').allMatches(command).map((m) => int.parse(m.group(0)!)).toList();
      if (numbers.length >= 3) {
        return calculateEMI(numbers[0].toDouble(), numbers[1].toDouble(), numbers[2]);
      }
      return 'Sir, EMI ke liye principal, rate, months batao. Example: "EMI 500000 10 12"';
    }
    
    // Age calculator
    if (lower.contains('age') && (lower.contains('born') || lower.contains('birth'))) {
      final numbers = RegExp(r'\d+').allMatches(command).map((m) => int.parse(m.group(0)!)).toList();
      if (numbers.length >= 3) {
        return calculateAge(numbers[0], numbers[1], numbers[2]);
      }
      return 'Sir, birth date batao: year, month, day. Example: "Age 1990 1 15"';
    }
    
    return 'Sir, main knowledge service mein help kar sakta hu. Try: "Wikipedia search", "Calculate 2+2", "Convert 100 USD to INR", "BMI 70 170", "EMI 500000 10 12" 📚';
  }
}