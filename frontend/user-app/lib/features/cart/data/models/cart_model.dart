import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../products/data/models/product_model.dart';

part 'cart_model.freezed.dart';
part 'cart_model.g.dart';

@freezed
class CartModel with _$CartModel {
  const factory CartModel({
    required String id,
    required String userId,
    required List<CartItemModel> items,
    required double totalAmount,
    required DateTime updatedAt,
  }) = _CartModel;

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);
}

@freezed
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String id,
    required String productId,
    required int quantity,
    Map<String, String>? selectedOptions,
    ProductModel? product,
    required DateTime createdAt,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}

@freezed
class AddToCartRequest with _$AddToCartRequest {
  const factory AddToCartRequest({
    required String productId,
    @Default(1) int quantity,
    Map<String, String>? selectedOptions,
  }) = _AddToCartRequest;

  factory AddToCartRequest.fromJson(Map<String, dynamic> json) =>
      _$AddToCartRequestFromJson(json);
}

