class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int stock;
  final String sellerId;
  final String status;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.stock,
    required this.sellerId,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      imageUrl: json['thumbnail'] ?? json['imageUrl'],
      stock: json['stockQuantity'] ?? json['stock'] ?? 0,
      sellerId: json['sellerId'] ?? '',
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'sellerId': sellerId,
      'status': status,
    };
  }
}
