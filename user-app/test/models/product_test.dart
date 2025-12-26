import 'package:flutter_test/flutter_test.dart';
import 'package:doa_market_user/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Product should be created from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'product-123',
        'name': '테스트 상품',
        'description': '테스트 상품 설명',
        'price': '10000',
        'thumbnail': 'https://example.com/image.jpg',
        'stockQuantity': 50,
        'sellerId': 'seller-123',
        'status': 'active',
      };

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.id, 'product-123');
      expect(product.name, '테스트 상품');
      expect(product.description, '테스트 상품 설명');
      expect(product.price, 10000.0);
      expect(product.imageUrl, 'https://example.com/image.jpg');
      expect(product.stock, 50);
      expect(product.sellerId, 'seller-123');
      expect(product.status, 'active');
    });

    test('Product should handle missing optional fields', () {
      // Arrange
      final json = {
        'id': 'product-123',
        'name': '테스트 상품',
        'description': '테스트 상품 설명',
        'price': '10000',
        'stockQuantity': 50,
        'sellerId': 'seller-123',
        'status': 'active',
      };

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.imageUrl, isNull);
    });

    test('Product should handle invalid price gracefully', () {
      // Arrange
      final json = {
        'id': 'product-123',
        'name': '테스트 상품',
        'description': '테스트 상품 설명',
        'price': 'invalid',
        'stockQuantity': 50,
        'sellerId': 'seller-123',
        'status': 'active',
      };

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.price, 0.0);
    });

    test('Product should convert to JSON correctly', () {
      // Arrange
      final product = Product(
        id: 'product-123',
        name: '테스트 상품',
        description: '테스트 상품 설명',
        price: 10000.0,
        imageUrl: 'https://example.com/image.jpg',
        stock: 50,
        sellerId: 'seller-123',
        status: 'active',
      );

      // Act
      final json = product.toJson();

      // Assert
      expect(json['id'], 'product-123');
      expect(json['name'], '테스트 상품');
      expect(json['description'], '테스트 상품 설명');
      expect(json['price'], 10000.0);
      expect(json['imageUrl'], 'https://example.com/image.jpg');
      expect(json['stock'], 50);
      expect(json['sellerId'], 'seller-123');
      expect(json['status'], 'active');
    });

    test('Product should handle alternative JSON field names', () {
      // Arrange
      final json = {
        'id': 'product-123',
        'name': '테스트 상품',
        'description': '테스트 상품 설명',
        'price': '10000',
        'imageUrl': 'https://example.com/image.jpg', // alternative field
        'stock': 50, // alternative field
        'sellerId': 'seller-123',
        'status': 'active',
      };

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.imageUrl, 'https://example.com/image.jpg');
      expect(product.stock, 50);
    });
  });
}
