import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _passwordController.text);
      
      if (mounted) {
        // Navigate or let the AuthWrapper handle it
       // In Flutter, usually AuthWrapper listens to AuthProvider and switches pages.
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
          // Background Layer
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  return Image.network(
                    'https://picsum.photos/seed/${index + 50}/300/450',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.black45, Colors.black],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AUDIOVIEW',
                        style: TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
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

                        // Form
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: '이메일 주소 또는 전화번호',
                            prefixIcon: Icon(LucideIcons.mail, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: '비밀번호',
                            prefixIcon: const Icon(LucideIcons.lock, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24, 
                                  height: 24, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text('로그인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),

                        const SizedBox(height: 24),
                        
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('비밀번호를 잊으셨나요?', style: TextStyle(color: Colors.grey)),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('AudioView 회원이 아닌가요?', style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('지금 가입하세요.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.helpCircle, size: 16, color: Colors.grey),
                        label: const Text('문의 사항이 있으신가요? 고객 센터에 문의하세요.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
        ],
      ),
    );
  }
}
