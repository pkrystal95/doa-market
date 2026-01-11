import 'package:flutter/material.dart';
import 'policy_viewer_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _selectedCategory = '전체';
  int? _expandedIndex;

  final List<Map<String, dynamic>> _faqList = [
    {
      'category': '주문/결제',
      'question': '주문 취소는 어떻게 하나요?',
      'answer': '주문 내역에서 취소하고자 하는 주문을 선택한 후 "주문 취소" 버튼을 클릭하시면 됩니다. 배송 시작 전에만 취소가 가능합니다.',
    },
    {
      'category': '주문/결제',
      'question': '결제 수단은 무엇이 있나요?',
      'answer': '신용카드, 계좌이체, 가상계좌, 휴대폰 결제 등 다양한 결제 수단을 지원합니다.',
    },
    {
      'category': '주문/결제',
      'question': '영수증 발급이 가능한가요?',
      'answer': '주문 상세 페이지에서 영수증 발급이 가능합니다. 결제 완료 후 언제든지 출력하실 수 있습니다.',
    },
    {
      'category': '배송',
      'question': '배송 기간은 얼마나 걸리나요?',
      'answer': '일반적으로 주문 후 2-3일 내에 배송됩니다. 지역에 따라 다소 차이가 있을 수 있습니다.',
    },
    {
      'category': '배송',
      'question': '배송지 변경이 가능한가요?',
      'answer': '배송 시작 전에는 주문 상세 페이지에서 배송지를 변경할 수 있습니다. 배송이 시작된 이후에는 변경이 불가능합니다.',
    },
    {
      'category': '배송',
      'question': '배송 조회는 어떻게 하나요?',
      'answer': '주문 내역에서 운송장 번호를 확인하실 수 있으며, 택배사 홈페이지에서 실시간 배송 조회가 가능합니다.',
    },
    {
      'category': '반품/교환',
      'question': '반품은 어떻게 하나요?',
      'answer': '상품 수령 후 7일 이내에 주문 내역에서 반품 신청을 하실 수 있습니다. 상품은 미사용 상태여야 하며, 태그가 부착되어 있어야 합니다.',
    },
    {
      'category': '반품/교환',
      'question': '교환은 어떻게 진행되나요?',
      'answer': '교환을 원하시는 경우 반품 신청 시 교환을 선택하시면 됩니다. 상품 회수 확인 후 새 상품이 발송됩니다.',
    },
    {
      'category': '반품/교환',
      'question': '반품 배송비는 누가 부담하나요?',
      'answer': '단순 변심의 경우 고객님이 부담하시며, 상품 하자나 오배송의 경우 판매자가 부담합니다.',
    },
    {
      'category': '반품/교환',
      'question': '청약철회(취소) 가능 기간은 어떻게 되나요?',
      'answer': '상품 수령일로부터 7일 이내에 청약철회가 가능합니다. 단, 이용자에게 책임 있는 사유로 상품이 훼손된 경우, 사용 또는 일부 소비로 가치가 현저히 감소한 경우, 시간 경과로 재판매가 곤란한 경우, 복제 가능한 상품의 포장을 훼손한 경우에는 청약철회가 제한됩니다.',
    },
    {
      'category': '반품/교환',
      'question': '환불은 언제 처리되나요?',
      'answer': '상품 품절 등의 사유로 배송이 불가능한 경우, 대금을 받은 날로부터 3영업일 이내에 환불됩니다. 반품의 경우 상품 회수 확인 후 3-5영업일 이내에 결제 수단으로 환불 처리됩니다.',
    },
    {
      'category': '반품/교환',
      'question': '환불이 불가능한 경우가 있나요?',
      'answer': '네, 다음의 경우 환불이 제한될 수 있습니다: 1) 고객님의 책임으로 상품이 멸실 또는 훼손된 경우 2) 사용 또는 일부 소비로 상품 가치가 현저히 감소한 경우 3) 시간 경과로 재판매가 곤란할 정도로 가치가 감소한 경우 4) 복제 가능한 상품의 포장을 훼손한 경우',
    },
    {
      'category': '회원',
      'question': '회원 탈퇴는 어떻게 하나요?',
      'answer': '마이페이지의 설정에서 회원 탈퇴를 진행하실 수 있습니다. 탈퇴 시 모든 정보가 삭제되며 복구가 불가능합니다.',
    },
    {
      'category': '회원',
      'question': '비밀번호를 잊어버렸어요.',
      'answer': '로그인 화면에서 "비밀번호 찾기"를 클릭하시면 가입하신 이메일로 임시 비밀번호를 발송해 드립니다.',
    },
    {
      'category': '포인트',
      'question': '적립금은 어떻게 사용하나요?',
      'answer': '결제 시 사용하실 적립금을 입력하시면 결제 금액에서 차감됩니다. 최소 사용 금액은 1,000원입니다.',
    },
    {
      'category': '포인트',
      'question': '적립금 유효기간이 있나요?',
      'answer': '적립금은 적립일로부터 1년간 유효합니다. 유효기간이 지난 적립금은 자동으로 소멸됩니다.',
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqList {
    if (_selectedCategory == '전체') {
      return _faqList;
    }
    return _faqList.where((faq) => faq['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자주 묻는 질문'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _filteredFaqList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.help_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          '해당 카테고리에 FAQ가 없습니다',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredFaqList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _filteredFaqList.length) {
                        return _buildTermsSection();
                      }
                      return _buildFaqItem(index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['전체', '주문/결제', '배송', '반품/교환', '회원', '포인트'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                    _expandedIndex = null; // Reset expanded item when changing category
                  });
                },
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.grey[200],
                elevation: isSelected ? 2 : 0,
                pressElevation: 4,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
              const SizedBox(width: 8),
              Text(
                '더 자세한 정보가 필요하신가요?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '이용약관에서 취소/환불 규정을 포함한 모든 정책을 확인하실 수 있습니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PolicyViewerScreen(
                      policyType: PolicyType.terms,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.description),
              label: const Text('이용약관 전체보기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    final faq = _filteredFaqList[index];
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedIndex = isExpanded ? null : index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      faq['category'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      faq['question'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          faq['answer'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
