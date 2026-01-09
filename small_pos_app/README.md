

# Smart POS & Full Inventory Management App

A comprehensive Point of Sale (POS) and Inventory Management application built with Flutter and Supabase. This application provides a complete solution for managing sales, inventory, customers, and business reports.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Development](#development)

## ✨ Features

### Core Features

- **Point of Sale (POS)**
  - Quick checkout interface
  - Real-time sales processing
  - Receipt generation

- **Inventory Management**
  - Product catalog management
  - Stock level tracking
  - Low stock alerts
  - Product categorization

- **Customer Management**
  - Customer database
  - Customer history tracking
  - Customer preferences

- **Reports & Analytics**
  - Sales reports
  - Inventory reports
  - Revenue analytics
  - Performance metrics

- **Data Synchronization**
  - Real-time data sync with cloud
  - Offline mode support
  - Multi-device synchronization

- **Authentication & Security**
  - User authentication
  - Role-based access control
  - Secure data transmission

## 🛠 Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile application framework
- **Dart** - Programming language

### Backend & Database
- **Supabase** - Backend as a Service (BaaS)
  - PostgreSQL database
  - Real-time subscriptions
  - Authentication
  - Storage
  - API generation

### Key Packages
- `supabase_flutter` - Supabase integration for Flutter applications

## 📁 Project Structure

```
lib/
├── core/                    # Core utilities and configurations
│   ├── constants.dart      # App-wide constants
│   ├── routes.dart         # Route definitions
│   └── dashboard_screen.dart # Main dashboard screen
│
├── auth/                    # Authentication module
│   ├── auth_service.dart   # Authentication service
│   └── login_screen.dart   # Login screen
│
├── database/                # Database services
│   └── supabase_service.dart # Supabase initialization and service
│
├── inventory/               # Inventory management module
│   └── inventory_screen.dart # Inventory management screen
│
├── pos/                     # Point of Sale module
│   └── pos_screen.dart     # POS screen
│
├── customers/               # Customer management module
│   └── customers_screen.dart # Customers screen
│
├── reports/                 # Reports and analytics module
│   └── reports_screen.dart # Reports screen
│
├── sync/                    # Data synchronization module
│   └── sync_screen.dart    # Sync screen
│
└── main.dart               # Application entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Supabase account (for backend services)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd small_pos_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   - Create a new project at [supabase.com](https://supabase.com)
   - Get your project URL and anon key from the project settings
   - Update the Supabase credentials in `lib/main.dart`

4. **Run the application**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Supabase Configuration

Update the Supabase credentials in `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

Replace:
- `YOUR_SUPABASE_URL` - Your Supabase project URL
- `YOUR_SUPABASE_ANON_KEY` - Your Supabase anonymous key

You can find these values in your Supabase project settings under API.

## 🔧 Development

### Running the App

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device-id>
```

### Building the App

```bash
# Build APK for Android
flutter build apk

# Build iOS app (macOS only)
flutter build ios

# Build web app
flutter build web
```

### Project Structure Guidelines

- Each module (auth, inventory, pos, etc.) should be self-contained
- Use the `core` folder for shared utilities and constants
- Keep screens in their respective module folders
- Use services for business logic and API calls
- Follow Flutter and Dart best practices

## 📝 License

This project is part of an academic course project.

## 👥 Contributors

- Muhammad Abdullah Nadeem

## 🔮 Future Enhancements

- Barcode scanning integration
- Multi-currency support
- Advanced reporting with charts
- Employee management
- Supplier management
- Purchase orders
- Email/SMS notifications
- Mobile app for customers
