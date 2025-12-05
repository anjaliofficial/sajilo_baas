import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  // Helper method for standard text fields
  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Helper method for password fields
  Widget _buildPasswordField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: const Icon(Icons.remove_red_eye),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Helper method for social media buttons
  Widget _buildSocialButton(String label, IconData icon) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
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

  @override
  Widget build(BuildContext context) {
    // The specific primary blue color provided by the user
    final Color primaryBlue = const Color.fromARGB(255, 154, 189, 224);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up Page'), toolbarHeight: 0),
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
                      'Create an account',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Connect with your friends today!',
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

            // --- Form Fields ---
            _buildTextField(label: 'Full Name', hint: 'Enter your name'),
            _buildTextField(label: 'Address', hint: 'Enter your address'),
            _buildTextField(
              label: 'Email Address',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),

            // Phone Number with country code prefix
            const Text(
              'Phone Number',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter your phonenumber',
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  width: 70,
                  child: const Text(
                    '+977',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
            const SizedBox(height: 20),

            _buildPasswordField(
              label: 'Password',
              hint: 'Please Enter Your Password',
            ),
            _buildPasswordField(
              label: 'Conform Password',
              hint: 'Please Renter Your Password',
            ),

            const SizedBox(height: 30),

            // --- Sign Up Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Successful sign up navigates to the Dashboard using named route
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Sign Up",
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

            // --- Footer: Already have an account? ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Already have an account?",
                  style: TextStyle(fontSize: 13),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate back to Login page using Navigator.pop (assuming it was pushed from login)
                    // If you want to explicitly ensure it goes to the /login route, use:
                    // Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Login',
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
}
