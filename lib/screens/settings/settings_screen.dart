import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../help/request_content_screen.dart';
import '../help/privacy_policy_screen.dart';
import '../help/terms_of_service_screen.dart';
import '../help/faq_screen.dart';
import '../help/user_guide_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isLiteMode = auth.userData?['isVisuallyImpaired'] == true;

    if (isLiteMode) {
      return _buildLiteModeUI(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _buildCustomerCenter(),
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
        _buildHelpNavEntry(
          context: context,
          icon: Icons.shield_outlined,
          title: '개인정보 처리방침',
          screen: const PrivacyPolicyScreen(),
        ),
        _buildHelpNavEntry(
          context: context,
          icon: Icons.description_outlined,
          title: '이용약관',
          screen: const TermsOfServiceScreen(),
        ),
        _buildHelpNavEntry(
          context: context,
          icon: Icons.chat_bubble_outline,
          title: '자주 묻는 질문',
          screen: const FAQScreen(),
        ),
        _buildHelpNavEntry(
          context: context,
          icon: Icons.info_outline,
          title: '이용안내',
          screen: const UserGuideScreen(),
        ),
        _buildHelpNavEntry(
          context: context,
          icon: Icons.add_circle_outline,
          title: '새로운 작품 요청하기',
          subtitle: '보고 싶은 작품이 있다면 요청해 주세요',
          screen: const RequestContentScreen(),
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

  Widget _buildHelpNavEntry({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget screen,
    String? subtitle,
  }) {
    return _buildSettingItem(
      title: title,
      subtitle: subtitle ?? '내용 보기',
      value: false,
      showSwitch: false,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
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
    bool value = false,
    ValueChanged<bool>? onChanged,
    String? badge,
    bool showSwitch = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            if (showSwitch && onChanged != null) ...[
              const SizedBox(width: 16),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.red,
                activeTrackColor: Colors.red.withValues(alpha: 0.5),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
              ),
            ] else if (onTap != null) ...[
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Text(
              '고객센터',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildLiteModeItem(
            context: context,
            title: '개인정보 처리방침',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen()),
            ),
          ),
          _buildLiteModeItem(
            context: context,
            title: '이용약관',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TermsOfServiceScreen()),
            ),
          ),
          _buildLiteModeItem(
            context: context,
            title: '자주 묻는 질문',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FAQScreen()),
            ),
          ),
          _buildLiteModeItem(
            context: context,
            title: '이용안내',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserGuideScreen()),
            ),
          ),
          _buildLiteModeItem(
            context: context,
            title: '새로운 작품 요청하기',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RequestContentScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiteModeItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: title,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
