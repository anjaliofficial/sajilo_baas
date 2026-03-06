import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:sajilo_baas/core/api/api_client.dart' as core_api;
import 'package:sajilo_baas/features/auth/data/repositories/auth_repository.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/auth_provider.dart';
import 'package:sajilo_baas/features/auth/presentation/state/auth_state.dart';
import '../providers/profile_provider.dart';
import '../state/profile_state.dart';
import 'edit_profile_page.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _biometricEnabled = false;
  bool _canUseBiometric = false;
  bool _hasEnrolledBiometric = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const _biometricEnabledKey = 'biometric_login_enabled';

  @override
  void initState() {
    super.initState();
    _initBiometricState();
    Future.microtask(() {
      final authState = ref.read(authViewModelProvider);
      if (authState.status == AuthStatus.authenticated) {
        ref.read(profileViewModelProvider.notifier).fetchProfile();
      } else {
        print(' User not authenticated. Skipping profile fetch.');
      }
    });
  }

  Future<void> _initBiometricState() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final available = await _localAuth.getAvailableBiometrics();

      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_biometricEnabledKey) ?? false;

      print('🔍 Biometric Device Check:');
      print('   Can check biometrics: $canCheck');
      print('   Available types: $available');
      print('   Has enrolled: ${available.isNotEmpty}');
      print('   Saved preference: $isEnabled');

      setState(() {
        _canUseBiometric = canCheck;
        _hasEnrolledBiometric = available.isNotEmpty;
        _biometricEnabled =
            isEnabled && _canUseBiometric && _hasEnrolledBiometric;
      });

      print('   Final enabled state: $_biometricEnabled');
    } catch (e) {
      print('❌ Biometric check error: $e');
      setState(() {
        _canUseBiometric = false;
        _hasEnrolledBiometric = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_canUseBiometric || !_hasEnrolledBiometric) {
      print('⚠️ Cannot enable biometric:');
      print('   Can use biometric: $_canUseBiometric');
      print('   Has enrolled biometric: $_hasEnrolledBiometric');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fingerprint not available. Enroll first in Settings.'),
        ),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // When disabling: clear credentials and preference
      if (!value) {
        await prefs.setBool(_biometricEnabledKey, false);
        setState(() => _biometricEnabled = false);
        await _clearBiometricCredentials();
        print('✅ Biometric disabled and credentials cleared');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fingerprint login disabled')),
          );
        }
        return;
      }

      // When enabling: check if we have saved credentials
      final apiClient = ref.read(core_api.apiClientProvider);
      final savedEmail = await apiClient.secureStorage.read(
        key: 'biometric_email',
      );
      final savedPassword = await apiClient.secureStorage.read(
        key: 'biometric_password',
      );

      // If credentials exist, just enable the preference
      if (savedEmail != null && savedPassword != null) {
        await prefs.setBool(_biometricEnabledKey, true);
        setState(() => _biometricEnabled = true);
        print('✅ Biometric enabled (credentials already saved)');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Fingerprint login enabled!')),
          );
        }
        return;
      }

      // If no credentials exist, ask user to enter password now
      final profile = ref.read(profileViewModelProvider).profile;
      if (profile?.email == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User email not found')),
          );
        }
        return;
      }

      // Show dialog to enter password
      if (!mounted) return;
      final password = await _showPasswordDialog(profile!.email);

      if (password == null || password.isEmpty) {
        print('❌ Password entry cancelled');
        return;
      }

      // Verify password with backend and save credentials
      try {
        final authRepo = ref.read(authRepositoryProvider);
        final loginResult = await authRepo.login(profile.email, password);

        if (loginResult.isRight()) {
          // Save credentials securely
          await apiClient.secureStorage.write(
            key: 'biometric_email',
            value: profile.email,
          );
          await apiClient.secureStorage.write(
            key: 'biometric_password',
            value: password,
          );
          await prefs.setBool(_biometricEnabledKey, true);
          setState(() => _biometricEnabled = true);

          print('✅ Biometric enabled and credentials saved');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Fingerprint login activated!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Incorrect password'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('❌ Error verifying password: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to verify password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error in _toggleBiometric: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<String?> _showPasswordDialog(String email) async {
    final TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: $email'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your password to activate fingerprint login',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _testFingerprint() async {
    if (!_canUseBiometric) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Biometric authentication not available on this device',
          ),
        ),
      );
      return;
    }

    if (!_hasEnrolledBiometric) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fingerprint enrolled. Add one in device settings first.',
          ),
        ),
      );
      return;
    }

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Test your fingerprint sensor',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;

      if (didAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Fingerprint verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fingerprint verification failed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      String message = 'Authentication error';

      if (e.code == auth_error.notAvailable) {
        message = 'Biometric authentication not available';
      } else if (e.code == auth_error.notEnrolled) {
        message = 'No fingerprint enrolled on this device';
      } else if (e.code == auth_error.lockedOut) {
        message = 'Too many attempts. Biometric authentication locked.';
      } else if (e.code == auth_error.permanentlyLockedOut) {
        message =
            'Biometric authentication permanently locked. Use device PIN.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _openBiometricSettings() async {
    try {
      await openAppSettings();

      // Refresh status when user returns
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _initBiometricState();
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open settings. Please do it manually.'),
        ),
      );
    }
  }

  Future<void> _clearBiometricCredentials() async {
    try {
      final apiClient = ref.read(core_api.apiClientProvider);
      await apiClient.secureStorage.delete(key: 'biometric_email');
      await apiClient.secureStorage.delete(key: 'biometric_password');
      print('🗑️ Biometric credentials cleared from secure storage');
    } catch (e) {
      print('❌ Error clearing biometric credentials: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // ✅ Request permissions
    if (source == ImageSource.gallery) {
      final galleryStatus = await Permission.photos.request();
      if (!galleryStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gallery permission denied")),
        );
        return;
      }
    } else if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera permission denied")),
        );
        return;
      }
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _isUploading = true);

      try {
        //  Upload file to backend
        final uploadedUrl = await ref
            .read(profileRemoteDatasourceProvider)
            .uploadProfilePicture(pickedFile.path);

        // Update profile with new picture URL
        final state = ref.read(profileViewModelProvider);
        if (state.profile != null) {
          final updated = state.profile!.copyWith(profilePicture: uploadedUrl);
          await ref
              .read(profileViewModelProvider.notifier)
              .updateProfile(updated);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile picture updated successfully"),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (state.profile != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(profile: state.profile!),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          switch (state.status) {
            case ProfileStatus.initial:
              return const Center(child: Text("No profile loaded"));
            case ProfileStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ProfileStatus.error:
              return Center(child: Text("Error: ${state.errorMessage}"));
            case ProfileStatus.loaded:
              final profile = state.profile!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Currently Logged In Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Currently Logged In',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  profile.fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  profile.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Profile Picture Section
                    GestureDetector(
                      onTap: _isUploading ? null : _showImageSourceDialog,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                (profile.profilePicture != null &&
                                    profile.profilePicture!.isNotEmpty)
                                ? NetworkImage(
                                    profile.profilePicture!.startsWith('http')
                                        ? profile.profilePicture!
                                        : ApiEndpoints.staticBaseUrl +
                                              profile.profilePicture!,
                                  )
                                : const AssetImage(
                                        'assets/images/default_avatar.jpg',
                                      )
                                      as ImageProvider,
                            onBackgroundImageError: (exception, stackTrace) {
                              debugPrint(
                                'Profile image load error: $exception',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to load profile image. Showing default.',
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                            child:
                                (profile.profilePicture == null ||
                                    profile.profilePicture!.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          if (_isUploading)
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text("Phone"),
                        subtitle: Text(profile.phoneNumber),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text("Address"),
                        subtitle: Text(profile.address),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text("Role"),
                        subtitle: Text(profile.role),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fingerprint Login Card
                    Card(
                      elevation: 2,
                      color: _canUseBiometric
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.fingerprint,
                                  color: _canUseBiometric
                                      ? Colors.blue
                                      : Colors.grey,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Biometric Login',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _canUseBiometric
                                            ? (_hasEnrolledBiometric
                                                  ? 'Fingerprint/Face ID enrolled ✓'
                                                  : 'Not enrolled yet')
                                            : 'Not available on this device',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_canUseBiometric && _hasEnrolledBiometric)
                                  Switch.adaptive(
                                    value: _biometricEnabled,
                                    onChanged: _toggleBiometric,
                                    activeColor: Colors.blue,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),

                            // Instructions
                            Text(
                              _canUseBiometric
                                  ? (_hasEnrolledBiometric
                                        ? 'Enable biometric login for quick access. You can also test your sensor below.'
                                        : 'Add your fingerprint or face to your device to enable secure biometric login.')
                                  : 'Your device does not support biometric authentication.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),

                            // Action Buttons
                            if (_canUseBiometric) ...[
                              const SizedBox(height: 16),
                              if (!_hasEnrolledBiometric)
                                // Add Fingerprint Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _openBiometricSettings,
                                    icon: const Icon(Icons.settings, size: 20),
                                    label: const Text(
                                      'Add Fingerprint/Face ID',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                // Test Fingerprint Button
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _testFingerprint,
                                        icon: const Icon(
                                          Icons.fingerprint,
                                          size: 20,
                                        ),
                                        label: const Text('Test Sensor'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.blue,
                                          side: const BorderSide(
                                            color: Colors.blue,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _openBiometricSettings,
                                        icon: const Icon(
                                          Icons.settings,
                                          size: 20,
                                        ),
                                        label: const Text('Settings'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade700,
                                          side: BorderSide(
                                            color: Colors.grey.shade400,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            // Don't clear biometric credentials on logout
                            // They should persist for fingerprint login

                            await ref
                                .read(authViewModelProvider.notifier)
                                .logout();

                            print('🚪 Logout complete, navigating to login...');
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
