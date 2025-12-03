import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String sellerId,
    required String categoryId,
    required String name,
    required String slug,
    String? description,
    required double price,
    double? originalPrice,
    required double discountRate,
    required String status,
    required int stockQuantity,
    required double ratingAvg,
    required int reviewCount,
    required int salesCount,
    required int viewCount,
    String? thumbnail,
    List<String>? images,
    ProductCategory? category,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@freezed
class ProductCategory with _$ProductCategory {
  const factory ProductCategory({
    required String id,
    required String name,
  }) = _ProductCategory;

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);
}
