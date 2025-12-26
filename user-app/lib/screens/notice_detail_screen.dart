import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/notice_provider.dart';
import '../models/notice.dart';

class NoticeDetailScreen extends StatefulWidget {
  const NoticeDetailScreen({Key? key}) : super(key: key);

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noticeId = ModalRoute.of(context)?.settings.arguments as String?;
      if (noticeId != null) {
        final noticeProvider =
            Provider.of<NoticeProvider>(context, listen: false);
        noticeProvider.fetchNotice(noticeId);
      }
    });
  }

  @override
  void dispose() {
    final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);
    noticeProvider.clearCurrentNotice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        elevation: 0,
        actions: [
          Consumer<NoticeProvider>(
            builder: (context, noticeProvider, child) {
              if (noticeProvider.currentNotice == null) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final notice = noticeProvider.currentNotice!;
                  Share.share(
                    '${notice.title}\n\n${notice.content}',
                    subject: notice.title,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<NoticeProvider>(
        builder: (context, noticeProvider, child) {
          if (noticeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noticeProvider.error != null ||
              noticeProvider.currentNotice == null) {
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('목록으로'),
                  ),
                ],
              ),
            );
          }

          final notice = noticeProvider.currentNotice!;
          return _buildNoticeContent(notice);
        },
      ),
    );
  }

  Widget _buildNoticeContent(Notice notice) {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 섹션
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (notice.isUrgent) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '긴급',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(notice.category),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        notice.categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (notice.isPinned) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.push_pin,
                        size: 18,
                        color: Colors.red[400],
                      ),
                    ],
                    if (notice.isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(notice.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      NumberFormat('#,###').format(notice.viewCount),
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
          // 내용 섹션
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            width: double.infinity,
            child: Text(
              notice.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          // 첨부파일 섹션
          if (notice.hasAttachments) _buildAttachmentsSection(notice),
          const SizedBox(height: 20),
          // 이전/다음 공지사항 네비게이션
          _buildNavigationSection(context),
          const SizedBox(height: 20),
          // 목록으로 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(Notice notice) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.attach_file, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                '첨부파일',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...notice.attachments!.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            final fileName = url.split('/').last;

            return InkWell(
              onTap: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('파일을 열 수 없습니다')),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file,
                         size: 20,
                         color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.download,
                         size: 20,
                         color: Colors.grey[600]),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Consumer<NoticeProvider>(
      builder: (context, noticeProvider, child) {
        final notices = noticeProvider.notices;
        if (notices.isEmpty) return const SizedBox();

        final currentNotice = noticeProvider.currentNotice;
        if (currentNotice == null) return const SizedBox();

        final currentIndex = notices.indexWhere((n) => n.id == currentNotice.id);
        if (currentIndex == -1) return const SizedBox();

        final hasPrevious = currentIndex > 0;
        final hasNext = currentIndex < notices.length - 1;

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              if (hasPrevious) ...[
                InkWell(
                  onTap: () {
                    final prevNotice = notices[currentIndex - 1];
                    noticeProvider.fetchNotice(prevNotice.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward,
                             size: 18,
                             color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '이전 글',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notices[currentIndex - 1].title,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (hasNext) ...[
                InkWell(
                  onTap: () {
                    final nextNotice = notices[currentIndex + 1];
                    noticeProvider.fetchNotice(nextNotice.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_downward,
                             size: 18,
                             color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '다음 글',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notices[currentIndex + 1].title,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
