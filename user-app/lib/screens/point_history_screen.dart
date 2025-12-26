import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/point_provider.dart';
import '../providers/auth_provider.dart';
import '../models/point.dart';

class PointHistoryScreen extends StatefulWidget {
  const PointHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _selectedFilter = 'all'; // 'all', 'earn', 'use'

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pointProvider = Provider.of<PointProvider>(context, listen: false);

    if (authProvider.userId != null) {
      await Future.wait([
        pointProvider.fetchPointSummary(authProvider.userId!),
        pointProvider.fetchPointHistory(authProvider.userId!, page: 1),
      ]);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      _loadMoreHistory();
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pointProvider = Provider.of<PointProvider>(context, listen: false);

    if (authProvider.userId != null) {
      _currentPage++;
      await pointProvider.fetchPointHistory(
        authProvider.userId!,
        page: _currentPage,
      );
    }

    setState(() {
      _isLoadingMore = false;
    });
  }

  List<Point> _getFilteredHistory(List<Point> history) {
    if (_selectedFilter == 'all') {
      return history;
    } else if (_selectedFilter == 'earn') {
      return history.where((point) => point.isEarned).toList();
    } else {
      return history.where((point) => !point.isEarned).toList();
    }
  }

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'daily_checkin':
        return Icons.calendar_today;
      case 'purchase':
        return Icons.shopping_cart;
      case 'review':
        return Icons.rate_review;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'refund':
        return Icons.replay;
      case 'event':
        return Icons.card_giftcard;
      default:
        return Icons.attach_money;
    }
  }

  Color _getSourceIconColor(String source) {
    switch (source) {
      case 'daily_checkin':
        return Colors.orange;
      case 'purchase':
        return Colors.blue;
      case 'review':
        return Colors.purple;
      case 'admin':
        return Colors.teal;
      case 'refund':
        return Colors.indigo;
      case 'event':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 내역'),
        elevation: 0,
      ),
      body: Consumer<PointProvider>(
        builder: (context, pointProvider, child) {
          if (pointProvider.isLoading && pointProvider.pointHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pointProvider.error != null &&
              pointProvider.pointHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '포인트 내역을 불러올 수 없습니다',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadInitialData,
            child: ListView(
              controller: _scrollController,
              children: [
                _buildSummaryCard(pointProvider),
                const SizedBox(height: 10),
                _buildFilterTabs(),
                _buildHistorySection(pointProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(PointProvider pointProvider) {
    final summary = pointProvider.pointSummary;
    final numberFormat = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                '보유 포인트',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary != null
                ? '${numberFormat.format(summary.currentBalance)}P'
                : '0P',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                '적립 예정',
                summary?.pendingPoints ?? 0,
                numberFormat,
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white24,
              ),
              _buildSummaryItem(
                '곧 만료',
                summary?.expiringPoints ?? 0,
                numberFormat,
              ),
            ],
          ),
          if (summary?.nextExpiringDate != null) ...[
            const SizedBox(height: 12),
            Text(
              '다음 만료일: ${DateFormat('yyyy.MM.dd').format(summary!.nextExpiringDate!)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int value, NumberFormat format) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${format.format(value)}P',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterTab('전체', 'all'),
          const SizedBox(width: 8),
          _buildFilterTab('적립', 'earn'),
          const SizedBox(width: 8),
          _buildFilterTab('사용', 'use'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(PointProvider pointProvider) {
    final history = pointProvider.pointHistory;
    final filteredHistory = _getFilteredHistory(history);

    if (filteredHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        color: Colors.white,
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '포인트 내역이 없습니다',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '포인트 내역',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredHistory.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final point = filteredHistory[index];
              return _buildHistoryItem(point);
            },
          ),
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Point point) {
    final numberFormat = NumberFormat('#,###');
    final isEarned = point.isEarned;
    final isExpired = point.isExpired;
    final sourceIcon = _getSourceIcon(point.source);
    final sourceIconColor = _getSourceIconColor(point.source);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: sourceIconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              sourceIcon,
              color: sourceIconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: sourceIconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        point.sourceLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: sourceIconColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('yyyy.MM.dd HH:mm').format(point.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (point.expiresAt != null && !isExpired) ...[
                  const SizedBox(height: 4),
                  Text(
                    '만료일: ${DateFormat('yyyy.MM.dd').format(point.expiresAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
                if (isExpired) ...[
                  const SizedBox(height: 4),
                  Text(
                    '만료됨',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEarned ? '+' : ''}${numberFormat.format(point.amount)}P',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isEarned ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
