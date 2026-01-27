import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../help/privacy_policy_screen.dart';
import '../help/terms_of_service_screen.dart';
import '../help/faq_screen.dart';
import '../help/user_guide_screen.dart';
import '../help/request_content_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedTab = 0; // 0: 환경설정, 1: 고객센터

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
      onTap: () => setState(() => _selectedTab = index),
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
              child: const Icon(
                Icons.help_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '무엇을 도와드릴까요?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildHelpAccordionItem(
          icon: Icons.shield_outlined,
          title: '개인정보 처리방침',
          content:
              '회사는 회원 가입 및 관리, 서비스 제공 및 개선, 고객 문의 응대 등을 위해 개인정보를 수집 및 이용합니다.\n\n'
              '• 필수항목: 이메일, 비밀번호, 이름\n'
              '• 선택항목: 전화번호, 주소\n\n'
              '개인정보는 원칙적으로 보유 및 이용기간이 경과하면 지체 없이 파기합니다.',
        ),
        _buildHelpAccordionItem(
          icon: Icons.description_outlined,
          title: '이용약관',
          content:
              '본 약관은 AudioView가 제공하는 배리어프리 영상 서비스의 이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.\n\n'
              '회사는 화면해설(AD), 문자자막(CC), 다국어자막 스트리밍 서비스를 제공하며 이용자는 타인의 정보 도용이나 저작권 침해 행위를 하여서는 안 됩니다.',
        ),
        _buildHelpAccordionItem(
          icon: Icons.chat_bubble_outline,
          title: '자주 묻는 질문',
          isFAQ: true,
        ),
        _buildHelpAccordionItem(
          icon: Icons.info_outline,
          title: '이용안내',
          content: 'AudioView는 시청각장애인과 비장애인 모두가 즐길 수 있는 배리어프리 콘텐츠 플랫폼입니다.\n\n'
              '앱 하단의 내비게이션이나 햄버거 메뉴를 통해 다양한 장르의 영화를 감상하실 수 있으며, 설정 메뉴에서 스마트 안경 연동 및 접근성 기능을 조절할 수 있습니다.',
        ),
        _buildHelpAccordionItem(
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
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '제작 : (사)한국시각장애인연합회',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildContactInfo(),
      ],
    );
  }

  Widget _buildHelpAccordionItem({
    required IconData icon,
    required String title,
    String? content,
    bool isFAQ = false,
    VoidCallback? onTap,
  }) {
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
                leading: Icon(icon, color: Colors.grey, size: 20),
                title: Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                iconColor: Colors.white,
                collapsedIconColor: Colors.grey,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: isFAQ
                        ? Column(
                            children: [
                              _buildFAQBrief(
                                  '화면해설(AD)이란?', '시각장애인을 위한 장면 및 동작 음성 설명'),
                              _buildFAQBrief(
                                  '문자자막(CC)이란?', '청각장애인을 위한 대사 및 효과음 자막'),
                              _buildFAQBrief(
                                  '스마트 안경 연동?', '블루투스 페어링 후 설정에서 활성화'),
                            ],
                          )
                        : Text(
                            content ?? '',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13, height: 1.5),
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
