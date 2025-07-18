import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QR 코드 패키지 추가
import 'package:url_launcher/url_launcher.dart'; // 외부 앱 호출용
import 'dart:convert'; // JSON 패키지 추가
import 'package:http/http.dart' as http; // HTTP 패키지 추가

class PaymentWebView extends StatefulWidget {
  final String merchantUid;
  final int amount;
  final String name;
  final String buyerEmail;
  final String buyerName;
  final Function(Map<String, dynamic>) onPaymentResult;

  const PaymentWebView({
    super.key,
    required this.merchantUid,
    required this.amount,
    required this.name,
    required this.buyerEmail,
    required this.buyerName,
    required this.onPaymentResult,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  bool _isLoading = true;
  
  // QR 코드 다이얼로그 표시 함수
  void _showQrDialog(String paymentUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('다른 기기에서 결제하기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('아래 QR 코드를 스캔해 결제를 진행하세요.'),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: paymentUrl,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            SelectableText(paymentUrl, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('PaymentWebView initState 시작');
    print('merchantUid: ${widget.merchantUid}');
    print('amount: ${widget.amount}');
    print('name: ${widget.name}');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('WebView 로딩 진행률: $progress%');
          },
          onPageStarted: (String url) {
            print('WebView 페이지 시작: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('WebView 페이지 완료: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('WebView 네비게이션 요청: ${request.url}');
            
            // 결제 완료 콜백 처리
            if (request.url.startsWith('flutter://payment/')) {
              _handlePaymentCallback(request.url);
              return NavigationDecision.prevent;
            }
            
            // 외부 앱 호출 처리 (결제 앱, 카드 앱 등)
            if (request.url.startsWith('intent://') || 
                request.url.startsWith('kb-acp://') ||
                request.url.startsWith('shinhan://') ||
                request.url.startsWith('lotte://') ||
                request.url.startsWith('hyundai://') ||
                request.url.startsWith('samsung://') ||
                request.url.startsWith('kakaotalk://') ||
                request.url.startsWith('kakaopay://') ||
                request.url.startsWith('naver://') ||
                request.url.startsWith('toss://') ||
                request.url.startsWith('payco://') ||
                request.url.contains('kakaopay/pg') ||
                request.url.contains('#Intent;scheme=')) {
              print('외부 앱 호출 시도: ${request.url}');
              _handleExternalAppLaunch(request.url);
              return NavigationDecision.prevent; // WebView에서 처리하지 않음
            }
            
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView 오류: ${error.description}');
            if (error.description.contains('ERR_UNKNOWN_URL_SCHEME')) {
              print('URL 스킴 오류 무시됨');
              // URL 스킴 오류는 무시하고 계속 진행
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: (message) async {
          print('JavaScript 메시지 수신: ${message.message}');
          if (message.message.startsWith('REQUEST_PAYMENT_LINK:')) {
            print('QR 링크 요청 감지됨');
            final jsonStr = message.message.replaceFirst('REQUEST_PAYMENT_LINK:', '');
            print('JSON 데이터: $jsonStr');
            final Map<String, dynamic> data = jsonDecode(jsonStr);
            print('파싱된 데이터: $data');
            final paymentUrl = await _createPaymentLink(
              merchantUid: data['merchant_uid'],
              amount: data['amount'],
              name: data['name'],
              buyerEmail: data['buyer_email'],
              buyerName: data['buyer_name'],
            );
            if (paymentUrl != null) {
              print('QR 다이얼로그 표시: $paymentUrl');
              _showQrDialog(paymentUrl);
            } else {
              print('QR 링크 생성 실패');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('결제 링크 생성에 실패했습니다.')),
              );
            }
          }
        },
      );
    
    print('HTML 로드 시작...');
    final html = _generatePaymentHtml();
    print('생성된 HTML 길이: ${html.length}');
    _controller.loadHtmlString(html);
    print('HTML 로드 완료');
  }

  void _handlePaymentCallback(String url) {
    try {
      final uri = Uri.parse(url);
      final status = uri.queryParameters['status'];
      final impUid = uri.queryParameters['imp_uid'];
      final merchantUid = uri.queryParameters['merchant_uid'];
      final errorMsg = uri.queryParameters['error_msg'];
      
      if (status == 'success' && impUid != null) {
        print('결제 성공! imp_uid: $impUid');
        widget.onPaymentResult({
          'success': true,
          'imp_uid': impUid,
          'merchant_uid': merchantUid ?? widget.merchantUid,
          'amount': widget.amount,
        });
      } else {
        print('결제 실패: $errorMsg');
        widget.onPaymentResult({
          'success': false,
          'error': errorMsg ?? '결제가 취소되었습니다.',
        });
      }
    } catch (e) {
      print('결제 콜백 처리 오류: $e');
      widget.onPaymentResult({
        'success': false,
        'error': '결제 처리 중 오류가 발생했습니다.',
      });
    }
  }

  Future<void> _handleExternalAppLaunch(String url) async {
    try {
      print('외부 앱 호출 시도: $url');
      
      // URL 스킴 정리
      String targetUrl = url;
      
      // 1. intent:// URL 처리
      if (url.startsWith('intent://')) {
        final intentUrl = url.replaceFirst('intent://', 'https://');
        print('Intent URL 변환: $intentUrl');
        targetUrl = intentUrl;
      }
      // 2. 복합 URL에서 앱 스킴 추출 (예: https://pay/?...&kb-acp://#Intent;...)
      else if (url.contains('kb-acp://') || 
               url.contains('shinhan://') || 
               url.contains('lotte://') || 
               url.contains('hyundai://') || 
               url.contains('samsung://') ||
               url.contains('kakaotalk://') ||
               url.contains('kakaopay://') ||
               url.contains('naver://') ||
               url.contains('toss://') ||
               url.contains('payco://')) {
        
        // 앱 스킴 추출
        final appSchemes = ['kb-acp://', 'shinhan://', 'lotte://', 'hyundai://', 'samsung://', 
                           'kakaotalk://', 'kakaopay://', 'naver://', 'toss://', 'payco://'];
        
        // 카카오페이 특별 처리 (Intent 스킴에서 추출)
        if (url.contains('#Intent;scheme=')) {
          final intentIndex = url.indexOf('#Intent;scheme=');
          if (intentIndex != -1) {
            final intentPart = url.substring(intentIndex);
            final schemeMatch = RegExp(r'scheme=([^;]+)').firstMatch(intentPart);
            if (schemeMatch != null) {
              final scheme = schemeMatch.group(1);
              targetUrl = '$scheme://';
              print('Intent 스킴 추출: $targetUrl');
            }
          }
        } else {
          // 일반적인 앱 스킴 추출
          for (final scheme in appSchemes) {
            if (url.contains(scheme)) {
              // 스킴부터 시작하는 부분 추출
              final schemeIndex = url.indexOf(scheme);
              if (schemeIndex != -1) {
                targetUrl = url.substring(schemeIndex);
                // #Intent 이후 부분 제거
                final intentIndex = targetUrl.indexOf('#Intent');
                if (intentIndex != -1) {
                  targetUrl = targetUrl.substring(0, intentIndex);
                }
                print('앱 스킴 추출: $targetUrl');
                break;
              }
            }
          }
        }
      }
      
      print('최종 타겟 URL: $targetUrl');
      
      // 외부 앱 호출 시도
      final uri = Uri.parse(targetUrl);
      final canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        print('외부 앱 호출 가능: $targetUrl');
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          print('외부 앱 호출 성공');
          // 앱 호출 후 안내 다이얼로그
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('결제 앱 호출됨'),
                content: const Text('결제 앱이 실행되었습니다. 결제를 완료한 후 이 페이지로 돌아와주세요.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('확인'),
                  ),
                ],
              ),
            );
          }
        } else {
          print('외부 앱 호출 실패');
          _showAppNotInstalledDialog();
        }
      } else {
        print('외부 앱 호출 불가능: $targetUrl');
        _showAppNotInstalledDialog();
      }
    } catch (e) {
      print('외부 앱 호출 오류: $e');
      _showAppNotInstalledDialog();
    }
  }
  
  void _showAppNotInstalledDialog() {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('앱이 설치되지 않음'),
          content: const Text('해당 결제 앱이 설치되어 있지 않습니다. 다른 결제 방법을 선택하거나 앱을 설치해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  // 아임포트 결제 링크 생성 함수
  Future<String?> _createPaymentLink({
    required String merchantUid,
    required int amount,
    required String name,
    required String buyerEmail,
    required String buyerName,
  }) async {
    try {
      print('QR 링크 생성 시작...');
      print('merchant_uid: $merchantUid, amount: $amount, name: $name');
      
      final url = Uri.parse('https://api.iamport.kr/links');
      
      // 1. 토큰 발급
      print('토큰 발급 요청 시작...');
      final tokenRes = await http.post(
        Uri.parse('https://api.iamport.kr/users/getToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imp_key': 'imp31685584',
          'imp_secret': 'CO2ouD8rGkcOcUc99QTznben0b7fKBJAuJAIvoLUv8OkW0Yz0284Wg8bLnaDdBMLzSNKfju3JI2K05lF',
        }),
      );
      
      print('토큰 발급 응답 상태: ${tokenRes.statusCode}');
      print('토큰 발급 응답 본문: ${tokenRes.body}');
      
      if (tokenRes.statusCode != 200) {
        print('토큰 발급 실패: ${tokenRes.statusCode}');
        return null;
      }
      
      final tokenJson = jsonDecode(tokenRes.body);
      final accessToken = tokenJson['response']['access_token'];
      print('토큰 발급 성공: $accessToken');
      
      // 2. 결제 링크 생성
      print('결제 링크 생성 요청 시작...');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
        body: jsonEncode({
          'merchant_uid': merchantUid,
          'amount': amount,
          'name': name,
          'buyer_email': buyerEmail,
          'buyer_name': buyerName,
          'notice_url': '',
        }),
      );
      
      print('결제 링크 생성 응답 상태: ${res.statusCode}');
      print('결제 링크 생성 응답 본문: ${res.body}');
      
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final paymentUrl = json['response']?['url'];
        print('결제 링크 생성 성공: $paymentUrl');
        return paymentUrl;
      } else {
        print('결제 링크 생성 실패: ${res.statusCode}');
        return null;
      }
    } catch (e) {
      print('QR 링크 생성 예외: $e');
      return null;
    }
  }

  String _generatePaymentHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>결제</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 400px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 24px;
        }
        .header h2 {
            color: #333;
            margin: 0 0 8px 0;
        }
        .payment-info {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 24px;
        }
        .payment-info p {
            margin: 8px 0;
            color: #666;
        }
        .payment-info .amount {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
        }
        .payment-button {
            width: 100%;
            padding: 16px;
            background: #007bff;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .payment-button:hover {
            background: #0056b3;
        }
        .payment-button:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        .test-button {
            width: 100%;
            padding: 16px;
            background: #22c55e;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 12px;
            transition: background-color 0.2s;
        }
        .test-button:hover {
            background: #16a34a;
        }
        .loading {
            text-align: center;
            color: #666;
            margin-top: 16px;
        }
    </style>
    <script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
    <script type="text/javascript" src="https://cdn.iamport.kr/js/iamport.payment-1.2.0.js"></script>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>결제 정보</h2>
        </div>
        <div class="payment-info">
            <p><strong>상품명:</strong> ${widget.name}</p>
            <p><strong>주문번호:</strong> ${widget.merchantUid}</p>
            <p class="amount">${widget.amount.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},'
            )}원</p>
        </div>
        <button id="paymentButton" class="payment-button" onclick="requestPayment()">
            결제하기
        </button>
        <button id="testButton" class="test-button" onclick="requestTestPayment()">
            테스트 코드로 진행하기
        </button>
        <button id="testSuccessButton" class="test-button" onclick="simulateSuccess()">
            테스트 결제 성공
        </button>
        <button id="testFailButton" class="test-button" onclick="simulateFail()">
            테스트 결제 실패
        </button>
        <div id="loading" class="loading" style="display: none;">
            결제 처리 중...
        </div>
    </div>
    <script>
        // IMP 객체 확인 및 초기화
        var IMP = window.IMP;
        if (IMP) {
            IMP.init('imp31685584');
        }
        function requestPayment() {
            document.getElementById('paymentButton').disabled = true;
            document.getElementById('testButton').disabled = true;
            document.getElementById('testSuccessButton').disabled = true;
            document.getElementById('testFailButton').disabled = true;
            document.getElementById('paymentButton').textContent = '결제 처리 중...';
            document.getElementById('loading').style.display = 'block';
            var paymentData = {
                pg: 'html5_inicis',
                pay_method: 'card',
                merchant_uid: '${widget.merchantUid}',
                name: '${widget.name}',
                amount: ${widget.amount},
                buyer_email: '${widget.buyerEmail}',
                buyer_name: '${widget.buyerName}',
                buyer_tel: '010-1234-5678',
                buyer_addr: '서울특별시 강남구 삼성동',
                buyer_postcode: '123-456',
                popup: false,
                m_redirect_url: 'flutter://payment/'
            };
            IMP.request_pay(paymentData, function(rsp) {
                if (rsp.success) {
                    window.location.href = 'flutter://payment/?status=success&imp_uid=' + rsp.imp_uid + '&merchant_uid=' + rsp.merchant_uid;
                } else {
                    window.location.href = 'flutter://payment/?status=fail&error_msg=' + encodeURIComponent(rsp.error_msg);
                }
            });
        }
        function requestTestPayment() {
          var data = {
            merchant_uid: '${widget.merchantUid}',
            amount: ${widget.amount},
            name: '${widget.name}',
            buyer_email: '${widget.buyerEmail}',
            buyer_name: '${widget.buyerName}'
          };
          PaymentChannel.postMessage('REQUEST_PAYMENT_LINK:' + JSON.stringify(data));
        }
        function simulateSuccess() {
            document.getElementById('paymentButton').disabled = true;
            document.getElementById('testButton').disabled = true;
            document.getElementById('testSuccessButton').disabled = true;
            document.getElementById('testFailButton').disabled = true;
            document.getElementById('loading').style.display = 'block';
            setTimeout(function() {
                window.location.href = 'flutter://payment/?status=success&imp_uid=TEST_IMP_UID&merchant_uid=${widget.merchantUid}';
            }, 1000);
        }
        function simulateFail() {
            document.getElementById('paymentButton').disabled = true;
            document.getElementById('testButton').disabled = true;
            document.getElementById('testSuccessButton').disabled = true;
            document.getElementById('testFailButton').disabled = true;
            document.getElementById('loading').style.display = 'block';
            setTimeout(function() {
                window.location.href = 'flutter://payment/?status=fail&error_msg=테스트실패';
            }, 1000);
        }
        // 페이지 로드 완료 시 자동으로 결제창 띄우기
        window.onload = function() {
            setTimeout(function() {
                requestPayment();
            }, 2000);
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onPaymentResult({
              'success': false,
              'error': '사용자가 결제를 취소했습니다.',
            });
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