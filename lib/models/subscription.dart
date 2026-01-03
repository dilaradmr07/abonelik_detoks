class Subscription {
  final String name;
  final double price;
  final int paymentDay;

  Subscription({required this.name, required this.price, required this.paymentDay});

  Map<String, dynamic> toJson() => {
    'name': name, 
    'price': price, 
    'paymentDay': paymentDay
  };

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      name: json['name'], 
      price: json['price'], 
      paymentDay: json['paymentDay'] ?? 1,
    );
  }
}