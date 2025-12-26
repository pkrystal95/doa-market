import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inquiry_provider.dart';
import '../providers/auth_provider.dart';
import '../models/inquiry.dart';

class InquiryListScreen extends StatefulWidget {
  const InquiryListScreen({Key? key}) : super(key: key);

  @override
  State<InquiryListScreen> createState() => _InquiryListScreenState();
}

class _InquiryListScreenState extends State<InquiryListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInquiries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInquiries() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final inquiryProvider =
        Provider.of<InquiryProvider>(context, listen: false);

    if (authProvider.userId != null) {
      await inquiryProvider.fetchInquiries(authProvider.userId!, page: 1);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      _loadMoreInquiries();
    }
  }

  Future<void> _loadMoreInquiries() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final inquiryProvider =
        Provider.of<InquiryProvider>(context, listen: false);

    if (authProvider.userId != null) {
      _currentPage++;
      await inquiryProvider.fetchInquiries(
        authProvider.userId!,
        page: _currentPage,
      );
    }

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1:1 문의'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '답변대기'),
            Tab(text: '답변완료'),
          ],
        ),
      ),
      body: Consumer<InquiryProvider>(
        builder: (context, inquiryProvider, child) {
          if (inquiryProvider.isLoading &&
              inquiryProvider.inquiries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (inquiryProvider.error != null &&
              inquiryProvider.inquiries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '문의를 불러올 수 없습니다',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadInquiries,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInquiryList(inquiryProvider.inquiries),
              _buildInquiryList(inquiryProvider.inquiries
                  .where((i) => i.status == 'pending')
                  .toList()),
              _buildInquiryList(inquiryProvider.inquiries
                  .where((i) => i.isAnswered)
                  .toList()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/inquiry-write').then((_) {
            _loadInquiries();
          });
        },
        icon: const Icon(Icons.create),
        label: const Text('문의하기'),
      ),
    );
  }

  Widget _buildInquiryList(List<Inquiry> inquiries) {
    if (inquiries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.question_answer, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '문의 내역이 없습니다',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInquiries,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: inquiries.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == inquiries.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final inquiry = inquiries[index];
          return _buildInquiryItem(inquiry);
        },
      ),
    );
  }

  Widget _buildInquiryItem(Inquiry inquiry) {
    final dateFormat = DateFormat('yyyy.MM.dd');

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/inquiry-detail',
          arguments: inquiry.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(inquiry.category),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    inquiry.categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: inquiry.isPending ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    inquiry.statusName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(inquiry.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              inquiry.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              inquiry.content,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (inquiry.hasReply) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${inquiry.reply!.adminName}님이 답변했습니다',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
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
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'order':
        return Colors.blue;
      case 'product':
        return Colors.purple;
      case 'delivery':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'etc':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
