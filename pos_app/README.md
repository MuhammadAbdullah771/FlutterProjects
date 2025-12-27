# Smart POS & Inventory Management App

A Flutter application built with Clean Architecture, featuring Supabase authentication and a scalable, maintainable codebase.

## 🏗️ Architecture

This project follows **Clean Architecture** principles, organized into three main layers:

```
lib/
├── core/              # Shared utilities, constants, and infrastructure
│   ├── constants/     # App-wide constants (API keys, storage keys, etc.)
│   ├── di/           # Dependency injection (Service Locator)
│   ├── errors/       # Error handling classes
│   └── utils/        # Utility classes (Result, extensions, etc.)
│
├── data/             # Data layer (repositories, data sources)
│   ├── datasources/  # Data sources (local storage, remote API)
│   └── repositories/ # Repository implementations (Supabase)
│
├── domain/           # Business logic layer
│   ├── entities/     # Business entities (User, etc.)
│   └── repositories/ # Repository interfaces (abstractions)
│
└── presentation/     # UI layer
    ├── providers/    # State management (AuthProvider)
    └── screens/      # UI screens (Login, Signup, Home)
```

### Key Principles

- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Inversion**: Domain layer doesn't depend on data layer
- **Repository Pattern**: Backend abstraction allows easy backend swapping
- **Single Responsibility**: Each class has one clear purpose

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- A Supabase account (free tier available)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd pos_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   
   a. Create a Supabase project at [supabase.com](https://supabase.com)
   
   b. Get your project credentials:
      - Go to Project Settings → API
      - Copy your **Project URL** and **anon/public key**
   
   c. Update `lib/core/constants/app_constants.dart`:
      ```dart
      static const String supabaseUrl = 'YOUR_SUPABASE_URL';
      static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
      ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Main Dependencies

- **supabase_flutter**: Backend services (authentication, database)
- **shared_preferences**: Local storage for session persistence
- **equatable**: Value equality comparisons

### Why These Packages?

- **supabase_flutter**: Provides authentication, real-time database, and storage
- **shared_preferences**: Simple key-value storage for session tokens
- **equatable**: Makes value comparisons easier and cleaner

## 🔐 Authentication Flow

1. **Sign Up**: User creates account with email and password
2. **Sign In**: User logs in with credentials
3. **Session Persistence**: Session is saved locally and restored on app restart
4. **Auto-login**: App checks for existing session on startup

### Error Handling

The app provides clear, user-friendly error messages for:
- Invalid credentials
- Network errors
- Email validation
- Password requirements
- Account already exists

## 🏛️ Repository Pattern

The app uses the Repository Pattern to abstract backend implementation:

```dart
// Domain layer defines the interface
abstract class AuthRepository {
  Future<Result<User>> signUp({...});
  Future<Result<User>> signIn({...});
  // ...
}

// Data layer implements with Supabase
class SupabaseAuthRepository implements AuthRepository {
  // Supabase-specific implementation
}
```

### Benefits

- **Easy Backend Swapping**: Replace Supabase with Firebase, custom API, etc.
- **Testability**: Mock repositories for unit testing
- **Separation**: Business logic doesn't depend on Supabase

## 📱 Features

### Current Features

- ✅ Email/Password authentication
- ✅ User registration
- ✅ Session persistence
- ✅ Auto-login on app restart
- ✅ Clear error handling
- ✅ Clean, modern UI

### Coming Soon

- 🔄 POS (Point of Sale) functionality
- 📦 Inventory management
- 📊 Analytics and reporting
- 👥 Multi-user support
- 💾 Offline mode

## 🧪 Testing

To run tests:

```bash
flutter test
```

## 📝 Code Structure

### Adding New Features

1. **Domain Layer**: Define entities and repository interfaces
2. **Data Layer**: Implement repositories with Supabase
3. **Presentation Layer**: Create UI screens and providers

### Example: Adding a New Feature

```dart
// 1. Domain: Define interface
abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();
}

// 2. Data: Implement with Supabase
class SupabaseProductRepository implements ProductRepository {
  // Implementation
}

// 3. Presentation: Create UI
class ProductsScreen extends StatelessWidget {
  // UI code
}
```

## 🔧 Configuration

### Environment Variables

For production, consider using environment variables instead of hardcoding:

1. Create `.env` file:
   ```
   SUPABASE_URL=your_url
   SUPABASE_ANON_KEY=your_key
   ```

2. Use `flutter_dotenv` package to load variables

3. Update `app_constants.dart` to read from environment

## 🐛 Troubleshooting

### Common Issues

1. **"ServiceLocator not initialized"**
   - Ensure `main()` calls `ServiceLocator().initialize()`

2. **Authentication not working**
   - Verify Supabase credentials in `app_constants.dart`
   - Check Supabase project settings (email auth enabled)

3. **Session not persisting**
   - Check SharedPreferences permissions
   - Verify session is being saved after login

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

Built with ❤️ using Flutter and Supabase

---

## 🎯 Next Steps

1. Set up your Supabase project
2. Configure credentials in `app_constants.dart`
3. Run the app and test authentication
4. Start building POS features!

For questions or issues, please open an issue on GitHub.
