# Supabase Setup Guide for Push Notifications

## Step 1: Create Supabase Account

1. Go to [https://supabase.com](https://supabase.com)
2. Click **"Start your project"** or **"Sign Up"**
3. Sign up with:
   - GitHub account (recommended), or
   - Email and password
4. Verify your email if required

## Step 2: Create a New Project

1. After logging in, click **"New Project"**
2. Fill in the project details:
   - **Name**: `small-pos-app` (or any name you prefer)
   - **Database Password**: Create a strong password (save it securely!)
   - **Region**: Choose closest to your location
   - **Pricing Plan**: Free tier is sufficient for development
3. Click **"Create new project"**
4. Wait 2-3 minutes for project setup to complete

## Step 3: Get Your Project Credentials

1. Once project is ready, go to **Settings** → **API**
2. Copy the following:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
   - **service_role key**: (Keep this secret! Only for server-side)

## Step 4: Update Your App Configuration

1. Open `lib/main.dart`
2. Replace the Supabase URL and key with your project credentials:

```dart
await Supabase.initialize(
  url: 'YOUR_PROJECT_URL',  // Replace with your Project URL
  anonKey: 'YOUR_ANON_KEY',  // Replace with your anon/public key
);
```

## Step 5: Set Up Database Tables

1. In Supabase Dashboard, go to **SQL Editor**
2. Click **"New query"**
3. Copy and paste the contents of `supabase_setup.sql`
4. Click **"Run"** to execute
5. Verify tables are created in **Table Editor**

## Step 6: Enable Real-time for Products Table

1. In Supabase Dashboard, go to **Database** → **Replication**
2. Find the `products` table
3. Toggle **"Enable"** for real-time replication
4. Or run this SQL in SQL Editor:

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE products;
```

## Step 7: Set Up Low Stock Trigger (Optional but Recommended)

1. Go to **SQL Editor**
2. Copy and paste the contents of `supabase_realtime_setup.sql`
3. Click **"Run"** to execute
4. This creates a trigger that automatically detects low stock

## Step 8: Configure Row Level Security (RLS)

RLS is already configured in `supabase_setup.sql`, but verify:

1. Go to **Authentication** → **Policies**
2. Ensure policies are created for:
   - `products` table
   - `customers` table
   - `transactions` table

## Step 9: Test Real-time Notifications

1. Build and install your app
2. Create a product with low stock (stock_quantity ≤ low_stock_threshold)
3. Update a product's stock to be low
4. You should receive a push notification!

## Step 10: Enable Push Notifications (Mobile)

For Android push notifications via Supabase:

1. Go to **Settings** → **API** → **Push Notifications**
2. Upload your Firebase Cloud Messaging (FCM) server key
3. Configure Android package name: `com.example.small_pos_app`

## Troubleshooting

### Real-time not working?
- Check if real-time is enabled for `products` table
- Verify you're authenticated (logged in)
- Check browser console for errors

### Notifications not showing?
- Ensure notification permissions are granted
- Check if `NotificationService` is initialized
- Verify product has `stock_quantity` and `low_stock_threshold` set

### Connection issues?
- Verify Project URL and anon key are correct
- Check internet connection
- Ensure Supabase project is active (not paused)

## Security Notes

- **Never commit** your `service_role` key to version control
- Use `anon` key in the app (it's safe for client-side)
- RLS policies ensure users only see their own data
- Always use HTTPS for Supabase connections

## Free Tier Limits

- **500 MB database storage**
- **2 GB bandwidth**
- **50,000 monthly active users**
- **Unlimited API requests** (with rate limiting)

For production, consider upgrading to Pro plan ($25/month).

## Support

- Supabase Docs: [https://supabase.com/docs](https://supabase.com/docs)
- Discord Community: [https://discord.supabase.com](https://discord.supabase.com)
- GitHub Issues: [https://github.com/supabase/supabase](https://github.com/supabase/supabase)

