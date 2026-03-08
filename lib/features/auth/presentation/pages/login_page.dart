// LoginPage (FULL)

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/providers/shared_pref_provider.dart';
import 'package:sajilo_baas/features/auth/presentation/pages/register_page.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/auth_provider.dart';
import 'package:sajilo_baas/features/dashboard/presentation/widgets/customer_main_navigation.dart';
import '../../presentation/state/auth_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const String _biometricEnabledKey = 'biometric_login_enabled';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _canUseBiometric = false;
  bool _hasEnrolledBiometric = false;
  bool _biometricEnabled = false;
  bool _isBiometricLoading = false;
  bool _credentialLoginInProgress = false;

  final Color primaryBlue = const Color(0xFF1A82AD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).reset();
      _initBiometricState();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _credentialLoginInProgress = true;
      ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  Future<void> _initBiometricState() async {
    try {
      final sharedPrefs = ref.read(sharedPreferencesProvider);
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final available = await _localAuth.getAvailableBiometrics();

      final enabled = sharedPrefs.getBool(_biometricEnabledKey) ?? false;

      print('🔍 Login Page - Biometric Check:');
      print('   Can check biometrics: $canCheck');
      print('   Device supported: $isSupported');
      print('   Available types: $available');
      print('   Has enrolled: ${available.isNotEmpty}');
      print('   Saved preference: $enabled');

      if (!mounted) return;
      setState(() {
        _canUseBiometric = canCheck || isSupported;
        _hasEnrolledBiometric = available.isNotEmpty;
        if (!_hasEnrolledBiometric) {
          _biometricEnabled = false;
        } else {
          _biometricEnabled = enabled;
        }
      });

      print('   Final enabled state: $_biometricEnabled');
      print(
        '   Fingerprint button will ${_biometricEnabled ? "SHOW" : "HIDE"}',
      );
    } on PlatformException {
      print('❌ Login Page - Biometric check failed');
      if (!mounted) return;
      setState(() {
        _canUseBiometric = false;
        _hasEnrolledBiometric = false;
        _biometricEnabled = false;
      });
    }
  }

  Future<void> _saveBiometricPreference(bool enabled) async {
    // Only save credentials when biometric is already enabled
    if (!enabled) return;

    final sharedPrefs = ref.read(sharedPreferencesProvider);
    final isEnabled = sharedPrefs.getBool(_biometricEnabledKey) ?? false;

    print('🔐 Saving biometric credentials... Enabled: $isEnabled');

    // Only store credentials if user has enabled biometric in profile
    if (isEnabled) {
      await _saveCredentialsSecurely(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      print('✅ Biometric credentials saved successfully');
    } else {
      print('⚠️ Biometric not enabled in profile, credentials not saved');
    }
  }

  Future<void> _saveCredentialsSecurely(String email, String password) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.secureStorage.write(key: 'biometric_email', value: email);
    await apiClient.secureStorage.write(
      key: 'biometric_password',
      value: password,
    );
  }

  Future<void> _onBiometricLogin() async {
    if (!_canUseBiometric) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric sensor is not available.')),
      );
      return;
    }

    if (!_hasEnrolledBiometric) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fingerprint/face is enrolled. Add it in phone settings first.',
          ),
        ),
      );
      return;
    }

    if (!_biometricEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable fingerprint login first, then sign in once.'),
        ),
      );
      return;
    }

    setState(() {
      _isBiometricLoading = true;
    });

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to log in to Sajilo Baas',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) return;

      // Retrieve stored credentials and perform real login
      final apiClient = ref.read(apiClientProvider);
      final email = await apiClient.secureStorage.read(key: 'biometric_email');
      final password = await apiClient.secureStorage.read(
        key: 'biometric_password',
      );

      if (email == null || password == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No saved credentials. Please login with email first.',
            ),
          ),
        );
        return;
      }

      // Perform actual login to get fresh user data
      await ref
          .read(authViewModelProvider.notifier)
          .login(email: email, password: password);

      final currentState = ref.read(authViewModelProvider);
      if (currentState.status != AuthStatus.authenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again with email.'),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Biometric authentication failed')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBiometricLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        _credentialLoginInProgress = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? "Login failed"),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (next.status == AuthStatus.authenticated) {
        if (_credentialLoginInProgress) {
          _credentialLoginInProgress = false;
          // Save credentials if biometric is enabled
          _saveBiometricPreference(true);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerMainNavigation()),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hi, Welcome Back! 👋",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Hello again, you've been missed!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/images/logo.png',
                      width: 45,
                      height: 45,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.home_work, color: primaryBlue, size: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Text(
                  "Email",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                    key: const Key('emailField'),
                    decoration: _inputDecoration("Please Enter Your Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegExp = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegExp.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  "Password",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                    key: const Key('passwordField'),
                    decoration: _inputDecoration("Please Enter Your Password")
                        .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.black54,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: primaryBlue,
                            onChanged: (val) =>
                                setState(() => _rememberMe = val!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text("Remember Me"),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                    child: ElevatedButton(
                      key: const Key('loginButton'),
                      onPressed: authState.status == AuthStatus.loading
                          ? null
                          : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authState.status == AuthStatus.loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                ),

                const SizedBox(height: 20),
                // Show fingerprint button only if already enabled in profile
                if (_biometricEnabled) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed:
                          authState.status == AuthStatus.loading ||
                              _isBiometricLoading
                          ? null
                          : _onBiometricLogin,
                      icon: _isBiometricLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.fingerprint),
                      label: Text(
                        _isBiometricLoading
                            ? 'Authenticating...'
                            : 'Login with Fingerprint',
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or With",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.mail, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          "Gmail",
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account ? "),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    );
  }
}
