import 'package:balanced_meal/core/providers/app_state_providers.dart';
import 'package:balanced_meal/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:balanced_meal/core/models/user_data_model.dart';
import 'package:balanced_meal/core/widgets/app_button.dart';
import 'package:balanced_meal/core/widgets/app_textfield.dart';
import 'package:balanced_meal/core/widgets/app_dropdown.dart';

/// User profile page for viewing and editing health information.
///
/// This page displays the user's health metrics (BMI, BMR) and allows
/// them to update their profile information.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedGender;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.user?.userData;

    if (userData != null) {
      _weightController.text = userData.weight.toString();
      _heightController.text = userData.height.toString();
      _ageController.text = userData.age.toString();
      _selectedGender = userData.gender;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final userData = UserDataModel.create(
        id: userId,
        gender: _selectedGender!,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        age: double.parse(_ageController.text),
      );

      await authProvider.saveUserData(
          userData, Provider.of<AppStateProvider>(context, listen: false));

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          final userData = user?.userData;

          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  _UserInfoCard(
                    email: user?.email ?? 'No email',
                    displayName: user?.displayName,
                  ),
                  const SizedBox(height: 24),

                  // Health Metrics (if exists)
                  if (userData != null && !_isEditing) ...[
                    Text(
                      'Health Metrics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _HealthMetricsGrid(userData: userData),
                    const SizedBox(height: 24),
                  ],

                  // Edit Form
                  if (_isEditing) ...[
                    Text(
                      'Edit Profile Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _EditForm(
                      weightController: _weightController,
                      heightController: _heightController,
                      ageController: _ageController,
                      selectedGender: _selectedGender,
                      onGenderChanged: (value) =>
                          setState(() => _selectedGender = value),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Cancel',
                            onPressed: () {
                              _loadUserData();
                              setState(() => _isEditing = false);
                            },
                            isLoading: false,
                            backgroundColor: theme.colorScheme.surfaceContainer,
                            textColor: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppButton(
                            text: 'Save Changes',
                            onPressed: _saveProfile,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // BMI Information
                  if (userData != null && !_isEditing) ...[
                    const SizedBox(height: 24),
                    _BMIInfoCard(userData: userData),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  final String email;
  final String? displayName;

  const _UserInfoCard({
    required this.email,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (displayName != null)
                  Text(
                    displayName!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMetricsGrid extends StatelessWidget {
  final UserDataModel userData;

  const _HealthMetricsGrid({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Weight',
                value: '${userData.weight.toStringAsFixed(1)} kg',
                icon: Icons.monitor_weight,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                label: 'Height',
                value: '${userData.height.toStringAsFixed(0)} cm',
                icon: Icons.height,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Age',
                value: '${userData.age.toStringAsFixed(0)} years',
                icon: Icons.cake,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                label: 'Gender',
                value: userData.gender,
                icon: Icons.person_outline,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController ageController;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;

  const _EditForm({
    required this.weightController,
    required this.heightController,
    required this.ageController,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCustomDropdown<String>(
          label: 'Gender',
          value: selectedGender,
          items: const [
            CustomDropdownItem(value: 'Male', label: 'Male'),
            CustomDropdownItem(value: 'Female', label: 'Female'),
          ],
          onChanged: onGenderChanged,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: weightController,
          label: 'Weight (kg)',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your weight';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return 'Please enter a valid weight';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: heightController,
          label: 'Height (cm)',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your height';
            }
            final height = double.tryParse(value);
            if (height == null || height <= 0) {
              return 'Please enter a valid height';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: ageController,
          label: 'Age (years)',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            final age = double.tryParse(value);
            if (age == null || age <= 0 || age > 120) {
              return 'Please enter a valid age';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _BMIInfoCard extends StatelessWidget {
  final UserDataModel userData;

  const _BMIInfoCard({required this.userData});

  Color _getBMIColor() {
    if (userData.bmi < 18.5) return Colors.blue;
    if (userData.bmi < 25) return Colors.green;
    if (userData.bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bmiColor = _getBMIColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Body Mass Index (BMI)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData.bmi.toStringAsFixed(1),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: bmiColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bmiColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userData.bmiCategory,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: bmiColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bmiColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: bmiColor, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      '${userData.bmr} kcal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: bmiColor,
                      ),
                    ),
                    Text(
                      'Daily BMR',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your daily calorie requirement is ${userData.bmr} kcal based on your BMR (Basal Metabolic Rate).',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
