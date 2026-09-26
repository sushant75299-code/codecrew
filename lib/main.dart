import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const StockSenseApp());
}

// ============================================================
// APP
// ============================================================

class StockSenseApp extends StatelessWidget {
  const StockSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          surface: Color(0xFF0F172A),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.login(
        email: _identifierController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.all_inbox_rounded,
                          size: 36,
                          color: Color(0xFF34D399),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome to StockSense',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your credentials to access your inventory',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Login ID or Business Email',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: _authInputDecoration(
                        hint: 'e.g. user@stocksense.com',
                        icon: Icons.mail_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitLogin(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: _authInputDecoration(
                        hint: '••••••••••••',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF64748B),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible =
                                  !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor:
                                    const Color(0xFF10B981),
                                checkColor: Colors.black,
                                side: const BorderSide(
                                  color: Color(0xFF475569),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF34D399),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _submitLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF10B981),
                          foregroundColor:
                              const Color(0xFF070B12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFF070B12),
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF34D399),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER PAGE
// ============================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration successful. Please login.',
          ),
          backgroundColor: Color(0xFF16A34A),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 36,
                          color: Color(0xFF34D399),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Create Your Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Register a new StockSense user account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: _authInputDecoration(
                        hint: 'Enter your name',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: _authInputDecoration(
                        hint: 'user@example.com',
                        icon: Icons.mail_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: _authInputDecoration(
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller:
                          _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: _authInputDecoration(
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword =
                                  !_showConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF10B981),
                          foregroundColor:
                              const Color(0xFF070B12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFF070B12),
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FORGOT PASSWORD PAGE
// ============================================================

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _otpSent = true;
      });

      // The backend returns the OTP directly
      // for development/testing.
      String? otp;

      if (result['otp'] != null) {
        otp = result['otp'].toString();
      }

      if (otp != null && otp.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('OTP Generated'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your OTP for testing is:',
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981)
                          .withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      otp!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 5,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF10B981),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'OTP generated successfully.',
            ),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.resetPassword(
        email: _emailController.text.trim(),
        otp: _otpController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Password Reset Successful',
            ),
            content: const Text(
              'Your password has been reset successfully. You can now login with your new password.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF10B981),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981)
                            .withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 36,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Forgot Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _otpSent
                        ? 'Enter the OTP and create a new password'
                        : 'Enter your email to receive an OTP',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (!_otpSent)
                    Form(
                      key: _emailFormKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _emailController,
                            keyboardType:
                                TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration:
                                _authInputDecoration(
                              hint: 'user@example.com',
                              icon:
                                  Icons.mail_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : _sendOtp,
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF10B981),
                                foregroundColor:
                                    const Color(0xFF070B12),
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Color(0xFF070B12),
                                      ),
                                    )
                                  : const Text(
                                      'Generate OTP',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_otpSent)
                    Form(
                      key: _resetFormKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'OTP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _otpController,
                            keyboardType:
                                TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration:
                                _authInputDecoration(
                              hint: 'Enter OTP',
                              icon:
                                  Icons.password_rounded,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter the OTP';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'New Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller:
                                _newPasswordController,
                            obscureText:
                                !_showNewPassword,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration:
                                _authInputDecoration(
                              hint: '••••••••',
                              icon:
                                  Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showNewPassword =
                                        !_showNewPassword;
                                  });
                                },
                                icon: Icon(
                                  _showNewPassword
                                      ? Icons
                                          .visibility_off_outlined
                                      : Icons
                                          .visibility_outlined,
                                  color:
                                      const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please enter a new password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller:
                                _confirmPasswordController,
                            obscureText:
                                !_showConfirmPassword,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration:
                                _authInputDecoration(
                              hint: '••••••••',
                              icon:
                                  Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showConfirmPassword =
                                        !_showConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _showConfirmPassword
                                      ? Icons
                                          .visibility_off_outlined
                                      : Icons
                                          .visibility_outlined,
                                  color:
                                      const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value !=
                                  _newPasswordController
                                      .text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : _resetPassword,
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF10B981),
                                foregroundColor:
                                    const Color(0xFF070B12),
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Color(0xFF070B12),
                                      ),
                                    )
                                  : const Text(
                                      'Reset Password',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _otpSent = false;
                                      _otpController.clear();
                                      _newPasswordController
                                          .clear();
                                      _confirmPasswordController
                                          .clear();
                                    });
                                  },
                            child: const Text(
                              'Use a different email',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  int selectedMenu = 0;
  bool darkMode = false;

  String selectedDocType = 'All Document Types';
  String selectedStatus = 'All Status';
  String selectedWarehouse = 'All Warehouses';
  String selectedCategory = 'All Categories';

  final List<String> menuItems = [
    'Dashboard',
    'Products',
    'Receipts',
    'Delivery Orders',
    'Internal Transfers',
    'Inventory Adjustments',
    'Move History',
    'Warehouse',
    'Settings',
    'My Profile',
    'Logout',
  ];

  final List<Map<String, String>> operations = [
    {
      'reference': 'REC-1024',
      'product': 'Steel Rods',
      'sku': 'SKU-STR-001',
      'operation': 'Receipt',
      'quantity': '+50',
      'location': 'Main Warehouse',
      'status': 'Done',
    },
    {
      'reference': 'DEL-2041',
      'product': 'Office Chairs',
      'sku': 'SKU-CHR-102',
      'operation': 'Delivery',
      'quantity': '-10',
      'location': 'Warehouse 1',
      'status': 'Waiting',
    },
    {
      'reference': 'TRF-3012',
      'product': 'Steel Sheets',
      'sku': 'SKU-STL-204',
      'operation': 'Internal Transfer',
      'quantity': '25',
      'location': 'Production Rack',
      'status': 'Ready',
    },
    {
      'reference': 'ADJ-4009',
      'product': 'Steel Rods',
      'sku': 'SKU-STR-001',
      'operation': 'Adjustment',
      'quantity': '-3',
      'location': 'Main Warehouse',
      'status': 'Done',
    },
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }

  Future<void> openAddProductDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return const AddProductDialog();
      },
    );

    if (result == true && mounted) {
      showMessage('Product added successfully.');
    }
  }

  Widget buildContent() {
    if (selectedMenu == 1) {
      return ProductsScreen(
        darkMode: darkMode,
        onAddProduct: openAddProductDialog,
      );
    }

    return buildDashboardContent();
  }

  Widget buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventory Dashboard',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: darkMode
                          ? Colors.white
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Monitor your inventory operations in real time.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: openAddProductDialog,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text(
                  'Add Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2563EB),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth =
                  constraints.maxWidth > 900
                      ? (constraints.maxWidth -
                              (18 * 3)) /
                          4
                      : (constraints.maxWidth -
                              18) /
                          2;

              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: statCard(
                      title: 'Total Products',
                      value: '1,284',
                      icon: Icons.inventory_2,
                      iconBackground:
                          const Color(0xFFDBEAFE),
                      iconColor:
                          const Color(0xFF2563EB),
                      trend:
                          '↑ 8.2% from last month',
                      trendColor:
                          const Color(0xFF16A34A),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: statCard(
                      title: 'Low Stock Items',
                      value: '37',
                      icon: Icons.warning_amber,
                      iconBackground:
                          const Color(0xFFFEF3C7),
                      iconColor:
                          const Color(0xFFD97706),
                      trend: '↑ Needs attention',
                      trendColor:
                          const Color(0xFFDC2626),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: statCard(
                      title: 'Out of Stock',
                      value: '12',
                      icon: Icons.cancel,
                      iconBackground:
                          const Color(0xFFFEE2E8),
                      iconColor:
                          const Color(0xFFDC2626),
                      trend: '↑ 3 new today',
                      trendColor:
                          const Color(0xFFDC2626),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: statCard(
                      title: 'Pending Receipts',
                      value: '24',
                      icon: Icons.local_shipping,
                      iconBackground:
                          const Color(0xFFDCFCE7),
                      iconColor:
                          const Color(0xFF16A34A),
                      trend: '◷ 8 due today',
                      trendColor:
                          const Color(0xFF16A34A),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: darkMode
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              border: Border.all(
                color: darkMode
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isWide =
                    constraints.maxWidth > 800;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: isWide
                          ? (constraints.maxWidth -
                                  36) /
                              4
                          : (constraints.maxWidth -
                                  12) /
                              2,
                      child: filterDropdown(
                        selectedDocType,
                        [
                          'All Document Types',
                          'Receipts',
                          'Delivery',
                          'Internal',
                          'Adjustments',
                        ],
                        (val) => setState(
                          () => selectedDocType =
                              val!,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isWide
                          ? (constraints.maxWidth -
                                  36) /
                              4
                          : (constraints.maxWidth -
                                  12) /
                              2,
                      child: filterDropdown(
                        selectedStatus,
                        [
                          'All Status',
                          'Draft',
                          'Waiting',
                          'Ready',
                          'Done',
                          'Canceled',
                        ],
                        (val) => setState(
                          () => selectedStatus =
                              val!,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isWide
                          ? (constraints.maxWidth -
                                  36) /
                              4
                          : (constraints.maxWidth -
                                  12) /
                              2,
                      child: filterDropdown(
                        selectedWarehouse,
                        [
                          'All Warehouses',
                          'Main Warehouse',
                          'Warehouse 1',
                          'Warehouse 2',
                        ],
                        (val) => setState(
                          () => selectedWarehouse =
                              val!,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isWide
                          ? (constraints.maxWidth -
                                  36) /
                              4
                          : (constraints.maxWidth -
                                  12) /
                              2,
                      child: filterDropdown(
                        selectedCategory,
                        [
                          'All Categories',
                          'Steel',
                          'Furniture',
                          'Electronics',
                        ],
                        (val) => setState(
                          () => selectedCategory =
                              val!,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: inventoryChart(),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: categoryChart(),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  inventoryChart(),
                  const SizedBox(height: 20),
                  categoryChart(),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: darkMode
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              border: Border.all(
                color: darkMode
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Operations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkMode
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(
                        label: Text('REFERENCE'),
                      ),
                      DataColumn(
                        label: Text('PRODUCT'),
                      ),
                      DataColumn(
                        label: Text('SKU'),
                      ),
                      DataColumn(
                        label: Text('TYPE'),
                      ),
                      DataColumn(
                        label: Text('QTY'),
                      ),
                      DataColumn(
                        label: Text('LOCATION'),
                      ),
                      DataColumn(
                        label: Text('STATUS'),
                      ),
                    ],
                    rows: operations.map((op) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              op['reference']!,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(op['product']!),
                          ),
                          DataCell(
                            Text(op['sku']!),
                          ),
                          DataCell(
                            Text(op['operation']!),
                          ),
                          DataCell(
                            Text(op['quantity']!),
                          ),
                          DataCell(
                            Text(op['location']!),
                          ),
                          DataCell(
                            buildStatusBadge(
                              op['status']!,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: darkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF5F7FB),
      appBar: !isDesktop
          ? AppBar(
              backgroundColor:
                  const Color(0xFF0F172A),
              title: const Text(
                'StockSense',
                style:
                    TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
            )
          : null,
      drawer: !isDesktop
          ? Drawer(
              child: buildSidebarContent(),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 250,
              child: buildSidebarContent(),
            ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 72,
                  color: darkMode
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration:
                              BoxDecoration(
                            color: darkMode
                                ? const Color(
                                    0xFF334155)
                                : const Color(
                                    0xFFF8FAFC),
                            border: Border.all(
                              color: darkMode
                                  ? const Color(
                                      0xFF475569)
                                  : const Color(
                                      0xFFE2E8F0),
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              9,
                            ),
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: darkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            decoration:
                                const InputDecoration(
                              border:
                                  InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color:
                                    Color(0xFF64748B),
                              ),
                              hintText:
                                  'Search products, SKU...',
                              hintStyle: TextStyle(
                                color:
                                    Color(0xFF64748B),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            darkMode = !darkMode;
                          });
                          showMessage('Theme changed');
                        },
                        icon: Icon(
                          darkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: darkMode
                              ? Colors.amber
                              : Colors.black87,
                        ),
                        style:
                            IconButton.styleFrom(
                          backgroundColor: darkMode
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Stack(
                        clipBehavior:
                            Clip.none,
                        children: [
                          IconButton(
                            onPressed: () =>
                                showMessage(
                              'You have 3 new notifications',
                            ),
                            icon: Icon(
                              Icons
                                  .notifications_none,
                              color: darkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            style:
                                IconButton.styleFrom(
                              backgroundColor:
                                  darkMode
                                      ? const Color(
                                          0xFF334155)
                                      : const Color(
                                          0xFFF1F5F9),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration:
                                  const BoxDecoration(
                                color:
                                    Color(0xFFDC2626),
                                shape:
                                    BoxShape.circle,
                              ),
                              child:
                                  const Center(
                                child: Text(
                                  '3',
                                  style: TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 20),

                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                Color(0xFFDBEAFE),
                            child: Text(
                              'TS',
                              style: TextStyle(
                                color:
                                    Color(0xFF2563EB),
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'Tushar',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color: darkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const Text(
                                'Inventory Manager',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons
                                .keyboard_arrow_down,
                            color:
                                Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebarContent() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              20,
              14,
              25,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF2563EB),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: 'Stock',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'Sense',
                        style: TextStyle(
                          color:
                              Color(0xFF60A5FA),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                sidebarTitle('MAIN'),
                sidebarItem(
                  index: 0,
                  icon: Icons.pie_chart,
                  title: 'Dashboard',
                ),
                sidebarItem(
                  index: 1,
                  icon: Icons.inventory_2,
                  title: 'Products',
                ),
                sidebarTitle('OPERATIONS'),
                sidebarItem(
                  index: 2,
                  icon: Icons.local_shipping,
                  title: 'Receipts',
                ),
                sidebarItem(
                  index: 3,
                  icon:
                      Icons.local_shipping_outlined,
                  title: 'Delivery Orders',
                ),
                sidebarItem(
                  index: 4,
                  icon: Icons.swap_horiz,
                  title: 'Internal Transfers',
                ),
                sidebarItem(
                  index: 5,
                  icon: Icons.tune,
                  title:
                      'Inventory Adjustments',
                ),
                sidebarItem(
                  index: 6,
                  icon: Icons.history,
                  title: 'Move History',
                ),
                sidebarTitle('MANAGEMENT'),
                sidebarItem(
                  index: 7,
                  icon: Icons.warehouse,
                  title: 'Warehouse',
                ),
                sidebarItem(
                  index: 8,
                  icon: Icons.settings,
                  title: 'Settings',
                ),
                const Divider(
                  color: Color(0xFF1E293B),
                ),
                sidebarItem(
                  index: 9,
                  icon: Icons.person,
                  title: 'My Profile',
                ),
                sidebarItem(
                  index: 10,
                  icon: Icons.logout,
                  title: 'Logout',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sidebarTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget sidebarItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected =
        selectedMenu == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8),
        ),
        selected: isSelected,
        selectedTileColor:
            const Color(0xFF1E293B),
        leading: Icon(
          icon,
          color: isSelected
              ? const Color(0xFF60A5FA)
              : const Color(0xFF94A3B8),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : const Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        onTap: () async {
          if (index == 10) {
            await ApiService.logout();

            if (!mounted) return;

            Navigator.of(context)
                .pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    const LoginPage(),
              ),
              (route) => false,
            );

            return;
          }

          setState(() {
            selectedMenu = index;
          });

          if (!isDesktopWidth(context)) {
            Navigator.of(context).maybePop();
          }
        },
      ),
    );
  }

  bool isDesktopWidth(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String trend,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: darkMode
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkMode
                  ? Colors.white
                  : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trend,
            style: TextStyle(
              color: trendColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget filterDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: darkMode
            ? const Color(0xFF334155)
            : const Color(0xFFF8FAFC),
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color: darkMode
              ? const Color(0xFF475569)
              : const Color(0xFFCBD5E1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: darkMode
              ? const Color(0xFF1E293B)
              : Colors.white,
          style: TextStyle(
            color: darkMode
                ? Colors.white
                : Colors.black,
            fontSize: 13,
          ),
          items: items.map(
            (String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            },
          ).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget inventoryChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: darkMode
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Trends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkMode
                  ? Colors.white
                  : const Color(0xFF0F172A),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Chart Visualization Placeholder',
                style: TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: darkMode
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Stock by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkMode
                  ? Colors.white
                  : const Color(0xFF0F172A),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Category Distribution Placeholder',
                style: TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'done':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case 'ready':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCTS SCREEN
// ============================================================

class ProductsScreen extends StatefulWidget {
  final bool darkMode;
  final Future<void> Function() onAddProduct;

  const ProductsScreen({
    super.key,
    required this.darkMode,
    required this.onAddProduct,
  });

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends State<ProductsScreen> {
  List<dynamic> products = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await ApiService.getProducts();

      if (!mounted) return;

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  Future<void> editProduct(
    Map<String, dynamic> product,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return EditProductDialog(
          product: product,
        );
      },
    );

    if (result == true) {
      await loadProducts();
    }
  }

  Future<void> deleteProduct(
    int productId,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Product',
          ),
          content: const Text(
            'Are you sure you want to delete this product?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await ApiService.deleteProduct(productId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product deleted successfully.',
          ),
          backgroundColor:
              Color(0xFF16A34A),
        ),
      );

      await loadProducts();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = widget.darkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight:
                          FontWeight.bold,
                      color: darkMode
                          ? Colors.white
                          : const Color(
                              0xFF0F172A,
                            ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Manage your inventory products.',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: isLoading
                        ? null
                        : loadProducts,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    tooltip: 'Refresh',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed:
                        widget.onAddProduct,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Add Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF2563EB,
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          if (isLoading)
            const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(50),
                child:
                    CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            _buildError(darkMode)
          else if (products.isEmpty)
            _buildEmpty(darkMode)
          else
            _buildProductTable(darkMode),
        ],
      ),
    );
  }

  Widget _buildError(bool darkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFCA5A5),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: loadProducts,
            child: const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool darkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: darkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: darkMode
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 50,
            color: Color(0xFF64748B),
          ),
          SizedBox(height: 15),
          Text(
            'No products found.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable(bool darkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: darkMode
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('NAME')),
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('CATEGORY')),
            DataColumn(label: Text('UNIT')),
            DataColumn(label: Text('STOCK')),
            DataColumn(label: Text('REORDER LEVEL')),
            DataColumn(label: Text('ACTION')),
          ],
          rows: products.map<DataRow>(
            (product) {
              return DataRow(
                cells: [
                  DataCell(
                    Text('${product['id']}'),
                  ),
                  DataCell(
                    Text('${product['name']}'),
                  ),
                  DataCell(
                    Text('${product['sku']}'),
                  ),
                  DataCell(
                    Text('${product['category']}'),
                  ),
                  DataCell(
                    Text('${product['unit']}'),
                  ),
                  DataCell(
                    Text('${product['stock']}'),
                  ),
                  DataCell(
                    Text('${product['reorder_level']}'),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(
                            Icons.edit,
                            color:
                                Color(0xFF2563EB),
                          ),
                          onPressed: () {
                            editProduct(
                              Map<String,
                                      dynamic>.from(
                                product,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            deleteProduct(
                              product['id'] as int,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

// ============================================================
// ADD PRODUCT DIALOG
// ============================================================

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() =>
      _AddProductDialogState();
}

class _AddProductDialogState
    extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockController = TextEditingController();
  final _reorderLevelController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? stock = double.tryParse(
      _stockController.text.trim(),
    );

    final double? reorderLevel =
        double.tryParse(
      _reorderLevelController.text.trim(),
    );

    if (stock == null || reorderLevel == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.addProduct(
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        category:
            _categoryController.text.trim(),
        unit: _unitController.text.trim(),
        stock: stock,
        reorderLevel: reorderLevel,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor:
              Colors.red.shade700,
        ),
      );
    }
  }

  String? _required(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _numberRequired(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Product'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _productField(
                  _nameController,
                  'Product Name',
                  _required,
                ),
                const SizedBox(height: 15),
                _productField(
                  _skuController,
                  'SKU',
                  _required,
                ),
                const SizedBox(height: 15),
                _productField(
                  _categoryController,
                  'Category',
                  _required,
                ),
                const SizedBox(height: 15),
                _productField(
                  _unitController,
                  'Unit',
                  _required,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Initial Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      _numberRequired(
                    value,
                    'Initial Quantity',
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller:
                      _reorderLevelController,
                  decoration: const InputDecoration(
                    labelText: 'Reorder Level',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      _numberRequired(
                    value,
                    'Reorder Level',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isLoading ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF2563EB),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _productField(
    TextEditingController controller,
    String label,
    String? Function(String?, String) validator,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          validator(value, label),
    );
  }
}

// ============================================================
// EDIT PRODUCT DIALOG
// ============================================================

class EditProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductDialog({
    super.key,
    required this.product,
  });

  @override
  State<EditProductDialog> createState() =>
      _EditProductDialogState();
}

class _EditProductDialogState
    extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _categoryController;
  late final TextEditingController _unitController;
  late final TextEditingController _stockController;
  late final TextEditingController
      _reorderLevelController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: '${widget.product['name'] ?? ''}',
    );

    _skuController = TextEditingController(
      text: '${widget.product['sku'] ?? ''}',
    );

    _categoryController = TextEditingController(
      text: '${widget.product['category'] ?? ''}',
    );

    _unitController = TextEditingController(
      text: '${widget.product['unit'] ?? ''}',
    );

    _stockController = TextEditingController(
      text: '${widget.product['stock'] ?? 0}',
    );

    _reorderLevelController =
        TextEditingController(
      text:
          '${widget.product['reorder_level'] ?? 0}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? stock = double.tryParse(
      _stockController.text.trim(),
    );

    final double? reorderLevel =
        double.tryParse(
      _reorderLevelController.text.trim(),
    );

    if (stock == null || reorderLevel == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.updateProduct(
        productId: widget.product['id'] as int,
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        category:
            _categoryController.text.trim(),
        unit: _unitController.text.trim(),
        stock: stock,
        reorderLevel: reorderLevel,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _required(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _numberRequired(
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Product'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField(
                  _nameController,
                  'Product Name',
                ),
                const SizedBox(height: 15),
                _editField(
                  _skuController,
                  'SKU',
                ),
                const SizedBox(height: 15),
                _editField(
                  _categoryController,
                  'Category',
                ),
                const SizedBox(height: 15),
                _editField(
                  _unitController,
                  'Unit',
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      _numberRequired(
                    value,
                    'Stock',
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller:
                      _reorderLevelController,
                  decoration: const InputDecoration(
                    labelText: 'Reorder Level',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      _numberRequired(
                    value,
                    'Reorder Level',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isLoading ? null : _updateProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF2563EB),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _editField(
    TextEditingController controller,
    String label,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          _required(value, label),
    );
  }
}

// ============================================================
// COMMON AUTH INPUT
// ============================================================

InputDecoration _authInputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: Color(0xFF475569),
      fontSize: 13,
    ),
    prefixIcon: Icon(
      icon,
      size: 20,
      color: Color(0xFF64748B),
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFF0F172A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF1E293B),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF1E293B),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF10B981),
      ),
    ),
  );
}