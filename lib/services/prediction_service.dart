import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictionResult {
  final String risk;
  final double probability;
  final String driver;
  final String location;

  PredictionResult({
    required this.risk,
    required this.probability,
    required this.driver,
    required this.location,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      risk: json['risk'] ?? 'UNKNOWN',
      probability: (json['probability'] ?? 0).toDouble(),
      driver: json['driver'] ?? 'N/A',
      location: json['location'] ?? 'Unknown',
    );
  }

  Color get riskColor {
    switch (risk) {
      case 'HIGH':   return const Color(0xFFD32F2F);
      case 'MEDIUM': return const Color(0xFFF57C00);
      default:       return const Color(0xFF388E3C);
    }
  }

  String get riskEmoji {
    switch (risk) {
      case 'HIGH':   return '🔴';
      case 'MEDIUM': return '🟡';
      default:       return '🟢';
    }
  }
}

class PredictionService {
  static const String _baseUrl = 'https://hwc-backend-fixed.onrender.com';

  static Future<PredictionResult?> predict(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/predict?lat=$lat&lon=$lon'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PredictionResult.fromJson(data);
      }
    } catch (e) {
      debugPrint('Prediction error: $e');
    }
    return null;
  }
}
