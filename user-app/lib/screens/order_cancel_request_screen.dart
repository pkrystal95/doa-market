import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/order.dart';

class OrderCancelRequestScreen extends StatefulWidget {
  const OrderCancelRequestScreen({Key? key}) : super(key: key);

  @override
  State<OrderCancelRequestScreen> createState() =>
      _OrderCancelRequestScreenState();
}

class _OrderCancelRequestScreenState extends State<OrderCancelRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _apiService = ApiService();

  String _requestType = 'cancel'; // 'cancel', 'return', 'exchange'
  String _selectedReason = '단순 변심';
  bool _isSubmitting = false;
  Order? _order;

  final List<String> _cancelReasons = [
    '단순 변심',
    '다른 상품 잘못 주문',
    '상품 정보 상이',
    '배송 지연',
    '기타',
  ];

  final List<String> _returnReasons = [
    '상품 불량/파손',
    '상품 정보 상이',
    '배송된 상품 오배송',
    '단순 변심',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        setState(() {
          _order = args['order'] as Order;
          _requestType = args['type'] as String? ?? 'cancel';
        });
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주문 정보를 찾을 수 없습니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final reason = _selectedReason == '기타'
          ? _reasonController.text.trim()
          : _selectedReason;

      Map<String, dynamic> response;

      switch (_requestType) {
        case 'cancel':
          response = await _apiService.cancelOrder(
            userId: authProvider.userId!,
            orderId: _order!.id,
            reason: reason,
          );
          break;
        case 'return':
          response = await _apiService.requestReturn(
            userId: authProvider.userId!,
            orderId: _order!.id,
            reason: reason,
          );
          break;
        case 'exchange':
          response = await _apiService.requestExchange(
            userId: authProvider.userId!,
            orderId: _order!.id,
            reason: reason,
          );
          break;
        default:
          throw Exception('잘못된 요청 유형입니다');
      }

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getRequestTypeName()} 요청이 접수되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to refresh
        } else {
          throw Exception(response['message'] ?? '요청에 실패했습니다');
        }
      }
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
          _isSubmitting = false;
        });
      }
    }
  }

  String _getRequestTypeName() {
    switch (_requestType) {
      case 'cancel':
        return '취소';
      case 'return':
        return '반품';
      case 'exchange':
        return '교환';
      default:
        return '요청';
    }
  }

  List<String> _getReasonList() {
    return _requestType == 'cancel' ? _cancelReasons : _returnReasons;
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: Text('${_getRequestTypeName()} 신청'),
        elevation: 0,
      ),
      body: _order == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 주문 정보
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '주문 정보',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._order!.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${numberFormat.format(item.price)}원 x ${item.quantity}개',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '총 결제 금액',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${numberFormat.format(_order!.totalAmount)}원',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 사유 선택
                    const Text(
                      '사유 선택',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedReason,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: _getReasonList()
                          .map((reason) => DropdownMenuItem(
                                value: reason,
                                child: Text(reason),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedReason = value ?? '단순 변심';
                        });
                      },
                    ),

                    // 기타 사유 입력
                    if (_selectedReason == '기타') ...[
                      const SizedBox(height: 16),
                      const Text(
                        '상세 사유',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '상세 사유를 입력해주세요',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (_selectedReason == '기타' &&
                              (value == null || value.trim().isEmpty)) {
                            return '상세 사유를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 안내 메시지
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange[700], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '안내사항',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _requestType == 'cancel'
                                ? '• 배송 준비 중인 상품만 취소 가능합니다\n'
                                    '• 취소 승인 후 영업일 기준 3-5일 내 환불됩니다\n'
                                    '• 포인트로 결제한 금액은 포인트로 환불됩니다'
                                : '• 배송 완료 후 7일 이내 신청 가능합니다\n'
                                    '• 상품 택 제거 및 사용 흔적이 있을 경우 반품이 제한될 수 있습니다\n'
                                    '• 승인 후 수거 진행 및 확인 후 환불됩니다',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 신청 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.red,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                '${_getRequestTypeName()} 신청',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
