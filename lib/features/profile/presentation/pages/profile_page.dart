import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
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

      setState(() {
        _canUseBiometric = canCheck;
        _hasEnrolledBiometric = available.isNotEmpty;
        _biometricEnabled =
            isEnabled && _canUseBiometric && _hasEnrolledBiometric;
      });
    } catch (e) {
      print(' Biometric check error: $e');
      setState(() {
        _canUseBiometric = false;
        _hasEnrolledBiometric = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_canUseBiometric || !_hasEnrolledBiometric) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fingerprint not available. Enroll first in Settings.'),
        ),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, value);
      setState(() => _biometricEnabled = value);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Fingerprint login enabled' : 'Fingerprint login disabled',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                      color: _canUseBiometric
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
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
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Fingerprint Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _canUseBiometric
                                            ? (_hasEnrolledBiometric
                                                  ? 'Fingerprint enrolled ✓'
                                                  : 'No fingerprint enrolled')
                                            : 'Not available on this device',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _biometricEnabled,
                                  onChanged:
                                      _canUseBiometric && _hasEnrolledBiometric
                                      ? _toggleBiometric
                                      : null,
                                  activeColor: Colors.blue,
                                ),
                              ],
                            ),
                            if (_canUseBiometric && !_hasEnrolledBiometric)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Add a fingerprint in device Settings to enable login.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                            await ref
                                .read(authViewModelProvider.notifier)
                                .logout();
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
