import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inquiry_provider.dart';
import '../providers/auth_provider.dart';
import '../models/inquiry.dart';

class InquiryDetailScreen extends StatefulWidget {
  const InquiryDetailScreen({Key? key}) : super(key: key);

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inquiryId = ModalRoute.of(context)?.settings.arguments as String?;
      if (inquiryId != null) {
        final authProvider =
            Provider.of<AuthProvider>(context, listen: false);
        final inquiryProvider =
            Provider.of<InquiryProvider>(context, listen: false);

        if (authProvider.userId != null) {
          inquiryProvider.fetchInquiry(authProvider.userId!, inquiryId);
        }
      }
    });
  }

  @override
  void dispose() {
    final inquiryProvider =
        Provider.of<InquiryProvider>(context, listen: false);
    inquiryProvider.clearCurrentInquiry();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 상세'),
        elevation: 0,
      ),
      body: Consumer<InquiryProvider>(
        builder: (context, inquiryProvider, child) {
          if (inquiryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (inquiryProvider.error != null ||
              inquiryProvider.currentInquiry == null) {
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('목록으로'),
                  ),
                ],
              ),
            );
          }

          final inquiry = inquiryProvider.currentInquiry!;
          return _buildInquiryContent(inquiry);
        },
      ),
    );
  }

  Widget _buildInquiryContent(Inquiry inquiry) {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문의 정보 섹션
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(inquiry.category),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        inquiry.categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            inquiry.isPending ? Colors.orange : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        inquiry.statusName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  inquiry.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(inquiry.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 문의 내용 섹션
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '문의 내용',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  inquiry.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                if (inquiry.hasImages) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: inquiry.imageUrls.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            inquiry.imageUrls[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 답변 섹션
          if (inquiry.hasReply) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.green[50],
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.support_agent,
                          color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${inquiry.reply!.adminName}님의 답변',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateFormat.format(inquiry.reply!.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    inquiry.reply!.content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.orange[50],
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.schedule, color: Colors.orange[700], size: 32),
                  const SizedBox(height: 12),
                  Text(
                    '답변 대기 중입니다',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '빠른 시일 내에 답변 드리겠습니다',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // 목록으로 버튼
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('목록으로'),
              ),
            ),
          ),
        ],
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
