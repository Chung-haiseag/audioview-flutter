import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download,
                  size: 80,
                  color: Colors.grey[800],
                ),
                const SizedBox(height: 16),
                Text(
                  '다운로드한 콘텐츠가 없습니다',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 공지사항 버튼
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/notice');
                  },
                  icon: const Icon(
                    Icons.campaign_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  label: const Text(
                    '공지사항 및 이벤트',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 로그아웃 버튼
                TextButton(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    // 로그아웃 후 홈 화면으로 이동 (앱 상태 초기화 효과)
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Colors.grey[500],
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
