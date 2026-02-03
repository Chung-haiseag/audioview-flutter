import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          '이용약관',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '제1조 (목적)',
              '본 약관은 AudioView(이하 "회사")가 제공하는 배리어프리 영상 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
            ),
            _buildSection(
              '제2조 (정의)',
              '1. "서비스"란 회사가 제공하는 배리어프리 영상 콘텐츠 스트리밍 서비스를 의미합니다.\n'
                  '2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 이용하는 회원 및 비회원을 말합니다.\n'
                  '3. "회원"이란 회사와 서비스 이용계약을 체결하고 회원 아이디를 부여받은 자를 말합니다.',
            ),
            _buildSection(
              '제3조 (약관의 효력 및 변경)',
              '1. 본 약관은 서비스를 이용하고자 하는 모든 이용자에게 그 효력이 발생합니다.\n'
                  '2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위 내에서 본 약관을 변경할 수 있습니다.',
            ),
            _buildSection(
              '제4조 (서비스의 제공)',
              '1. 회사는 다음과 같은 서비스를 제공합니다:\n'
                  '   • 화면해설(AD) 서비스\n'
                  '   • 문자자막(CC) 서비스\n'
                  '   • 다국어자막 서비스\n'
                  '   • 영상 콘텐츠 스트리밍\n\n'
                  '2. 서비스는 연중무휴 1일 24시간 제공함을 원칙으로 합니다.',
            ),
            _buildSection(
              '제5조 (이용자의 의무)',
              '이용자는 다음 행위를 하여서는 안 됩니다:\n\n'
                  '1. 타인의 정보 도용\n'
                  '2. 회사가 게시한 정보의 변경\n'
                  '3. 회사가 정한 정보 이외의 정보 등의 송신 또는 게시\n'
                  '4. 회사와 기타 제3자의 저작권 등 지적재산권에 대한 침해\n'
                  '5. 회사 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위',
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
              '이용약관',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            _buildLiteModeSection('제1조 (목적)',
                '본 약관은 AudioView가 제공하는 배리어프리 영상 서비스의 이용 규정을 목적으로 합니다.'),
            _buildLiteModeSection('제2조 (정의)',
                '1. 서비스: 배리어프리 영상 콘텐츠 스트리밍\n2. 이용자: 서비스를 이용하는 회원 및 비회원\n3. 회원: 이용계약을 체결하고 아이디를 부여받은 자'),
            _buildLiteModeSection('제3조 (약관의 효력)',
                '본 약관은 모든 이용자에게 효력이 발생하며, 회사는 필요한 경우 약관을 변경할 수 있습니다.'),
            _buildLiteModeSection(
                '제4조 (서비스 제공)', '화면해설, 문자자막, 다국어자막 등을 24시간 제공합니다.'),
            _buildLiteModeSection(
                '제5조 (이용자의 의무)', '타인 정보 도용, 정보 변경, 저작권 침해, 업무 방해 등을 금지합니다.'),
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
