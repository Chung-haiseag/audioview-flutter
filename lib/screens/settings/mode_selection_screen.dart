import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isLiteMode = auth.userData?['isVisuallyImpaired'] == true;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '모드 설정',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '사용하실 모드를 선택해주세요',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Normal Mode Button
              _buildModeButton(
                context,
                title: '일반 모드',
                description: '화려하고 다양한 기능',
                isTargetLite: false,
                isCurrent: !isLiteMode,
                auth: auth,
              ),

              const SizedBox(height: 32),

              // Lite Mode Button
              _buildModeButton(
                context,
                title: '간편 모드',
                description: '크고 단순한 화면',
                isTargetLite: true,
                isCurrent: isLiteMode,
                auth: auth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String title,
    required String description,
    required bool isTargetLite,
    required bool isCurrent,
    required AuthProvider auth,
  }) {
    return Semantics(
      label: '$title 선택',
      button: true,
      hint: isCurrent ? '현재 사용 중인 모드입니다.' : '$title로 변경하려면 두 번 탭하세요.',
      child: GestureDetector(
        onTap: () async {
          if (isCurrent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미 사용 중인 모드입니다.')),
            );
            return;
          }

          // Show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );

          try {
            // Update user profile
            await auth.updateUserProfile(
              nickname: auth.userData?['username'] ?? 'User',
              isVisuallyImpaired: isTargetLite,
            );

            // Wait for propagation
            await Future.delayed(const Duration(seconds: 1));

            if (context.mounted) {
              Navigator.pop(context); // Close loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('설정이 저장되었습니다. 앱을 재실행하면 적용됩니다.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // Close loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('변경 실패: $e')),
              );
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isCurrent
                ? (isTargetLite ? Colors.yellow : const Color(0xFFE50914))
                : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrent
                  ? Colors.transparent
                  : (isTargetLite ? Colors.yellow : const Color(0xFFE50914)),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCurrent
                      ? (isTargetLite ? Colors.black : Colors.white)
                      : Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  color: isCurrent
                      ? (isTargetLite ? Colors.black87 : Colors.white70)
                      : Colors.grey[400],
                  fontSize: 18,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '사용 중',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
