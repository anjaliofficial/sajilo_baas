import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileViewModelProvider.notifier).fetchProfile();
    });
  }

  Future<void> _changeProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isUploading = true);

      try {
        // ✅ Upload file to backend first
        final uploadedUrl = await ref
            .read(profileRemoteDatasourceProvider)
            .uploadProfilePicture(pickedFile.path);

        // ✅ Update profile with new picture URL
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
                    GestureDetector(
                      onTap: _isUploading ? null : _changeProfilePicture,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                profile.profilePicture != null &&
                                    profile.profilePicture!.isNotEmpty
                                ? NetworkImage(profile.profilePicture!)
                                : const AssetImage(
                                        'assets/images/default_avatar.png',
                                      )
                                      as ImageProvider,
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
                  ],
                ),
              );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
