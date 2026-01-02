import 'dart:convert'; // JSON işlemleri için gerekli
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import 'add_subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subscription> mySubscriptions = [];
  double hourlyWage = 120.0;

  @override
  void initState() {
    super.initState();
    _loadData(); // Uygulama açıldığında verileri yükle
  }

  // VERİLERİ YÜKLEME (Telefondan oku)
  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hourlyWage = prefs.getDouble('hourlyWage') ?? 120.0;
      final String? subString = prefs.getString('subscriptions');
      if (subString != null) {
        final List<dynamic> jsonData = jsonDecode(subString);
        mySubscriptions = jsonData.map((item) => Subscription.fromJson(item)).toList();
      }
    });
  }

  // VERİLERİ KAYDETME (Telefona yaz)
  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('hourlyWage', hourlyWage);
    final String subString = jsonEncode(mySubscriptions.map((e) => e.toJson()).toList());
    prefs.setString('subscriptions', subString);
  }

  String calculateWorkHours(double price) {
    if (hourlyWage <= 0) return "Gelir girilmedi";
    final hours = price / hourlyWage;
    return "${hours.toStringAsFixed(1)} saat çalışmalısın";
  }

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
    );

    if (result != null && result is Subscription) {
      setState(() {
        mySubscriptions.add(result);
        _saveData(); // Listeye ekleyince kaydet
      });
    }
  }

  void _deleteSubscription(int index) {
    setState(() {
      mySubscriptions.removeAt(index);
      _saveData(); // Silince kaydet
    });
  }

  void _showWageDialog() {
    final TextEditingController wageController = TextEditingController(text: hourlyWage.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Saatlik Geliri Güncelle"),
        content: TextField(
          controller: wageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Örn: 150", suffixText: "TL"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              if (wageController.text.isNotEmpty) {
                setState(() {
                  hourlyWage = double.tryParse(wageController.text) ?? 120.0;
                  _saveData(); // Ücreti güncelleyince kaydet
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Güncelle"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abonelik Detoksu"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text("${hourlyWage.toInt()} TL/saat", style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
            ),
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: _showWageDialog),
        ],
      ),
      body: mySubscriptions.isEmpty
          ? const Center(child: Text("Henüz abonelik eklemedin."))
          : ListView.builder(
              itemCount: mySubscriptions.length,
              itemBuilder: (context, index) {
                final sub = mySubscriptions[index];
                return Dismissible(
                  key: Key(sub.id),
                  direction: DismissDirection.endToStart,
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (direction) => _deleteSubscription(index),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.2), child: const Icon(Icons.subscriptions, color: Colors.green)),
                      title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(calculateWorkHours(sub.price), style: const TextStyle(color: Colors.redAccent)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${sub.price.toStringAsFixed(2)} TL", style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.grey), onPressed: () => _deleteSubscription(index)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: _navigateToAddScreen, child: const Icon(Icons.add)),
    );
  }
}