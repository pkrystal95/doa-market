import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;
  final Function(Map<String, dynamic>) onPaymentComplete;
  final Function(String) onPaymentError;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentData,
    required this.onPaymentComplete,
    required this.onPaymentError,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            print('WebView navigation: ${request.url}');
            final uri = Uri.parse(request.url);
            print('WebView scheme: ${uri.scheme}');

            // Ignore about:blank and data: schemes
            if (uri.scheme == 'about' || uri.scheme == 'data') {
              print('Ignoring internal WebView scheme: ${uri.scheme}');
              return NavigationDecision.navigate;
            }

            // Check if URL is not http/https (payment app scheme)
            if (uri.scheme != 'http' && uri.scheme != 'https') {
              print('Detected payment app scheme: ${uri.scheme}, host: ${uri.host}');
              // Try to launch payment app
              _launchPaymentApp(request.url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check for callback URLs
            if (url.contains('/payment/callback') || url.contains('/payment/complete')) {
              _handlePaymentCallback(url);
            }
          },
          onWebResourceError: (WebResourceError error) {
            widget.onPaymentError('페이지 로드 오류: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'PaymentResult',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final result = json.decode(message.message);
            widget.onPaymentComplete(result);
          } catch (e) {
            widget.onPaymentError('결과 처리 오류: $e');
          }
        },
      )
      ..loadHtmlString(_buildPaymentHtml());
  }

  Future<void> _launchPaymentApp(String url) async {
    try {
      print('Attempting to launch payment app: $url');
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        print('canLaunchUrl returned true, launching...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Payment app not installed - could show error or redirect to app store
        print('canLaunchUrl returned false - payment app not available');
        print('시뮬레이터에서는 결제 앱을 사용할 수 없습니다. 실제 기기에서 테스트해주세요.');
        widget.onPaymentError('시뮬레이터에서는 결제 앱을 사용할 수 없습니다.\n\nPG사 심사용 스크린샷을 위해서는 실제 iOS 기기에서 테스트가 필요합니다.\n\n앱 스키마: ${uri.scheme}://');
      }
    } catch (e) {
      print('Payment app launch error: $e');
      widget.onPaymentError('결제 앱 실행 오류: $e');
    }
  }

  void _handlePaymentCallback(String url) {
    final uri = Uri.parse(url);
    final params = uri.queryParameters;

    if (params.containsKey('status')) {
      final status = params['status'];
      if (status == 'success') {
        widget.onPaymentComplete({
          'status': 'success',
          'transactionId': params['transactionId'] ?? 'TXN_${DateTime.now().millisecondsSinceEpoch}',
          'paymentId': widget.paymentData['paymentId'],
        });
      } else {
        widget.onPaymentError(params['message'] ?? '결제에 실패했습니다');
      }
    }
  }

  String _buildPaymentHtml() {
    final paymentData = widget.paymentData;
    final inicisParams = paymentData['inicisParams'] ?? {};
    final paymentUrl = paymentData['paymentUrl'] ?? 'https://mobile.inicis.com/smart/payment/';

    // Build form inputs from inicisParams
    String formInputs = '';
    inicisParams.forEach((key, value) {
      formInputs += '<input type="hidden" name="$key" value="$value" />\n';
    });

    return '''
    <!DOCTYPE html>
    <html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>KG 이니시스 결제</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: #f5f5f5;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                margin: 0;
                padding: 20px;
            }
            .loading-container {
                text-align: center;
                background: white;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            }
            .spinner {
                border: 4px solid #f3f3f3;
                border-top: 4px solid #667eea;
                border-radius: 50%;
                width: 60px;
                height: 60px;
                animation: spin 1s linear infinite;
                margin: 0 auto 20px;
            }
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
            h3 {
                color: #333;
                margin: 0 0 10px 0;
            }
            p {
                color: #666;
                margin: 0;
            }
        </style>
    </head>
    <body>
        <div class="loading-container">
            <div class="spinner"></div>
            <h3>KG 이니시스 결제창 연결 중...</h3>
            <p>잠시만 기다려 주세요</p>
        </div>

        <form id="paymentForm" name="paymentForm" method="post" action="$paymentUrl" accept-charset="euc-kr">
            $formInputs
        </form>

        <script>
            // Auto-submit form on load
            window.onload = function() {
                setTimeout(function() {
                    document.forms['paymentForm'].submit();
                }, 500);
            };
        </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('결제 취소'),
                content: const Text('결제를 취소하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('아니요'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('예'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
