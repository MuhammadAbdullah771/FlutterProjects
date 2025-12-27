# Supabase Authentication Setup Guide

## Step 1: Get Your Supabase Credentials

1. **Go to your Supabase Dashboard**
   - Visit: https://app.supabase.com
   - Log in to your account
   - Select your project

2. **Navigate to API Settings**
   - Click on **Settings** (gear icon) in the left sidebar
   - Click on **API** under Project Settings

3. **Copy Your Credentials**
   - **Project URL**: Found under "Project URL" section
     - Looks like: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon/public key**: Found under "Project API keys" section
     - It's the `anon` `public` key (a long string starting with `eyJ...`)

## Step 2: Update App Constants

Open `lib/core/constants/app_constants.dart` and replace:
- `YOUR_SUPABASE_URL` with your Project URL
- `YOUR_SUPABASE_ANON_KEY` with your anon key

## Step 3: Enable Email Authentication

1. In Supabase Dashboard, go to **Authentication** → **Providers**
2. Find **Email** provider
3. Make sure it's **enabled** (toggle should be ON)
4. Configure settings:
   - **Enable email confirmations**: Optional (turn OFF for testing, ON for production)
   - **Secure email change**: Optional
   - **Double confirm email changes**: Optional

## Step 4: Test Authentication

Run the app and test:
- Sign up with a new email
- Sign in with your credentials
- Close and reopen app (should stay logged in)

## Troubleshooting

### "Invalid API key" error
- Double-check you copied the **anon/public** key (not the service_role key!)
- Make sure there are no extra spaces or quotes
- Verify the URL is correct

### "Email already registered"
- This means the email is already in use
- Try a different email or sign in instead

### "Network error"
- Check your internet connection
- Verify Supabase project is active
- Check Supabase status page

