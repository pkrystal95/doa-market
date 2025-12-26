import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notice_provider.dart';
import '../models/notice.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({Key? key}) : super(key: key);

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotices();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNotices() async {
    final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);
    await noticeProvider.fetchNotices(page: 1);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      _loadMoreNotices();
    }
  }

  Future<void> _loadMoreNotices() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);
    _currentPage++;
    await noticeProvider.fetchNotices(
      page: _currentPage,
      category: noticeProvider.selectedCategory,
    );

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        elevation: 0,
      ),
      body: Consumer<NoticeProvider>(
        builder: (context, noticeProvider, child) {
          if (noticeProvider.isLoading && noticeProvider.notices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noticeProvider.error != null && noticeProvider.notices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '공지사항을 불러올 수 없습니다',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadNotices,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadNotices,
            child: Column(
              children: [
                _buildCategoryFilter(noticeProvider),
                if (noticeProvider.urgentNotices.isNotEmpty)
                  _buildUrgentSection(noticeProvider),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: noticeProvider.notices.length +
                        (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == noticeProvider.notices.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final notice = noticeProvider.notices[index];
                      return _buildNoticeItem(notice);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUrgentSection(NoticeProvider noticeProvider) {
    return Container(
      color: Colors.red[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '긴급 공지',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...noticeProvider.urgentNotices.map((notice) {
            return InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/notice-detail',
                  arguments: notice.id,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[900],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.red[400]),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(NoticeProvider noticeProvider) {
    final categories = [
      {'value': null, 'label': '전체'},
      {'value': '공지', 'label': '공지'},
      {'value': '이벤트', 'label': '이벤트'},
      {'value': '점검', 'label': '점검'},
      {'value': '업데이트', 'label': '업데이트'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected =
                noticeProvider.selectedCategory == category['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category['label'] as String),
                selected: isSelected,
                onSelected: (selected) {
                  noticeProvider.filterByCategory(
                    selected ? category['value'] as String? : null,
                  );
                },
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor: Theme.of(context).primaryColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNoticeItem(Notice notice) {
    final dateFormat = DateFormat('yyyy.MM.dd');

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/notice-detail',
          arguments: notice.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (notice.isUrgent) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '긴급',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(notice.category),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    notice.categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (notice.isPinned) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: Colors.red[400],
                  ),
                ],
                if (notice.isNew) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  dateFormat.format(notice.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  NumberFormat('#,###').format(notice.viewCount),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '공지':
      case 'announcement':
        return Colors.blue;
      case '이벤트':
      case 'event':
        return Colors.orange;
      case '점검':
      case 'maintenance':
        return Colors.red;
      case '업데이트':
      case 'update':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
