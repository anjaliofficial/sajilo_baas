// profile/presentation/pages/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/profile/presentation/providers/profile_provider.dart';
import '../view_model/profile_view_model.dart';
import '../state/profile_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${profile.fullName}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Email: ${profile.email}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Phone: ${profile.phoneNumber}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Address: ${profile.address}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Role: ${profile.role}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
