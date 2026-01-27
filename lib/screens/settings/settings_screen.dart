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
        // Help section header
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

        // Help menu items
        _buildHelpMenuItem(
          icon: Icons.shield_outlined,
          title: '개인정보 처리방침',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            );
          },
        ),
        _buildHelpMenuItem(
          icon: Icons.description_outlined,
          title: '이용약관',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsOfServiceScreen(),
              ),
            );
          },
        ),
        _buildHelpMenuItem(
          icon: Icons.chat_bubble_outline,
          title: '자주 묻는 질문',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FAQScreen(),
              ),
            );
          },
        ),
        _buildHelpMenuItem(
          icon: Icons.info_outline,
          title: '이용안내',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserGuideScreen(),
              ),
            );
          },
        ),
        _buildHelpMenuItem(
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

        // Production info
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

        // Contact info
        Container(
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
                    child: const Icon(
                      Icons.email_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMAIL',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'kbu1004@hanmail.com',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
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
                    child: const Icon(
                      Icons.phone_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHONE',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '02-799-1000',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHelpMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 20,
        ),
        onTap: onTap,
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
