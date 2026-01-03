import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
// Timezone paketini buraya da ekle
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Zaman dilimlerini yükle (Kritik nokta burası)
  tz.initializeTimeZones();
  
  // 2. Bildirim servisini başlat
  await NotificationService.init();
  
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}