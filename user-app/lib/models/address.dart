class Address {
  final String id;
  final String userId;
  final String recipientName;
  final String phone;
  final String zipCode;
  final String address;
  final String? addressDetail;
  final bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.phone,
    required this.zipCode,
    required this.address,
    this.addressDetail,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['addressId'] ?? '',
      userId: json['userId'] ?? '',
      recipientName: json['recipientName'] ?? '',
      phone: json['phone'] ?? '',
      zipCode: json['zipCode'] ?? '',
      address: json['address'] ?? '',
      addressDetail: json['addressDetail'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': id,
      'userId': userId,
      'recipientName': recipientName,
      'phone': phone,
      'zipCode': zipCode,
      'address': address,
      'addressDetail': addressDetail,
      'isDefault': isDefault,
    };
  }

  String get fullAddress {
    if (addressDetail != null && addressDetail!.isNotEmpty) {
      return '$address $addressDetail';
    }
    return address;
  }

  String get displayText {
    return '[$zipCode] $fullAddress';
  }
}
