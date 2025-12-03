import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String orderNumber,
    required String userId,
    required String sellerId,
    @Default('pending') String status,
    required List<OrderItemModel> items,
    required double subtotalAmount,
    required double shippingAmount,
    @Default(0) double discountAmount,
    required double totalAmount,
    @Default('card') String paymentMethod,
    @Default('pending') String paymentStatus,
    required AddressModel shippingAddress,
    String? memo,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    required String orderId,
    required String productId,
    required String productName,
    String? productImage,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    Map<String, String>? options,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    String? id,
    required String recipientName,
    required String phone,
    required String zipCode,
    required String address,
    required String addressDetail,
    @Default(false) bool isDefault,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
}

@freezed
class CreateOrderRequest with _$CreateOrderRequest {
  const factory CreateOrderRequest({
    required List<OrderItemInput> items,
    required String addressId,
    required String paymentMethod,
    String? couponId,
    String? memo,
  }) = _CreateOrderRequest;

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);
}

@freezed
class OrderItemInput with _$OrderItemInput {
  const factory OrderItemInput({
    required String productId,
    required int quantity,
    Map<String, String>? options,
  }) = _OrderItemInput;

  factory OrderItemInput.fromJson(Map<String, dynamic> json) =>
      _$OrderItemInputFromJson(json);
}

