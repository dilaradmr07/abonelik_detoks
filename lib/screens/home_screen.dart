import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Subscription> mySubscriptions = [];
  
  double hourlyRate = 120.0; // Varsayılan 120 TL
  double budgetLimit = 2000.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _storage.loadSubscriptions();
    final rate = await _storage.loadHourlyRate();
    
    final prefs = await SharedPreferences.getInstance();
    final limit = prefs.getDouble('budget_limit') ?? 2000.0;

    setState(() {
      mySubscriptions = data;
      hourlyRate = rate > 0 ? rate : 120.0;
      budgetLimit = limit;
    });
  }

  void _showSettingsDialog() {
    final rateController = TextEditingController(text: hourlyRate.toString());
    final limitController = TextEditingController(text: budgetLimit.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("Ayarlar", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rateController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Saatlik Kazancın (TL)",
                labelStyle: TextStyle(color: Colors.greenAccent),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: limitController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Aylık Bütçe Limitin (TL)",
                labelStyle: TextStyle(color: Colors.orangeAccent),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              double newRate = double.tryParse(rateController.text) ?? 120.0;
              double newLimit = double.tryParse(limitController.text) ?? 2000.0;
              await _storage.saveHourlyRate(newRate);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setDouble('budget_limit', newLimit);
              setState(() {
                hourlyRate = newRate;
                budgetLimit = newLimit;
              });
              Navigator.pop(context);
            },
            child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final n = TextEditingController();
    final p = TextEditingController();
    final d = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("Yeni Abonelik", style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: n, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Platform", hintStyle: TextStyle(color: Colors.grey))),
          TextField(controller: p, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Fiyat", hintStyle: TextStyle(color: Colors.grey)), keyboardType: TextInputType.number),
          TextField(controller: d, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Ödeme Günü (1-31)", hintStyle: TextStyle(color: Colors.grey)), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (n.text.isNotEmpty && p.text.isNotEmpty && d.text.isNotEmpty) {
                int day = int.parse(d.text);
                final newSub = Subscription(name: n.text, price: double.parse(p.text), paymentDay: day);
                setState(() => mySubscriptions.add(newSub));
                await _storage.saveSubscriptions(mySubscriptions);
                await NotificationService.scheduleNotification(mySubscriptions.length, n.text, day);
                Navigator.pop(c);
              }
            }, child: const Text("Ekle", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = mySubscriptions.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        // İŞTE YEŞİL BAŞLIK
        title: const Text(
          "Abonelik Detoksu", 
          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.greenAccent),
            onPressed: _showSettingsDialog,
          )
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(total),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Aboneliklerin", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mySubscriptions.length,
              itemBuilder: (context, index) {
                final sub = mySubscriptions[index];
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const Icon(Icons.subscriptions, color: Colors.greenAccent),
                    title: Text(sub.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("${sub.price} TL • Gün: ${sub.paymentDay}", style: const TextStyle(color: Colors.grey)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(() => mySubscriptions.removeAt(index));
                        _storage.saveSubscriptions(mySubscriptions);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    double progress = (total / budgetLimit).clamp(0.0, 1.0);
    Color progressColor = progress > 0.8 ? Colors.redAccent : (progress > 0.5 ? Colors.orangeAccent : Colors.greenAccent);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text("Aylık Gider", style: TextStyle(color: Colors.white70)),
          Text("${total.toStringAsFixed(2)} TL", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          
          // ÇITA (PROGRESS BAR)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.black26,
              color: progressColor,
            ),
          ),
          const SizedBox(height: 10),
          Text("%${(progress * 100).toInt()} bütçe doluluğu", style: TextStyle(color: progressColor, fontSize: 12)),
          
          const Divider(color: Colors.white24, height: 30),
          Text(
            "Bu para için ayda ${(total / hourlyRate).toStringAsFixed(1)} saat çalışıyorsun.",
            style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}