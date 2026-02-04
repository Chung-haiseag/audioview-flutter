import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isEmbedded;

  const LoginScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _passwordController.text);

      if (mounted) {
        // If embedded, we don't pop, we just let the parent rebuild (Consumer in MyPage will switch view)
        if (!widget.isEmbedded) {
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image with Overlay
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1574267432553-4b4628081c31?q=80&w=1000&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      if (!widget.isEmbedded)
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.of(context).maybePop(),
                        )
                      else
                        const SizedBox(
                            width:
                                48), // Spacer to balance if needed, or just nothing
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          '로그인',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '이메일 주소 또는 전화번호',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFF333333),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '비밀번호',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFF333333),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? LucideIcons.eye
                                    : LucideIcons.eyeOff,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                  () => _showPassword = !_showPassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            disabledBackgroundColor:
                                const Color(0xFFE50914).withValues(alpha: 0.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('로그인',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ),

                        const SizedBox(height: 16),

                        // OR Divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.grey)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('또는',
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 12)),
                            ),
                            const Expanded(child: Divider(color: Colors.grey)),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Kakao Login Button
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    await Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .signInWithKakao();
                                    if (mounted && !widget.isEmbedded) {
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content:
                                            Text('카카오 로그인 실패: ${e.toString()}'),
                                      ));
                                    }
                                  } finally {
                                    if (mounted)
                                      setState(() => _isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFFFEE500),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble,
                                  color: Colors.black, size: 20),
                              const SizedBox(width: 8),
                              const Text('카카오 로그인',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Naver Login Button
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    await Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .signInWithNaver();
                                    if (mounted && !widget.isEmbedded) {
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(e
                                                  .toString()
                                                  .replaceAll(
                                                      'Exception: ', ''))));
                                    }
                                  } finally {
                                    if (mounted)
                                      setState(() => _isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF03C75A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('N',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              const SizedBox(width: 8),
                              const Text('네이버 로그인',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Google Login Button
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    await Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .signInWithGoogle();
                                    if (mounted && !widget.isEmbedded) {
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('구글 로그인에 실패했습니다.')));
                                    }
                                  } finally {
                                    if (mounted)
                                      setState(() => _isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Use a more reliable icon source or fallback
                              Icon(Icons.g_mobiledata,
                                  color: Colors.blue, size: 28),
                              const SizedBox(width: 8),
                              const Text('구글 로그인',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('비밀번호를 잊으셨나요?',
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('AudioView 회원이 아닌가요? ',
                                style: TextStyle(color: Colors.grey[400])),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  '지금 가입하세요.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),

                        // Footer Links
                        const Divider(color: Colors.grey, thickness: 0.5),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Icon(LucideIcons.helpCircle,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '문의 사항이 있으신가요? 고객 센터에 문의하세요.',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
        ],
      ),
    );
  }
}
