class Subscription {
  final String id;
  final String name;
  final double price;

  Subscription({required this.id, required this.name, required this.price});

  // Aboneliği JSON formatına (Yazıya) çevirir
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };

  // Yazıdan (JSON) tekrar Abonelik nesnesi oluşturur
  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'],
        name: json['name'],
        price: json['price'],
      );
}