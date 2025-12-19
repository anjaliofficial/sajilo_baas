import 'package:flutter/material.dart';

enum UserRole { customer, host }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  UserRole _selectedRole = UserRole.customer;

  final Color primaryBlue = const Color.fromARGB(255, 154, 189, 224);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset('assets/images/logo.png'),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ---------------- EMAIL ----------------
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- PASSWORD ----------------
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
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- LOGIN BUTTON ----------------
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedRole == UserRole.customer) {
                    Navigator.pushReplacementNamed(context, '/customer');
                  } else {
                    Navigator.pushReplacementNamed(context, '/host');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- OR CONTINUE WITH ----------------
            const Center(
              child: Text(
                "Or Continue With",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------- GMAIL LOGIN BUTTON ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Add Gmail login logic
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    icon: const Icon(Icons.mail_outline, color: Colors.red),
                    label: const Text(
                      "Login with Gmail",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ---------------- ROLE SELECTION ----------------
            const Text(
              "Login As",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _roleButton(
                  title: "Customer",
                  isSelected: _selectedRole == UserRole.customer,
                  onTap: () {
                    setState(() {
                      _selectedRole = UserRole.customer;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _roleButton(
                  title: "Host",
                  isSelected: _selectedRole == UserRole.host,
                  onTap: () {
                    setState(() {
                      _selectedRole = UserRole.host;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ROLE BUTTON ----------------
  Widget _roleButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
