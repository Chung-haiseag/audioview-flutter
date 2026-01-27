import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../help/request_content_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedTab = 0; // 0: 환경설정, 1: 고객센터
  int _expandedIndex =
      -1; // -1: all closed, 0: Privacy, 1: Terms, 2: FAQ, 3: Guide

  // Settings states
  bool _smartGlasses = true;
  bool _use3GLTE = true;
  bool _expandRecognition = false;
  bool _audioDescription = false;
  bool _closedCaption = false;
  bool _multiLanguage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          // Tab bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildTab('환경설정', 0),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTab('고객센터', 1),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildEnvironmentSettings()
                : _buildCustomerCenter(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _expandedIndex = -1; // Reset accordion expansion when switching tabs
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.red : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentSettings() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Smart Glasses
            _buildSettingItem(
              title: '스마트 안경',
              subtitle: '스마트 안경 연동 설정',
              value: _smartGlasses,
              onChanged: (value) => setState(() => _smartGlasses = value),
              badge: '연동됨',
            ),

            const SizedBox(height: 16),

            // 3G/LTE Usage
            _buildSettingItem(
              title: '3G/LTE 사용',
              subtitle: '체크 해제시 WiFi에서만 사용가능',
              value: _use3GLTE,
              onChanged: (value) => setState(() => _use3GLTE = value),
            ),

            const SizedBox(height: 16),

            // Expand Recognition
            _buildSettingItem(
              title: '인식구간 확장하기',
              subtitle: '음성인식 영상물 전체로 확장',
              value: _expandRecognition,
              onChanged: (value) => setState(() => _expandRecognition = value),
            ),

            const SizedBox(height: 32),

            // Accessibility Settings Header
            const Text(
              '접근성 기능 설정',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '화면해설, 자막 등 모든 보조 기능 켜기/끄기',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            // Audio Description (AD)
            _buildSettingItem(
              title: '화면해설 (AD)',
              subtitle: '시각장애인용 오디오자막',
              value: _audioDescription,
              onChanged: (value) => setState(() => _audioDescription = value),
            ),

            const SizedBox(height: 16),

            // Closed Caption (CC)
            _buildSettingItem(
              title: '문자자막 (CC)',
              subtitle: '청각장애인용 대사 및 소리자막',
              value: _closedCaption,
              onChanged: (value) => setState(() => _closedCaption = value),
            ),

            const SizedBox(height: 16),

            // Multi-language Subtitle
            _buildSettingItem(
              title: '다국어자막',
              subtitle: '외국인용 다국어 문자자막',
              value: _multiLanguage,
              onChanged: (value) => setState(() => _multiLanguage = value),
            ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildCustomerCenter() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.help_outline, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              '무엇을 도와드릴까요?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildHelpAccordionItem(
          index: 0,
          icon: Icons.shield_outlined,
          title: '개인정보 처리방침',
          content: _buildPrivacyPolicyContent(),
        ),
        _buildHelpAccordionItem(
          index: 1,
          icon: Icons.description_outlined,
          title: '이용약관',
          content: _buildTermsOfServiceContent(),
        ),
        _buildHelpAccordionItem(
          index: 2,
          icon: Icons.chat_bubble_outline,
          title: '자주 묻는 질문',
          content: _buildFAQContent(),
        ),
        _buildHelpAccordionItem(
          index: 3,
          icon: Icons.info_outline,
          title: '이용안내',
          content: _buildUserGuideContent(),
        ),
        _buildHelpAccordionItem(
          index: 4,
          icon: Icons.add_circle_outline,
          title: '새로운 작품 요청하기',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RequestContentScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        const Text(
          'PRODUCTION',
          style:
              TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        const Text(
          '제작 : (사)한국시각장애인연합회',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildContactInfo(),
      ],
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentSection('1. 개인정보의 수집 및 이용 목적',
            '회사는 회원 가입 및 관리, 서비스 제공 및 개선, 고객 문의 응대, 마케팅 및 광고 활용을 위해 개인정보를 처리합니다.'),
        _buildContentSection(
            '2. 수집하는 개인정보 항목', '• 필수: 이메일, 비밀번호, 이름\n• 선택: 전화번호, 주소'),
        _buildContentSection('3. 개인정보의 보유 및 이용기간',
            '법령에 따른 보유기간 또는 수집 시 동의받은 기간 내에서 개인정보를 처리·보유합니다.'),
        _buildContentSection('4. 개인정보의 제3자 제공',
            '원칙적으로 제3자에게 제공하지 않으나, 법령 의거 또는 본인 동의 시 예외로 합니다.'),
        _buildContentSection('5. 정보주체의 권리·의무 및 행사방법',
            '언제든지 열람, 정정, 삭제, 처리정지 등의 권리를 행사할 수 있습니다.'),
      ],
    );
  }

  Widget _buildTermsOfServiceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentSection('제1조 (목적)',
            'AudioView(이하 "회사")가 제공하는 배리어프리 영상 서비스의 이용과 관련하여 회사와 이용자의 권리, 의무를 규정합니다.'),
        _buildContentSection('제2조 (정의)', '서비스, 이용자, 회원 등에 대한 용어의 정의를 규정합니다.'),
        _buildContentSection('제3조 (약관의 효력 및 변경)',
            '약관은 이용자에게 효력이 발생하며, 회사는 필요한 경우 약관을 변경할 수 있습니다.'),
        _buildContentSection('제4조 (서비스의 제공)',
            '화면해설(AD), 문자자막(CC), 다국어자막, 스트리밍 등의 서비스를 24시간 제공합니다.'),
        _buildContentSection(
            '제5조 (이용자의 의무)', '타인 정보 도용, 저작권 침해 등 서비스 방해 행위를 하여서는 안 됩니다.'),
      ],
    );
  }

  Widget _buildFAQContent() {
    return Column(
      children: [
        _buildFAQBrief(
            '화면해설(AD)이란 무엇인가요?', '시각장애인을 위해 영상의 장면과 동작을 음성으로 설명해주는 기능입니다.'),
        _buildFAQBrief(
            '문자자막(CC)이란 무엇인가요?', '청각장애인을 위해 대사, 배경음악, 효과음 등을 텍스트로 제공하는 기능입니다.'),
        _buildFAQBrief('스마트 안경 연동 방법은?', '블루투스 페어링 후 설정에서 활성화하여 연동할 수 있습니다.'),
        _buildFAQBrief(
            'WiFi 없이 사용 가능한가요?', '설정에서 "3G/LTE 사용"을 활성화하면 데이터로 이용 가능합니다.'),
        _buildFAQBrief('다운로드 가능한가요?', '현재는 스트리밍만 제공하며, 다운로드는 추후 업데이트 예정입니다.'),
        _buildFAQBrief('동시 시청 기기 수는?', '계정당 최대 2대(프리미엄 4대)까지 동시 시청을 지원합니다.'),
        _buildFAQBrief('자막 크기 조절?', '설정의 "자막 스타일 설정"에서 자유롭게 조절할 수 있습니다.'),
        _buildFAQBrief(
            '회원 탈퇴 방법은?', '설정 > 계정 관리 메뉴에서 가능하며, 탈퇴 시 모든 기록이 파기됩니다.'),
      ],
    );
  }

  Widget _buildUserGuideContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentSection(
            '서비스 소개', '장애의 벽 없는 배리어프리 영상 콘텐츠 플랫폼 AudioView입니다.'),
        _buildContentSection(
            '회원가입 및 로그인', 'MY 탭에서 이메일 인증을 통해 간편하게 가입하고 시청 기록을 관리하세요.'),
        _buildContentSection(
            '영화 시청하기', '장르별 카테고리에서 원하는 영화를 선택하고 AD/CC 버튼을 눌러 감상하세요.'),
        _buildContentSection(
            '스마트 안경 연동', '블루투스 연결을 통해 시각장애인용 오디오 설명을 안경으로 직접 들을 수 있습니다.'),
        _buildContentSection(
            '새로운 작품 요청', '보고 싶은 작품이 있다면 고객센터의 "신규 요청" 메뉴를 이용해 주세요.'),
      ],
    );
  }

  Widget _buildContentSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(content,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildHelpAccordionItem({
    required int index,
    required IconData icon,
    required String title,
    Widget? content,
    VoidCallback? onTap,
  }) {
    final bool isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: onTap != null
            ? ListTile(
                leading: Icon(icon, color: Colors.grey, size: 20),
                title: Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right,
                    color: Colors.grey, size: 20),
                onTap: onTap,
              )
            : ExpansionTile(
                key: PageStorageKey<int>(index),
                initiallyExpanded: isExpanded,
                leading: Icon(icon, color: Colors.grey, size: 20),
                title: Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                iconColor: Colors.white,
                collapsedIconColor: Colors.grey,
                onExpansionChanged: (expanding) {
                  setState(() {
                    if (expanding) {
                      _expandedIndex = index;
                    } else {
                      if (_expandedIndex == index) {
                        _expandedIndex = -1;
                      }
                    }
                  });
                },
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: content ?? const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFAQBrief(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(a, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.email_outlined,
                    color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EMAIL',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.2)),
                  SizedBox(height: 4),
                  Text('kbu1004@hanmail.com',
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_outlined,
                    color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PHONE',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.2)),
                  SizedBox(height: 4),
                  Text('02-799-1000',
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.red,
            activeTrackColor: Colors.red.withValues(alpha: 0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
