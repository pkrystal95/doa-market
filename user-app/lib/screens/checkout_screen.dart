import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../providers/point_provider.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _apiService = ApiService();

  bool _isProcessing = false;
  Address? _selectedAddress;
  int _usedPoints = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final pointProvider = Provider.of<PointProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.userId != null) {
      await Future.wait([
        addressProvider.fetchAddresses(authProvider.userId!),
        pointProvider.fetchPointSummary(authProvider.userId!),
      ]);

      // 기본 주소 자동 선택
      if (addressProvider.defaultAddress != null) {
        setState(() {
          _selectedAddress = addressProvider.defaultAddress;
          _fillAddressForm(_selectedAddress!);
        });
      }
    }
  }

  void _fillAddressForm(Address address) {
    _nameController.text = address.recipientName;
    _phoneController.text = address.phone;
    _zipcodeController.text = address.zipCode;
    _addressController.text = address.address;
    _detailAddressController.text = address.addressDetail ?? '';
  }

  void _selectAddress() {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    
    if (addressProvider.addresses.isEmpty) {
      // 주소가 없으면 주소 관리 화면으로 이동
      Navigator.of(context).pushNamed('/addresses').then((_) {
        _loadAddresses();
      });
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '배송지 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/addresses').then((_) {
                      _loadAddresses();
                    });
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('새 주소 추가'),
                ),
              ],
            ),
            const Divider(),
            ...addressProvider.addresses.map((address) => ListTile(
              leading: Icon(
                address.isDefault ? Icons.home : Icons.location_on,
                color: address.isDefault ? Theme.of(context).primaryColor : Colors.grey,
              ),
                              title: Row(
                                children: [
                                  Expanded(child: Text(address.recipientName)),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '기본',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
                              subtitle: Text('${address.address} ${address.addressDetail ?? ""}'),
              selected: _selectedAddress?.id == address.id,
              onTap: () {
                setState(() {
                  _selectedAddress = address;
                  _fillAddressForm(address);
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _zipcodeController.dispose();
    super.dispose();
  }

  void _searchAddress() {
    if (!kIsWeb) {
      // Mobile: Show a simple input dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('주소 검색'),
          content: const Text('모바일에서는 수동으로 입력해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    // Web-only code would go here
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('웹에서는 주소 검색 기능을 사용할 수 없습니다.')),
    );
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      if (!authProvider.isAuthenticated || authProvider.userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 주소 정보 가져오기 (선택된 주소 또는 입력한 주소)
      Map<String, dynamic> shippingAddress;
      if (_selectedAddress != null) {
        shippingAddress = {
          'name': _selectedAddress!.recipientName,
          'phone': _selectedAddress!.phone,
          'address': _selectedAddress!.address,
          'detailAddress': _selectedAddress!.addressDetail ?? '',
          'zipcode': _selectedAddress!.zipCode,
        };
      } else {
        shippingAddress = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'detailAddress': _detailAddressController.text,
          'zipcode': _zipcodeController.text,
        };
      }

      // 1. Create order
      final orderItems = cartProvider.items.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'quantity': item.quantity,
        'price': item.product.price,
        'totalPrice': item.totalPrice,
      }).toList();

      final orderResponse = await _apiService.createOrder(
        userId: authProvider.userId!,
        items: orderItems,
        shippingAddress: shippingAddress,
      );

      if (orderResponse['success'] != true) {
        throw Exception('주문 생성에 실패했습니다');
      }

      final orderId = orderResponse['data']['id'];
      final totalAmount = cartProvider.totalAmount;
      final finalAmount = totalAmount - _usedPoints;

      // 2. Use points if any
      if (_usedPoints > 0) {
        final pointProvider = Provider.of<PointProvider>(context, listen: false);
        final pointsUsed = await pointProvider.usePoints(
          userId: authProvider.userId!,
          amount: _usedPoints,
          orderId: orderId,
        );

        if (!pointsUsed) {
          throw Exception('포인트 사용에 실패했습니다');
        }
      }

      // 3. Prepare payment
      final paymentResponse = await _apiService.preparePayment(
        orderId: orderId,
        userId: authProvider.userId!,
        amount: finalAmount.toInt().toDouble(), // Convert to int then back to double to ensure whole number
        productName: cartProvider.items.length == 1
            ? cartProvider.items[0].product.name
            : '${cartProvider.items[0].product.name} 외 ${cartProvider.items.length - 1}건',
      );

      if (paymentResponse['success'] != true) {
        throw Exception('결제 준비에 실패했습니다');
      }

      // 4. Open KG Inicis payment page
      await _openPaymentWindow(paymentResponse['data']);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _openPaymentWindow(Map<String, dynamic> paymentData) async {
    // Note: In production, you would handle the payment callback
    // For now, show a message
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('결제 진행 중'),
          content: Text(kIsWeb
            ? '새 창에서 결제를 진행해주세요.\n결제 완료 후 이 화면으로 돌아옵니다.'
            : '모바일 결제 페이지로 이동합니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to cart
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                cartProvider.clear();
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    if (cartProvider.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('주문하기'),
        ),
        body: const Center(
          child: Text('장바구니가 비어있습니다'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문하기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order items summary
              const Text(
                '주문 상품',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...cartProvider.items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: item.product.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported);
                                  },
                                ),
                              )
                            : const Icon(Icons.shopping_bag),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 x ${item.quantity}개',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 24),

              // Delivery information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '배송 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Consumer<AddressProvider>(
                    builder: (context, addressProvider, child) {
                      return TextButton.icon(
                        onPressed: _selectAddress,
                        icon: const Icon(Icons.location_on, size: 20),
                        label: Text(
                          _selectedAddress != null ? '배송지 변경' : '배송지 선택',
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 선택된 주소 표시
              if (_selectedAddress != null)
                Consumer<AddressProvider>(
                  builder: (context, addressProvider, child) {
                    return Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedAddress!.isDefault ? Icons.home : Icons.location_on,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedAddress!.recipientName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_selectedAddress!.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '기본',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(_selectedAddress!.phone),
                            const SizedBox(height: 4),
                            Text('${_selectedAddress!.address} ${_selectedAddress!.addressDetail ?? ""}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (_selectedAddress == null)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '받는 사람',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '받는 사람을 입력해주세요';
                    }
                    return null;
                  },
                ),
              if (_selectedAddress == null) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: '연락처',
                    border: OutlineInputBorder(),
                    hintText: '010-1234-5678',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '연락처를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _zipcodeController,
                        decoration: const InputDecoration(
                          labelText: '우편번호',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '우편번호를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchAddress,
                      child: const Text('주소 검색'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: '주소',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '주소를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailAddressController,
                  decoration: const InputDecoration(
                    labelText: '상세 주소',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '상세 주소를 입력해주세요';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),

              // Point usage section
              Consumer<PointProvider>(
                builder: (context, pointProvider, child) {
                  final numberFormat = NumberFormat('#,###');
                  final availablePoints = pointProvider.totalPoints;
                  final maxUsable = pointProvider.getMaxUsablePoints(cartProvider.totalAmount.toInt());

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.stars, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  '포인트 사용',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              '보유: ${numberFormat.format(availablePoints)}P',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _usedPoints > 0 ? _usedPoints.toString() : '',
                                decoration: InputDecoration(
                                  hintText: '0',
                                  suffixText: 'P',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final points = int.tryParse(value) ?? 0;
                                  setState(() {
                                    _usedPoints = points.clamp(0, maxUsable);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: maxUsable > 0
                                  ? () {
                                      setState(() {
                                        _usedPoints = maxUsable;
                                      });
                                    }
                                  : null,
                              child: const Text('전액 사용'),
                            ),
                          ],
                        ),
                        if (maxUsable < availablePoints) ...[
                          const SizedBox(height: 8),
                          Text(
                            '최대 ${numberFormat.format(maxUsable)}P까지 사용 가능 (주문 금액의 50%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Payment summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('상품 금액', style: TextStyle(fontSize: 16)),
                        Text(
                          '${cartProvider.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('배송비', style: TextStyle(fontSize: 16)),
                        Text('0원', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    if (_usedPoints > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('포인트 사용', style: TextStyle(fontSize: 16)),
                          Text(
                            '-${NumberFormat('#,###').format(_usedPoints)}원',
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '총 결제 금액',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${(cartProvider.totalAmount - _usedPoints).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '${(cartProvider.totalAmount - _usedPoints).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 결제하기',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'KG이니시스 안전결제',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
