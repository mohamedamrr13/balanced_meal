import 'package:balanced_meal/core/models/user_data_model.dart';
import 'package:balanced_meal/core/providers/auth_provider.dart';
import 'package:balanced_meal/core/utils/calorie_calculator.dart';
import 'package:balanced_meal/core/widgets/app_button.dart';
import 'package:balanced_meal/core/widgets/app_dropdown.dart';
import 'package:balanced_meal/core/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_state_providers.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;
  bool _isExistingUser = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final userData = context.read<AppStateProvider>().userData;
    if (userData != null) {
      setState(() {
        _isExistingUser = true;
        _selectedGender = userData.gender;
        _weightController.text = userData.weight.toString();
        _heightController.text = userData.height.toString();
        _ageController.text = userData.age.toString();
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedGender != null &&
        _weightController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        CaloriesCalculator.isValidWeight(_weightController.text) &&
        CaloriesCalculator.isValidHeight(_heightController.text) &&
        CaloriesCalculator.isValidAge(_ageController.text);
  }

  void _calculateAndProceed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);
      final age = double.parse(_ageController.text);

      final bmr = CaloriesCalculator.calculateBasalMetabolicRate(
        gender: _selectedGender!,
        weight: weight,
        height: height,
        age: age,
      );

      final bmi = CaloriesCalculator.calculateBMI(
        weight: weight,
        height: height,
      );

      final bmiCategory = CaloriesCalculator.getBMICategory(bmi);

      final userData = UserDataModel.create(
        id: context.read<AuthProvider>().user?.uid ?? '',
        gender: _selectedGender!,
        weight: weight,
        height: height,
        age: age,
      );

      await context
          .read<AuthProvider>()
          .saveUserData(userData, context.read<AppStateProvider>());

      if (mounted) {
        if (_isExistingUser) {
          _showUpdateSuccessDialog();
        } else {
          _showResultsDialog(userData);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUpdateSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Profile Updated'),
          ],
        ),
        content:
            const Text('Your health profile has been updated successfully!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showResultsDialog(UserDataModel userData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Your Health Profile'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultRow('BMI',
                  '${userData.bmi.toStringAsFixed(1)} (${userData.bmiCategory})'),
              _buildResultRow(
                  'Daily Calories (BMR)', '${userData.bmr} calories'),
              _buildResultRow('Weight', '${userData.weight} kg'),
              _buildResultRow('Height', '${userData.height} cm'),
              _buildResultRow('Age', '${userData.age.toInt()} years'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getBMIColor(userData.bmi).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI Category: ${userData.bmiCategory}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getBMIColor(userData.bmi),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getBMIDescription(userData.bmiCategory),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBMIDescription(String category) {
    switch (category) {
      case 'Underweight':
        return 'Consider consulting a healthcare provider about gaining weight safely.';
      case 'Normal weight':
        return 'Great! Maintain your current healthy lifestyle.';
      case 'Overweight':
        return 'Consider a balanced diet and regular exercise to reach a healthy weight.';
      case 'Obese':
        return 'Consider consulting a healthcare provider about weight management.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isExistingUser ? 'Update Profile' : 'Enter your details'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isExistingUser
                                  ? 'Update your information to recalculate your BMI and daily calorie needs.'
                                  : 'We\'ll calculate your BMI and daily calorie needs based on this information.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Gender Dropdown
                      AppCustomDropdown<String>(
                        label: 'Gender',
                        hintText: 'Choose your gender',
                        value: _selectedGender,
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.grey[600],
                        ),
                        items: const [
                          CustomDropdownItem(value: 'Male', label: "Male"),
                          CustomDropdownItem(value: 'Female', label: 'Female')
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select your gender';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Weight Field
                      AppTextField(
                        label: 'Weight',
                        hintText: 'Enter your weight (30-500 kg)',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        suffixText: 'Kg',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          if (!CaloriesCalculator.isValidWeight(value)) {
                            return 'Please enter a weight between 30-500 kg';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Height Field
                      AppTextField(
                        label: 'Height',
                        hintText: 'Enter your height (50-300 cm)',
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        suffixText: 'Cm',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          if (!CaloriesCalculator.isValidHeight(value)) {
                            return 'Please enter a height between 50-300 cm';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Age Field
                      AppTextField(
                        label: 'Age',
                        hintText: 'Enter your age (1-120 years)',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          if (!CaloriesCalculator.isValidAge(value)) {
                            return 'Please enter an age between 1-120 years';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              AppButton(
                text:
                    _isExistingUser ? 'Update Profile' : 'Calculate & Continue',
                onPressed: _isFormValid ? _calculateAndProceed : null,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
