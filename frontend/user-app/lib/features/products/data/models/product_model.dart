import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String sellerId,
    required String categoryId,
    required String name,
    required String slug,
    String? description,
    required double price,
    double? originalPrice,
    @Default(0) double discountRate,
    @Default('active') String status,
    required int stockQuantity,
    @Default(0) double ratingAvg,
    @Default(0) int reviewCount,
    @Default(0) int salesCount,
    @Default(0) int viewCount,
    String? thumbnail,
    List<String>? images,
    CategoryModel? category,
    List<ProductOptionModel>? options,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String slug,
    String? parentId,
    @Default(0) int level,
    @Default(0) int order,
    List<CategoryModel>? children,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}

@freezed
class ProductOptionModel with _$ProductOptionModel {
  const factory ProductOptionModel({
    required String id,
    required String name,
    required List<String> values,
    @Default(true) bool required,
  }) = _ProductOptionModel;

  factory ProductOptionModel.fromJson(Map<String, dynamic> json) =>
      _$ProductOptionModelFromJson(json);
}

@freezed
class ProductListResponse with _$ProductListResponse {
  const factory ProductListResponse({
    required List<ProductModel> products,
    required PaginationMeta meta,
  }) = _ProductListResponse;

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductListResponseFromJson(json);
}

@freezed
class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    required int page,
    required int limit,
    required int total,
    required int totalPages,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}

