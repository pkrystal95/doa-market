import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

/// 개인정보 처리방침 및 이용약관 표시 화면
class PolicyViewerScreen extends StatefulWidget {
  final PolicyType policyType;

  const PolicyViewerScreen({
    super.key,
    required this.policyType,
  });

  @override
  State<PolicyViewerScreen> createState() => _PolicyViewerScreenState();
}

class _PolicyViewerScreenState extends State<PolicyViewerScreen> {
  String _policyContent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    try {
      // 정책 파일 로드 (assets에 추가 필요)
      final fileName = widget.policyType == PolicyType.privacy
          ? 'assets/policies/privacy_policy.md'
          : 'assets/policies/terms_of_service.md';

      final content = await rootBundle.loadString(fileName);
      setState(() {
        _policyContent = content;
        _isLoading = false;
      });
    } catch (e) {
      // 파일 로드 실패 시 기본 텍스트 사용
      setState(() {
        _policyContent = _getDefaultPolicy();
        _isLoading = false;
      });
    }
  }

  String _getDefaultPolicy() {
    if (widget.policyType == PolicyType.privacy) {
      return '''
# 개인정보 처리방침

**시행일자**: 2025년 12월 17일

DOA Market은 이용자의 개인정보를 중요시하며, 관련 법규를 준수하고 있습니다.

## 1. 개인정보의 수집 및 이용 목적
- 회원 가입 및 관리
- 서비스 제공
- 마케팅 및 광고

## 2. 수집하는 개인정보 항목
- 필수: 이메일, 비밀번호, 이름
- 선택: 휴대전화번호, 생년월일

자세한 내용은 웹사이트를 참고해주세요.
''';
    } else {
      return '''
# 이용약관

**시행일자**: 2025년 12월 17일

## 제1조 (목적)
본 약관은 DOA Market이 제공하는 서비스의 이용과 관련하여 필요한 사항을 규정함을 목적으로 합니다.

## 제2조 (용어의 정의)
- 서비스: DOA Market이 제공하는 모바일 애플리케이션
- 회원: 회사에 개인정보를 제공하여 회원등록을 한 자

자세한 내용은 웹사이트를 참고해주세요.
''';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.policyType == PolicyType.privacy
        ? '개인정보 처리방침'
        : '이용약관';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Markdown(
              data: _policyContent,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                h2: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                h3: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                p: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                ),
                listBullet: const TextStyle(
                  fontSize: 14,
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}

enum PolicyType {
  privacy,
  terms,
}
