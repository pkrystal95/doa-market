import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checkin_provider.dart';
import '../providers/auth_provider.dart';

class DailyCheckinScreen extends StatefulWidget {
  const DailyCheckinScreen({Key? key}) : super(key: key);

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    // Defer data loading until after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCheckinData();
    });
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadCheckinData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final checkinProvider = Provider.of<CheckinProvider>(context, listen: false);

    if (authProvider.userId != null) {
      await checkinProvider.initialize(authProvider.userId!);
    }
  }

  Future<void> _handleCheckin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final checkinProvider = Provider.of<CheckinProvider>(context, listen: false);

    if (authProvider.userId == null) {
      _showMessage('로그인이 필요합니다', isError: true);
      return;
    }

    if (!checkinProvider.canCheckIn) {
      _showMessage('오늘 이미 출석하셨습니다', isError: true);
      return;
    }

    // 출석 체크 애니메이션 시작
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    final result = await checkinProvider.checkIn(authProvider.userId!);

    if (result != null) {
      _showMessage(result.message, isError: false);

      // 보너스가 있으면 축하 효과
      if (result.hasBonus) {
        _showBonusDialog(result);
      }
    } else if (checkinProvider.error != null) {
      _showMessage(checkinProvider.error!, isError: true);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showBonusDialog(result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 보너스 획득!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${result.consecutiveDays}일 연속 출석',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '+${result.bonusPoints}P 보너스!',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            Text('총 ${result.pointsEarned}P 적립'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출석체크'),
        centerTitle: true,
      ),
      body: Consumer<CheckinProvider>(
        builder: (context, checkinProvider, child) {
          if (checkinProvider.isLoading && checkinProvider.checkinStatus == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadCheckinData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeaderCard(checkinProvider),
                  const SizedBox(height: 24),
                  _buildCheckinButton(checkinProvider),
                  const SizedBox(height: 24),
                  _buildNextBonusCard(checkinProvider),
                  const SizedBox(height: 24),
                  _buildCalendarCard(checkinProvider),
                  const SizedBox(height: 24),
                  _buildStatsCard(checkinProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(CheckinProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildHeaderItem(
              icon: Icons.card_giftcard,
              label: '보유 포인트',
              value: '${provider.totalPoints}P',
              color: Colors.orange,
            ),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            _buildHeaderItem(
              icon: Icons.local_fire_department,
              label: '연속 출석',
              value: '${provider.consecutiveDays}일',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckinButton(CheckinProvider provider) {
    final isCheckedIn = provider.isCheckedInToday;
    final isProcessing = provider.isCheckingIn;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTap: isCheckedIn || isProcessing ? null : _handleCheckin,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCheckedIn
                        ? [Colors.grey[400]!, Colors.grey[600]!]
                        : [Colors.orange[400]!, Colors.orange[700]!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCheckedIn
                          ? Colors.grey.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCheckedIn ? Icons.check_circle : Icons.touch_app,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCheckedIn ? '출석완료!' : '출석체크',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isCheckedIn)
                      const Text(
                        '10P 받기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextBonusCard(CheckinProvider provider) {
    if (provider.checkinStatus == null || !provider.checkinStatus!.hasNextBonus) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.stars, color: Colors.orange[700], size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '다음 보너스',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.nextBonusMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(CheckinProvider provider) {
    final now = DateTime.now();
    final calendar = provider.checkinCalendar;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${now.year}년 ${now.month}월',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '이번 달 ${provider.checkinStatus?.thisMonthCount ?? 0}일 출석',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCalendarGrid(provider, now),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(CheckinProvider provider, DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;

    // 요일 헤더
    final weekDays = ['일', '월', '화', '수', '목', '금', '토'];

    return Column(
      children: [
        // 요일 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) => SizedBox(
            width: 40,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        // 날짜 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: daysInMonth + firstDay.weekday % 7,
          itemBuilder: (context, index) {
            // 빈 칸 처리
            if (index < firstDay.weekday % 7) {
              return const SizedBox.shrink();
            }

            final day = index - firstDay.weekday % 7 + 1;
            final date = DateTime(month.year, month.month, day);
            final isCheckedIn = provider.isCheckedIn(date);
            final checkinDay = provider.getCheckinDay(date);
            final isToday = date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day;

            return Container(
              decoration: BoxDecoration(
                color: isCheckedIn
                    ? (checkinDay?.isBonus ?? false
                        ? Colors.orange
                        : Colors.green)
                    : (isToday ? Colors.blue[50] : null),
                shape: BoxShape.circle,
                border: isToday && !isCheckedIn
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isCheckedIn ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (isCheckedIn && (checkinDay?.isBonus ?? false))
                      const Icon(Icons.star, size: 12, color: Colors.white),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsCard(CheckinProvider provider) {
    final stats = provider.checkinStats;
    if (stats == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '출석 통계',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('총 출석일', '${stats.totalCheckins}일'),
                _buildStatItem('획득 포인트', '${stats.totalPointsEarned}P'),
                _buildStatItem('보너스 횟수', '${stats.bonusCount}회'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
