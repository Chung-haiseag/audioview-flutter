import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  String _disabilityType = 'visual'; // Default value
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  /// 한국어 나레이션을 중첩 없이 안내합니다.
  void _announce(String message, {bool interrupt = false}) {
    // ignore: deprecated_member_use
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: interrupt ? Assertiveness.assertive : Assertiveness.polite,
    );
  }

  String _getDisabilityTypeName(String type) {
    switch (type) {
      case 'visual':
        return '시각 장애';
      case 'hearing':
        return '청각 장애';
      case 'none':
        return '기타 또는 비장애';
      default:
        return type;
    }
  }

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        disabilityType: _disabilityType,
      );

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text('가입 완료', style: TextStyle(color: Colors.white)),
            content: const Text('회원가입이 성공했습니다.\n로그인 화면으로 이동합니다.',
                style: TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to login
                },
                child: const Text('확인', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패: $e')),
        );
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
              'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=1000&auto=format&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.black),
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
                      Semantics(
                        label: "뒤로가기",
                        button: true,
                        excludeSemantics: true,
                        onDidGainAccessibilityFocus: () {
                          _announce("뒤로가기. 로그인 화면으로 돌아갑니다.", interrupt: true);
                        },
                        child: IconButton(
                          icon: const Icon(LucideIcons.chevronLeft,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        header: true,
                        excludeSemantics: true,
                        onDidGainAccessibilityFocus: () {
                          _announce("회원가입 화면입니다. 필수 정보를 입력하여 계정을 만드세요.", interrupt: true);
                        },
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                      children: [
                        const SizedBox(height: 20),
                        ExcludeSemantics(
                          child: const Text(
                            '계정 만들기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Name Field (Maps to username)
                        Semantics(
                          label: "이름 입력",
                          textField: true,
                          onDidGainAccessibilityFocus: () {
                            _announce("이름 입력 필드입니다. 사용할 이름을 입력하세요.", interrupt: true);
                          },
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '이름 (Username)',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: const Color(0xFF333333),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Disability Type Dropdown
                        Semantics(
                          label: "장애 유형 선택",
                          value: _getDisabilityTypeName(_disabilityType),
                          onDidGainAccessibilityFocus: () {
                            _announce("장애 유형 선택. 현재 ${_getDisabilityTypeName(_disabilityType)} 선택됨. 두 번 탭하여 변경합니다.", interrupt: true);
                          },
                          child: DropdownButtonFormField<String>(
                            value: _disabilityType,
                            dropdownColor: const Color(0xFF333333),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF333333),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'visual', child: Text('시각 장애')),
                              DropdownMenuItem(
                                  value: 'hearing', child: Text('청각 장애')),
                              DropdownMenuItem(
                                  value: 'none', child: Text('기타 / 비장애')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _disabilityType = value);
                                _announce("${_getDisabilityTypeName(value)} 선택됨", interrupt: true);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        Semantics(
                          label: "이메일 주소 입력",
                          textField: true,
                          onDidGainAccessibilityFocus: () {
                            _announce("이메일 주소 입력 필드입니다.", interrupt: true);
                          },
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '이메일 주소',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: const Color(0xFF333333),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Semantics(
                          label: "비밀번호 입력",
                          textField: true,
                          obscured: !_showPassword,
                          onDidGainAccessibilityFocus: () {
                            _announce("비밀번호 입력 필드입니다.", interrupt: true);
                          },
                          child: TextField(
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
                              suffixIcon: Semantics(
                                label: _showPassword ? "비밀번호 숨기기" : "비밀번호 보기",
                                button: true,
                                excludeSemantics: true,
                                child: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? LucideIcons.eye
                                        : LucideIcons.eyeOff,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() => _showPassword = !_showPassword);
                                    _announce(_showPassword ? "비밀번호가 보입니다" : "비밀번호가 숨겨졌습니다", interrupt: true);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        Semantics(
                          label: "비밀번호 확인 입력",
                          textField: true,
                          obscured: !_showConfirmPassword,
                          onDidGainAccessibilityFocus: () {
                            _announce("비밀번호 확인 입력 필드입니다. 위에서 입력한 비밀번호를 다시 입력하세요.", interrupt: true);
                          },
                          child: TextField(
                            controller: _passwordConfirmController,
                            obscureText: !_showConfirmPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '비밀번호 확인',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: const Color(0xFF333333),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Semantics(
                                label: _showConfirmPassword ? "비밀번호 숨기기" : "비밀번호 보기",
                                button: true,
                                excludeSemantics: true,
                                child: IconButton(
                                  icon: Icon(
                                    _showConfirmPassword
                                        ? LucideIcons.eye
                                        : LucideIcons.eyeOff,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() => _showConfirmPassword = !_showConfirmPassword);
                                    _announce(_showConfirmPassword ? "비밀번호가 보입니다" : "비밀번호가 숨겨졌습니다", interrupt: true);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        Semantics(
                          label: _isLoading ? "가입 처리 중" : "회원가입",
                          button: true,
                          enabled: !_isLoading,
                          excludeSemantics: true,
                          onDidGainAccessibilityFocus: () {
                            _announce(_isLoading ? "가입 처리 중입니다. 잠시만 기다려주세요." : "회원가입 버튼. 두 번 탭하여 가입합니다.", interrupt: true);
                          },
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
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
                                : const Text('회원가입',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ExcludeSemantics(
                              child: Text('이미 회원이신가요? ',
                                  style: TextStyle(color: Colors.grey[400])),
                            ),
                            Semantics(
                              label: "로그인 화면으로 이동",
                              button: true,
                              excludeSemantics: true,
                              onDidGainAccessibilityFocus: () {
                                _announce("로그인하기 버튼. 두 번 탭하여 로그인 화면으로 이동합니다.", interrupt: true);
                              },
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  '로그인하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
