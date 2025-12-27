# Quick Setup Guide

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Configure Supabase

1. **Create a Supabase Account**
   - Go to [supabase.com](https://supabase.com)
   - Sign up for a free account
   - Create a new project

2. **Get Your Credentials**
   - In your Supabase project, go to **Settings** → **API**
   - Copy your **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - Copy your **anon/public key** (a long string)

3. **Update App Constants**
   - Open `lib/core/constants/app_constants.dart`
   - Replace `YOUR_SUPABASE_URL` with your Project URL
   - Replace `YOUR_SUPABASE_ANON_KEY` with your anon key

   ```dart
   static const String supabaseUrl = 'https://xxxxx.supabase.co';
   static const String supabaseAnonKey = 'your-anon-key-here';
   ```

## Step 3: Enable Email Authentication

1. In Supabase dashboard, go to **Authentication** → **Providers**
2. Make sure **Email** provider is enabled
3. Configure email settings if needed (for production)

## Step 4: Run the App

```bash
flutter run
```

## Testing

1. **Sign Up**: Create a new account with email and password
2. **Sign In**: Log in with your credentials
3. **Session Persistence**: Close and reopen the app - you should stay logged in

## Troubleshooting

### "Invalid API key" error
- Double-check your Supabase URL and anon key in `app_constants.dart`
- Make sure there are no extra spaces or quotes

### "Network error"
- Check your internet connection
- Verify your Supabase project is active
- Check Supabase dashboard for any service issues

### App crashes on startup
- Make sure you've run `flutter pub get`
- Check that all dependencies are installed
- Verify Supabase credentials are correct

## Next Steps

- Customize the UI theme in `lib/main.dart`
- Add more features following the Clean Architecture pattern
- Set up environment variables for production (see README.md)

