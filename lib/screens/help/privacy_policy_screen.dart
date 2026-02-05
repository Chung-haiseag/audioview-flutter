import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isLiteMode = auth.userData?['isVisuallyImpaired'] == true;

    if (isLiteMode) {
      return _buildLiteModeUI(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '개인정보 처리방침',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. 개인정보의 수집 및 이용 목적',
              '회사는 다음의 목적을 위하여 개인정보를 처리합니다.\n\n'
                  '• 회원 가입 및 관리\n'
                  '• 서비스 제공 및 개선\n'
                  '• 고객 문의 응대\n'
                  '• 마케팅 및 광고 활용',
            ),
            _buildSection(
              '2. 수집하는 개인정보 항목',
              '회사는 다음의 개인정보 항목을 수집합니다.\n\n'
                  '• 필수항목: 이메일, 비밀번호, 이름\n'
                  '• 선택항목: 전화번호, 주소',
            ),
            _buildSection(
              '3. 개인정보의 보유 및 이용기간',
              '회사는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.',
            ),
            _buildSection(
              '4. 개인정보의 제3자 제공',
              '회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다. 다만, 다음의 경우에는 예외로 합니다.\n\n'
                  '• 이용자가 사전에 동의한 경우\n'
                  '• 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우',
            ),
            _buildSection(
              '5. 정보주체의 권리·의무 및 행사방법',
              '정보주체는 회사에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다.\n\n'
                  '• 개인정보 열람 요구\n'
                  '• 오류 등이 있을 경우 정정 요구\n'
                  '• 삭제 요구\n'
                  '• 처리정지 요구',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiteModeUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/main', (route) => false);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size(60, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "뒤로가기",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              '개인정보 처리방침',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            _buildLiteModeSection(
                '1. 수집 목적', '회원 가입 및 관리, 서비스 제공 및 개선, 고객 문의 응대, 마케팅 활용'),
            _buildLiteModeSection(
                '2. 수집 항목', '필수: 이메일, 비밀번호, 이름\n선택: 전화번호, 주소'),
            _buildLiteModeSection('3. 보유 기간', '법령에 따른 기간 내에서 보유'),
            _buildLiteModeSection('4. 제3자 제공', '원칙적으로 제공하지 않음 (법령에 의한 경우 제외)'),
            _buildLiteModeSection('5. 권리 행사', '언제든지 열람, 정정, 삭제, 처리정지 요구 가능'),
          ],
        ),
      ),
    );
  }

  Widget _buildLiteModeSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
