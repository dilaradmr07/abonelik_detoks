import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

class StorageService {
  static const String _subKey = 'user_subscriptions';
  static const String _rateKey = 'hourly_rate';

  // Abonelikleri Kaydet/Oku
  Future<void> saveSubscriptions(List<Subscription> subs) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(subs.map((s) => s.toJson()).toList());
    await prefs.setString(_subKey, encodedData);
  }

  Future<List<Subscription>> loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_subKey);
    if (data == null) return [];
    final List<dynamic> decodedData = jsonDecode(data);
    return decodedData.map((item) => Subscription.fromJson(item)).toList();
  }

  // Saatlik Ücreti Kaydet/Oku
  Future<void> saveHourlyRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_rateKey, rate);
  }

  Future<double> loadHourlyRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_rateKey) ?? 150.0; // Varsayılan değer
  }
}