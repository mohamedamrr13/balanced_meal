# 🥗 Balanced Meal - Smart Nutrition Planning App

A comprehensive Flutter application for creating balanced meals based on personalized health metrics. Built with clean architecture, modern UI/UX patterns, and robust testing.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)

## ✨ Key Features

### 🎯 Core Functionality
- **Smart Meal Builder** - Create meals from categorized food items (vegetables, meat, carbs)
- **Real-Time Calorie Tracking** - Live updates as you build your meal
- **Personalized Nutrition** - BMI/BMR-based meal recommendations
- **Health Profile Management** - Track weight, height, age, and health metrics
- **Meal History & Analytics** - Visual insights with charts and statistics
- **Favorites System** - Quick access to your favorite meals

### 🔐 Authentication
- Email/Password authentication with validation
- Google Sign-In integration
- Anonymous sign-in support
- Session persistence across app restarts

### 💪 Enhanced Features
- **Detailed Nutrition Breakdown** - Complete macronutrient tracking (protein, carbs, fat)
- **Visual Charts** - Calorie trends and category distribution with FL Chart
- **User Profile Page** - Edit health information with real-time BMI/BMR calculations
- **Loading Skeletons** - Professional loading states with shimmer effects
- **Empty States** - Helpful, user-friendly empty state messages with CTAs
- **Error Handling** - Comprehensive error boundaries with retry mechanisms

### 🎨 UI/UX Excellence
- Dark/Light theme support with system preference detection
- Smooth animations and transitions
- Material Design 3 implementation
- Custom fonts (Poppins)
- Responsive layouts for all screen sizes
- Accessibility features

## 🏗️ Architecture

Clean Architecture with feature-based organization:

```
lib/
├── core/                      # Shared resources
│   ├── models/               # Data models with full documentation
│   ├── services/             # Backend services (Firestore)
│   ├── providers/            # State management (Provider + BLoC)
│   ├── widgets/              # Reusable UI components
│   ├── theme/                # App theming (light/dark)
│   ├── routes/               # Navigation (GoRouter)
│   └── utils/                # Utilities and helpers
│
└── features/                  # Feature modules
    ├── auth/                 # Authentication (BLoC-based)
    ├── profile/              # User profile management
    ├── meal_history/         # Analytics & charts
    ├── onboarding/           # Welcome flow
    ├── user_details/         # Health profile setup
    ├── home/                 # Dashboard
    └── order/                # Meal creation & management
```

## 🚀 Tech Stack

- **Flutter 3.0+** & **Dart 3.0+**
- **Firebase** (Auth, Firestore)
- **Provider** + **Flutter BLoC** (State management)
- **GoRouter** (Navigation)
- **FL Chart** (Data visualization)
- **Shimmer** (Loading effects)
- **Lottie** (Animations)
- **Google Fonts** (Typography)

## 📦 Installation

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Firebase project configured

### Setup

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd balanced_meal
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Email/Password and Google Sign-In authentication
   - Create Firestore database

4. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Testing

Comprehensive test coverage included:

```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/models/
flutter test test/widgets/
flutter test test/utils/
```

### Test Coverage
- ✅ Unit tests for models (FoodItemModel, SavedMealModel, UserDataModel)
- ✅ Unit tests for utilities (BMI, BMR calculations)
- ✅ Widget tests for custom components (NutritionBreakdown, EmptyState)
- ✅ Edge cases and validation testing

## 📊 Key Components

### Data Models
- **FoodItemModel** - Complete nutritional info with macros
- **SavedMealModel** - Meals with calculated totals and favorites
- **UserDataModel** - Health metrics with BMI/BMR calculations

### Custom Widgets
- **NutritionBreakdown** - Visual macro display with progress bars
- **ShimmerLoading** - Professional skeleton loading states
- **EmptyState** - User-friendly empty states with actions
- **AppButton** - Animated button with loading states
- **AppTextField** - Validated inputs with floating labels
- **FoodItemCard** - Food items with hero animations

### Health Calculations

**BMI (Body Mass Index)**
```
BMI = weight(kg) / (height(m))²
```

**BMR (Basal Metabolic Rate)** - Mifflin-St Jeor Equation
```
Male:   BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5
Female: BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161
```

## 🎯 Code Quality

### Best Practices
- ✅ Comprehensive dartdoc documentation
- ✅ Clean separation of concerns
- ✅ SOLID principles
- ✅ Type safety with generics
- ✅ Null safety throughout
- ✅ Error handling & validation
- ✅ DRY principle
- ✅ Consistent naming conventions

## 🗃️ Firestore Structure

```
users/{userId}/health_data/current/
  ├── gender, weight, height, age
  ├── bmi, bmi_category, bmr
  └── created_at

saved_meals/{mealId}/
  ├── meal_name, user_id
  ├── total_calories, total_price
  ├── is_favorite, saved_at
  └── items[] (with protein, carbs, fat)

vegetables/{itemId}/, meat/{itemId}/, carbs/{itemId}/
  └── food data with macros
```

## 🎓 Interview Showcase

This project demonstrates:

### Technical Excellence
- ✅ Flutter & Dart advanced concepts
- ✅ Clean Architecture implementation
- ✅ Hybrid state management (Provider + BLoC)
- ✅ Firebase integration (Auth + Firestore)
- ✅ Comprehensive testing strategy
- ✅ Material Design 3 & theming
- ✅ Performance optimization

### Software Engineering
- ✅ SOLID principles & design patterns
- ✅ Professional code documentation
- ✅ Error handling & validation
- ✅ Git workflow & version control
- ✅ Production-ready code quality

### Product Thinking
- ✅ User-centric design
- ✅ Accessibility considerations
- ✅ UX optimizations
- ✅ Feature completeness

---

**Made with Flutter** 💙
