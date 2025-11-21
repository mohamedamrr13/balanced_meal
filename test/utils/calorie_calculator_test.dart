import 'package:flutter_test/flutter_test.dart';
import 'package:balanced_meal/core/models/user_data_model.dart';

/// Unit tests for health calculation utilities
///
/// Tests cover:
/// - BMI calculation
/// - BMI category classification
/// - BMR calculation (Mifflin-St Jeor equation)
/// - Edge cases and validation
void main() {
  group('UserDataModel Health Calculations', () {
    group('BMI Calculation', () {
      test('should calculate BMI correctly for normal weight', () {
        // Arrange
        const weight = 70.0; // kg
        const height = 175.0; // cm

        // Act
        final bmi = UserDataModel.calculateBMI(weight, height);

        // Assert
        // BMI = weight / (height_in_meters)^2
        // BMI = 70 / (1.75)^2 = 70 / 3.0625 = 22.857
        expect(bmi, closeTo(22.86, 0.01));
      });

      test('should calculate BMI correctly for underweight', () {
        // Arrange
        const weight = 50.0; // kg
        const height = 175.0; // cm

        // Act
        final bmi = UserDataModel.calculateBMI(weight, height);

        // Assert
        // BMI = 50 / (1.75)^2 = 16.33
        expect(bmi, closeTo(16.33, 0.01));
      });

      test('should calculate BMI correctly for overweight', () {
        // Arrange
        const weight = 90.0; // kg
        const height = 175.0; // cm

        // Act
        final bmi = UserDataModel.calculateBMI(weight, height);

        // Assert
        // BMI = 90 / (1.75)^2 = 29.39
        expect(bmi, closeTo(29.39, 0.01));
      });

      test('should return 0 for zero height', () {
        // Arrange
        const weight = 70.0;
        const height = 0.0;

        // Act
        final bmi = UserDataModel.calculateBMI(weight, height);

        // Assert
        expect(bmi, 0.0);
      });

      test('should return 0 for negative height', () {
        // Arrange
        const weight = 70.0;
        const height = -175.0;

        // Act
        final bmi = UserDataModel.calculateBMI(weight, height);

        // Assert
        expect(bmi, 0.0);
      });
    });

    group('BMI Category Classification', () {
      test('should classify BMI < 18.5 as Underweight', () {
        // Arrange
        const bmi = 17.5;

        // Act
        final category = UserDataModel.getBMICategory(bmi);

        // Assert
        expect(category, 'Underweight');
      });

      test('should classify BMI 18.5-24.9 as Normal weight', () {
        // Arrange
        const bmi1 = 18.5;
        const bmi2 = 22.0;
        const bmi3 = 24.9;

        // Act & Assert
        expect(UserDataModel.getBMICategory(bmi1), 'Normal weight');
        expect(UserDataModel.getBMICategory(bmi2), 'Normal weight');
        expect(UserDataModel.getBMICategory(bmi3), 'Normal weight');
      });

      test('should classify BMI 25-29.9 as Overweight', () {
        // Arrange
        const bmi1 = 25.0;
        const bmi2 = 27.5;
        const bmi3 = 29.9;

        // Act & Assert
        expect(UserDataModel.getBMICategory(bmi1), 'Overweight');
        expect(UserDataModel.getBMICategory(bmi2), 'Overweight');
        expect(UserDataModel.getBMICategory(bmi3), 'Overweight');
      });

      test('should classify BMI >= 30 as Obese', () {
        // Arrange
        const bmi1 = 30.0;
        const bmi2 = 35.5;
        const bmi3 = 40.0;

        // Act & Assert
        expect(UserDataModel.getBMICategory(bmi1), 'Obese');
        expect(UserDataModel.getBMICategory(bmi2), 'Obese');
        expect(UserDataModel.getBMICategory(bmi3), 'Obese');
      });

      test('should handle edge case at exact category boundaries', () {
        // Assert
        expect(UserDataModel.getBMICategory(18.4), 'Underweight');
        expect(UserDataModel.getBMICategory(18.5), 'Normal weight');
        expect(UserDataModel.getBMICategory(24.9), 'Normal weight');
        expect(UserDataModel.getBMICategory(25.0), 'Overweight');
        expect(UserDataModel.getBMICategory(29.9), 'Overweight');
        expect(UserDataModel.getBMICategory(30.0), 'Obese');
      });
    });

    group('BMR Calculation (Mifflin-St Jeor)', () {
      test('should calculate BMR correctly for male', () {
        // Arrange
        const weight = 80.0; // kg
        const height = 180.0; // cm
        const age = 30.0; // years
        const gender = 'Male';

        // Act
        final bmr = UserDataModel.calculateBMR(weight, height, age, gender);

        // Assert
        // BMR (male) = (10 * weight) + (6.25 * height) - (5 * age) + 5
        // BMR = (10 * 80) + (6.25 * 180) - (5 * 30) + 5
        // BMR = 800 + 1125 - 150 + 5 = 1780
        expect(bmr, 1780);
      });

      test('should calculate BMR correctly for female', () {
        // Arrange
        const weight = 60.0; // kg
        const height = 165.0; // cm
        const age = 25.0; // years
        const gender = 'Female';

        // Act
        final bmr = UserDataModel.calculateBMR(weight, height, age, gender);

        // Assert
        // BMR (female) = (10 * weight) + (6.25 * height) - (5 * age) - 161
        // BMR = (10 * 60) + (6.25 * 165) - (5 * 25) - 161
        // BMR = 600 + 1031.25 - 125 - 161 = 1345.25 ≈ 1345
        expect(bmr, 1345);
      });

      test('should handle male gender case-insensitively', () {
        // Arrange
        const weight = 80.0;
        const height = 180.0;
        const age = 30.0;

        // Act
        final bmrMale = UserDataModel.calculateBMR(weight, height, age, 'male');
        final bmrMALE = UserDataModel.calculateBMR(weight, height, age, 'MALE');
        final bmrMale2 = UserDataModel.calculateBMR(weight, height, age, 'Male');

        // Assert
        expect(bmrMale, bmrMALE);
        expect(bmrMale, bmrMale2);
      });

      test('should treat non-male gender as female', () {
        // Arrange
        const weight = 60.0;
        const height = 165.0;
        const age = 25.0;

        // Act
        final bmrFemale = UserDataModel.calculateBMR(weight, height, age, 'Female');
        final bmrOther = UserDataModel.calculateBMR(weight, height, age, 'Other');
        final bmrUnknown = UserDataModel.calculateBMR(weight, height, age, 'Unknown');

        // Assert
        expect(bmrOther, bmrFemale);
        expect(bmrUnknown, bmrFemale);
      });

      test('should calculate different BMR for different ages', () {
        // Arrange
        const weight = 70.0;
        const height = 170.0;
        const gender = 'Male';

        // Act
        final bmr20 = UserDataModel.calculateBMR(weight, height, 20, gender);
        final bmr40 = UserDataModel.calculateBMR(weight, height, 40, gender);
        final bmr60 = UserDataModel.calculateBMR(weight, height, 60, gender);

        // Assert
        expect(bmr20, greaterThan(bmr40));
        expect(bmr40, greaterThan(bmr60));
      });

      test('should calculate different BMR for different weights', () {
        // Arrange
        const height = 170.0;
        const age = 30.0;
        const gender = 'Male';

        // Act
        final bmr60 = UserDataModel.calculateBMR(60, height, age, gender);
        final bmr80 = UserDataModel.calculateBMR(80, height, age, gender);
        final bmr100 = UserDataModel.calculateBMR(100, height, age, gender);

        // Assert
        expect(bmr80, greaterThan(bmr60));
        expect(bmr100, greaterThan(bmr80));
      });

      test('should calculate different BMR for different heights', () {
        // Arrange
        const weight = 70.0;
        const age = 30.0;
        const gender = 'Male';

        // Act
        final bmr150 = UserDataModel.calculateBMR(weight, 150, age, gender);
        final bmr170 = UserDataModel.calculateBMR(weight, 170, age, gender);
        final bmr190 = UserDataModel.calculateBMR(weight, 190, age, gender);

        // Assert
        expect(bmr170, greaterThan(bmr150));
        expect(bmr190, greaterThan(bmr170));
      });
    });

    group('UserDataModel.create Factory', () {
      test('should create UserDataModel with calculated values', () {
        // Arrange & Act
        final userData = UserDataModel.create(
          id: 'user_123',
          gender: 'Male',
          weight: 70.0,
          height: 175.0,
          age: 30.0,
        );

        // Assert
        expect(userData.id, 'user_123');
        expect(userData.gender, 'Male');
        expect(userData.weight, 70.0);
        expect(userData.height, 175.0);
        expect(userData.age, 30.0);
        expect(userData.bmi, closeTo(22.86, 0.01));
        expect(userData.bmiCategory, 'Normal weight');
        expect(userData.bmr, 1642); // Calculated for 70kg, 175cm, 30y, Male
      });

      test('should create UserDataModel with correct BMI category', () {
        // Arrange & Act
        final underweight = UserDataModel.create(
          id: 'user_1',
          gender: 'Female',
          weight: 45.0,
          height: 165.0,
          age: 25.0,
        );

        final normal = UserDataModel.create(
          id: 'user_2',
          gender: 'Female',
          weight: 60.0,
          height: 165.0,
          age: 25.0,
        );

        final overweight = UserDataModel.create(
          id: 'user_3',
          gender: 'Female',
          weight: 75.0,
          height: 165.0,
          age: 25.0,
        );

        final obese = UserDataModel.create(
          id: 'user_4',
          gender: 'Female',
          weight: 90.0,
          height: 165.0,
          age: 25.0,
        );

        // Assert
        expect(underweight.bmiCategory, 'Underweight');
        expect(normal.bmiCategory, 'Normal weight');
        expect(overweight.bmiCategory, 'Overweight');
        expect(obese.bmiCategory, 'Obese');
      });

      test('should set createdAt to current time', () {
        // Arrange
        final before = DateTime.now();

        // Act
        final userData = UserDataModel.create(
          id: 'user_123',
          gender: 'Male',
          weight: 70.0,
          height: 175.0,
          age: 30.0,
        );

        final after = DateTime.now();

        // Assert
        expect(userData.createdAt.isAfter(before) || userData.createdAt.isAtSameMomentAs(before), true);
        expect(userData.createdAt.isBefore(after) || userData.createdAt.isAtSameMomentAs(after), true);
      });
    });
  });
}
