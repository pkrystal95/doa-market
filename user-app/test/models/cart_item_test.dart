import 'package:flutter_test/flutter_test.dart';
import 'package:doa_market_user/models/cart_item.dart';
import 'package:doa_market_user/models/product.dart';

void main() {
  group('CartItem Model Tests', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: 'product-123',
        name: '테스트 상품',
        description: '테스트 상품 설명',
        price: 10000.0,
        imageUrl: 'https://example.com/image.jpg',
        stock: 50,
        sellerId: 'seller-123',
        status: 'active',
      );
    });

    test('CartItem should be created correctly', () {
      // Arrange & Act
      final cartItem = CartItem(
        id: 'cart-item-1',
        product: testProduct,
        quantity: 2,
      );

      // Assert
      expect(cartItem.id, 'cart-item-1');
      expect(cartItem.product, testProduct);
      expect(cartItem.quantity, 2);
    });

    test('CartItem totalPrice should be calculated correctly', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-item-1',
        product: testProduct,
        quantity: 3,
      );

      // Act
      final totalPrice = cartItem.totalPrice;

      // Assert
      expect(totalPrice, 30000.0);
    });

    test('CartItem quantity should be mutable', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-item-1',
        product: testProduct,
        quantity: 2,
      );

      // Act
      cartItem.quantity = 5;

      // Assert
      expect(cartItem.quantity, 5);
      expect(cartItem.totalPrice, 50000.0);
    });

    test('CartItem should be created from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'cart-item-1',
        'product': {
          'id': 'product-123',
          'name': '테스트 상품',
          'description': '테스트 상품 설명',
          'price': '10000',
          'stockQuantity': 50,
          'sellerId': 'seller-123',
          'status': 'active',
        },
        'quantity': 2,
      };

      // Act
      final cartItem = CartItem.fromJson(json);

      // Assert
      expect(cartItem.id, 'cart-item-1');
      expect(cartItem.product.id, 'product-123');
      expect(cartItem.product.name, '테스트 상품');
      expect(cartItem.quantity, 2);
      expect(cartItem.totalPrice, 20000.0);
    });

    test('CartItem should handle missing fields with defaults', () {
      // Arrange
      final json = {
        'product': {
          'id': 'product-123',
          'name': '테스트 상품',
          'description': '테스트 상품 설명',
          'price': '10000',
          'stockQuantity': 50,
          'sellerId': 'seller-123',
          'status': 'active',
        },
      };

      // Act
      final cartItem = CartItem.fromJson(json);

      // Assert
      expect(cartItem.id, '');
      expect(cartItem.quantity, 1);
    });

    test('CartItem should convert to JSON correctly', () {
      // Arrange
      final cartItem = CartItem(
        id: 'cart-item-1',
        product: testProduct,
        quantity: 2,
      );

      // Act
      final json = cartItem.toJson();

      // Assert
      expect(json['id'], 'cart-item-1');
      expect(json['quantity'], 2);
      expect(json['product'], isNotNull);
      expect(json['product']['id'], 'product-123');
    });
  });
}
