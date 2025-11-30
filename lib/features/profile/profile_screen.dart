import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import 'dart:math' as math;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  int _selectedAvatarIndex = 0;

  final List<String> _avatarEmojis = [
    '😊', '🎯', '🚀', '💪', '🌟', '🎨', '📚', '🏆', '⚡', '🔥',
    '🌈', '🎭', '🎪', '🎸', '🎮', '⚽', '🏀', '🎾', '🏐', '🎱'
  ];

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _nameController = TextEditingController(
      text: authProvider.currentUser?.displayName ?? 'User',
    );
    _emailController = TextEditingController(
      text: authProvider.currentUser?.email ?? 
            authProvider.currentUser?.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/welcome');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Avatar Selection
            _buildAvatarSection(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // User Info Form
            _buildUserInfoForm(user),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Account Info
            _buildAccountInfo(user),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Settings Options
            _buildSettingsOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          // Current Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.gradientBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _avatarEmojis[_selectedAvatarIndex],
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'Choose Your Avatar',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Avatar Grid
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _avatarEmojis.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedAvatarIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatarIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _avatarEmojis[index],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoForm(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Enter your name' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: user?.email != null ? 'Email' : 'Phone Number',
                prefixIcon: Icon(user?.email != null ? Icons.email : Icons.phone),
              ),
              enabled: false, // Can't change email/phone
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Save Changes',
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // TODO: Update user profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _buildInfoRow('User ID', user?.uid ?? 'N/A'),
          const Divider(height: 32),
          _buildInfoRow('Account Created', 'Recently'),
          const Divider(height: 32),
          _buildInfoRow('Email Verified', user?.emailVerified == true ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOptions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () => context.push('/notifications'),
          ),
          _buildSettingTile(
            icon: Icons.lock,
            title: 'Privacy & Security',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.info,
            title: 'About',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}