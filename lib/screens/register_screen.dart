import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/big_button.dart';
import '../services/auth_service.dart';
import 'patient_dashboard.dart';
import 'caregiver_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _selectedRole;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_selectedRole == null) {
      setState(() => _error = 'Please select a role');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your email');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole!,
      );

      if (response['success'] == true) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => _selectedRole == 'patient'
                  ? const PatientDashboard()
                  : const CaregiverDashboard(),
            ),
          );
        }
      } else {
        setState(() => _error = response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      setState(() => _error = 'Connection error. Is backend running?');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.person_add, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Create Account', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text(
                'Join PillCare today',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Role Selection
              Text('I am a:', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      icon: Icons.person,
                      label: 'Patient',
                      isSelected: _selectedRole == 'patient',
                      onTap: () => setState(() => _selectedRole = 'patient'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RoleCard(
                      icon: Icons.favorite,
                      label: 'Caregiver',
                      isSelected: _selectedRole == 'caregiver',
                      onTap: () => setState(() => _selectedRole = 'caregiver'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              _InputField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Email Field
              _InputField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              _InputField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              _InputField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),

              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                ),

              _isLoading
                  ? const CircularProgressIndicator()
                  : BigButton.primary(
                      text: 'Create Account',
                      icon: Icons.person_add,
                      onPressed: _register,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textLight,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 28),
          labelText: label,
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
