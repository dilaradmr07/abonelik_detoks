import 'package:flutter/material.dart';
import '../models/subscription.dart'; // Model dosyasını buradan çağırıyoruz

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _saveSubscription() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      return; 
    }

    final String name = _nameController.text;
    final double? price = double.tryParse(_priceController.text.replaceAll(',', '.'));

    if (price == null) return;

    final newSubscription = Subscription(
      id: DateTime.now().toString(),
      name: name,
      price: price,
    );

    Navigator.pop(context, newSubscription);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Abonelik Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Abonelik Adı (Örn: Netflix)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Aylık Ücret (TL)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveSubscription,
              icon: const Icon(Icons.save),
              label: const Text("Kaydet"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}