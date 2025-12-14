import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.userId != null) {
      await orderProvider.fetchOrders(authProvider.userId!, refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 사용자 프로필 섹션
          _buildProfileSection(),

          const Divider(height: 1),

          // 등급 및 포인트 섹션
          _buildTierAndPointsSection(),

          const SizedBox(height: 10),

          // 주문 관리 섹션
          _buildOrderSection(),

          const SizedBox(height: 10),

          // 쇼핑 활동 섹션
          _buildShoppingSection(),

          const SizedBox(height: 10),

          // 고객센터 섹션
          _buildCustomerServiceSection(),

          const SizedBox(height: 10),

          // 설정 섹션
          _buildSettingsSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.userName ?? '사용자';
        final userEmail = authProvider.userEmail ?? '';

        return Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).pushNamed('/profile-edit');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTierAndPointsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.workspace_premium,
              iconColor: Colors.amber,
              title: 'GOLD',
              subtitle: '회원 등급',
              onTap: () {
                // 등급 상세
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.stars,
              iconColor: Colors.orange,
              title: '12,500P',
              subtitle: '적립금',
              onTap: () {
                // 포인트 상세
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final pendingCount = orderProvider.getOrderCountByStatus('pending');
        final shippedCount = orderProvider.getOrderCountByStatus('shipped');
        final deliveredCount = orderProvider.getOrderCountByStatus('delivered');
        final cancelledCount = orderProvider.getOrderCountByStatus('cancelled');

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '주문 관리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOrderStatusItem(
                    icon: Icons.payment,
                    label: '결제대기',
                    count: pendingCount,
                    onTap: () {
                      Navigator.of(context).pushNamed('/orders');
                    },
                  ),
                  _buildOrderStatusItem(
                    icon: Icons.local_shipping,
                    label: '배송중',
                    count: shippedCount,
                    onTap: () {
                      Navigator.of(context).pushNamed('/orders');
                    },
                  ),
                  _buildOrderStatusItem(
                    icon: Icons.check_circle,
                    label: '배송완료',
                    count: deliveredCount,
                    onTap: () {
                      Navigator.of(context).pushNamed('/orders');
                    },
                  ),
                  _buildOrderStatusItem(
                    icon: Icons.cancel,
                    label: '취소됨',
                    count: cancelledCount,
                    onTap: () {
                      Navigator.of(context).pushNamed('/orders');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildMenuItem(
                icon: Icons.list_alt,
                title: '전체 주문내역',
                onTap: () {
                  Navigator.of(context).pushNamed('/orders');
                },
              ),
              _buildMenuItem(
                icon: Icons.cancel,
                title: '취소/반품/교환',
                onTap: () {
                  Navigator.of(context).pushNamed('/orders');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusItem({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '쇼핑 활동',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuItem(
            icon: Icons.favorite,
            title: '찜한 상품',
            onTap: () {
              Navigator.of(context).pushNamed('/wishlist');
            },
          ),
          _buildMenuItem(
            icon: Icons.history,
            title: '최근 본 상품',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.rate_review,
            title: '내 리뷰',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.question_answer,
            title: '내 상품문의',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerServiceSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '고객센터',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuItem(
            icon: Icons.headset_mic,
            title: '1:1 문의',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: '자주 묻는 질문',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.announcement,
            title: '공지사항',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuItem(
            icon: Icons.location_on,
            title: '배송지 관리',
            onTap: () {
              Navigator.of(context).pushNamed('/addresses');
            },
          ),
          _buildMenuItem(
            icon: Icons.person,
            title: '회원정보 수정',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.notifications,
            title: '알림 설정',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.security,
            title: '개인정보 처리방침',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: '로그아웃',
            textColor: Colors.red,
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: textColor ?? Colors.grey[700]),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor ?? Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout();
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

