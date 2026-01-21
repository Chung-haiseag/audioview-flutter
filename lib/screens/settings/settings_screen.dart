import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Account section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: auth.isAuthenticated
                    ? Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFFE50914),
                            child: Icon(Icons.person, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '배리어프리 회원님',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'premium_user@audioview.kr',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.grey),
                            onPressed: () => auth.logout(),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '로그인이 필요합니다',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '로그인하고 시청 기록을 동기화하세요.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE50914),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('로그인 하러가기'),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Settings list
              _buildSettingItem('일반 설정', Icons.settings),
              _buildSettingItem('접근성 기능', Icons.accessibility),
              _buildSettingItem('자막 스타일', Icons.subtitles),
              _buildSettingItem('알림 설정', Icons.notifications),
              _buildSettingItem('고객센터', Icons.help_outline),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
