import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = true;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Defined a specific color to match the design aesthetics in the previous file
    final Color primaryBlue = const Color.fromARGB(255, 154, 189, 224);

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Welcome Back! 👋',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hello again, you\'ve been missed!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                // Logo placeholder
                CircleAvatar(
                  backgroundColor: primaryBlue,
                  radius: 18,
                  child: const Text(
                    'SB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- Email Field ---
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: 'sophat.leat@gmail.com',
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Password Field ---
            const Text(
              'Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Enter Your Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- Remember Me / Forgot Password ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Remember Me', style: TextStyle(fontSize: 13)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Placeholder for forgot password logic
                  },
                  child: const Text(
                    'Forgot Password',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Login Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Successful login navigates to the Dashboard using named route
                  Navigator.of(context).pushReplacementNamed('/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Login", // Corrected text
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Or With Divider ---
            const Center(
              child: Text(
                'Or With',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),

            // --- Social Login Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildSocialButton('Gmail', Icons.mail_outline),
                const SizedBox(width: 20),
                _buildSocialButton('Facebook', Icons.facebook),
              ],
            ),
            const SizedBox(height: 40),

            // --- Footer: Don't have an account? ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Don't have an account?",
                  style: TextStyle(fontSize: 13),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to the Sign Up page using named route
                    Navigator.of(context).pushNamed('/signup');
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          // Placeholder for social login action
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Colors.grey),
        ),
        icon: Icon(icon, color: Colors.black),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
