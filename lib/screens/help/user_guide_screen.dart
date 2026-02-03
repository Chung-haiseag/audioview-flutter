import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

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
          '이용안내',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '서비스 소개',
              'AudioView는 시각·청각장애인을 위한 배리어프리 영상 서비스입니다. 화면해설(AD), 문자자막(CC), 다국어자막 등 다양한 접근성 기능을 제공합니다.',
              Icons.info_outline,
            ),
            _buildSection(
              '회원가입 및 로그인',
              '1. 메인 화면 하단의 "MY" 탭을 선택합니다.\n'
                  '2. "로그인 하러가기" 버튼을 클릭합니다.\n'
                  '3. 이메일과 비밀번호를 입력하여 로그인합니다.\n'
                  '4. 신규 회원은 "회원가입" 버튼을 통해 가입할 수 있습니다.',
              Icons.login,
            ),
            _buildSection(
              '영화 시청하기',
              '1. 홈 화면에서 원하는 카테고리를 선택합니다.\n'
                  '2. 영화 포스터를 클릭하여 상세 정보를 확인합니다.\n'
                  '3. 화면해설(AD) 또는 문자자막(CC) 버튼을 선택합니다.\n'
                  '4. 동기화가 완료되면 영상이 재생됩니다.',
              Icons.play_circle_outline,
            ),
            _buildSection(
              '화면해설(AD) 사용법',
              '화면해설은 시각장애인을 위한 기능으로, 영상의 장면과 동작을 음성으로 설명합니다.\n\n'
                  '• 영화 상세 화면에서 "화면해설(AD)" 버튼 선택\n'
                  '• 스마트 안경 연동 시 안경을 통해 청취 가능\n'
                  '• 설정에서 음량 조절 가능',
              Icons.record_voice_over,
            ),
            _buildSection(
              '문자자막(CC) 사용법',
              '문자자막은 청각장애인을 위한 기능으로, 대사와 효과음을 텍스트로 표시합니다.\n\n'
                  '• 영화 상세 화면에서 "문자자막(CC)" 버튼 선택\n'
                  '• 설정에서 자막 크기, 색상, 배경 조절 가능\n'
                  '• 다국어자막도 함께 제공',
              Icons.closed_caption,
            ),
            _buildSection(
              '스마트 안경 연동',
              '1. 설정 메뉴로 이동합니다.\n'
                  '2. "스마트 안경" 항목을 선택합니다.\n'
                  '3. 블루투스를 켜고 안경을 페어링합니다.\n'
                  '4. 연동 완료 후 영상 시청 시 안경으로 화면해설을 들을 수 있습니다.',
              Icons.remove_red_eye_outlined,
            ),
            _buildSection(
              '고객센터 문의',
              '서비스 이용 중 문제가 발생하거나 문의사항이 있으시면 언제든지 연락주세요.\n\n'
                  '• 이메일: kbu1004@hanmail.com\n'
                  '• 전화: 02-799-1000\n'
                  '• 운영시간: 평일 09:00 - 18:00',
              Icons.support_agent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardUI(BuildContext context) {
    return SingleChildScrollView(
        // ... (Original Code) ...
        // Reused structure in build but kept separate for clarity if needed.
        // Actually, just returning Scaffold in build is simpler since Standard has Scaffold in build.
        // So I kept the standard scaffold in `build` after the check.
        );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
              '이용안내',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            _buildLiteModeSection('서비스 소개',
                'AudioView는 시각·청각장애인을 위한 배리어프리 영상 서비스입니다. 화면해설(AD), 문자자막(CC), 다국어자막 등 다양한 접근성 기능을 제공합니다.'),
            _buildLiteModeSection('회원가입 및 로그인',
                '1. 메인 화면 하단의 "MY" 탭 선택\n2. "로그인 하러가기" 버튼 클릭\n3. 이메일과 비밀번호 입력\n4. 신규 회원은 "회원가입" 버튼 이용'),
            _buildLiteModeSection('영화 시청하기',
                '1. 홈 화면에서 원하는 카테고리 선택\n2. 영화 포스터 클릭하여 상세 정보 확인\n3. 화면해설(AD) 또는 문자자막(CC) 버튼 선택\n4. 동기화 완료 후 영상 재생'),
            _buildLiteModeSection('화면해설(AD) 사용법',
                '화면해설은 시각장애인을 위한 기능으로, 영상의 장면과 동작을 음성으로 설명합니다.\n• 영화 상세 화면에서 AD 버튼 선택\n• 스마트 안경 연동 시 안경 청취 가능'),
            _buildLiteModeSection('문자자막(CC) 사용법',
                '문자자막은 청각장애인을 위한 기능으로, 대사와 효과음을 텍스트로 표시합니다.\n• 영화 상세 화면에서 CC 버튼 선택\n• 설정에서 자막 조절 가능'),
            _buildLiteModeSection('스마트 안경 연동',
                '1. 설정 메뉴 이동\n2. "스마트 안경" 선택\n3. 블루투스 페어링\n4. 연동 완료 후 사용'),
            _buildLiteModeSection('고객센터 문의',
                '• 이메일: kbu1004@hanmail.com\n• 전화: 02-799-1000\n• 운영시간: 평일 09:00 - 18:00'),
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
