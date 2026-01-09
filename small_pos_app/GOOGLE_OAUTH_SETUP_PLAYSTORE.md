# Google OAuth Setup for Play Store (Free Plan)

## Problem
You're getting "Google Sign-In Error 10 - OAuth Consent Screen Not Configured" because the OAuth consent screen needs to be properly configured for Play Store publication.

## Solution for Free Plan + Play Store

### Step 1: Go to Google Cloud Console
1. Open: https://console.cloud.google.com/apis/credentials/consent?project=ordinal-rig-409609
2. Make sure you're logged in with: `abdullah.nadeem492@gmail.com`

### Step 2: Configure OAuth Consent Screen

#### 2.1 Basic App Information
1. Click **"OAuth consent screen"** in the left menu
2. Select **"External"** (for public apps - required for Play Store)
3. Click **"CREATE"**

#### 2.2 Fill Required Fields:
- **App name**: `VendoraX POS`
- **User support email**: `abdullah.nadeem492@gmail.com`
- **App logo**: (Optional - upload your app icon if you have one)
- **Application home page**: 
  - If you have a website: Put your website URL
  - If not: Use GitHub repo URL or Play Store link (once published)
  - Example: `https://github.com/yourusername/vendorax-pos`
- **Application privacy policy link**: ⚠️ **REQUIRED for Play Store**
  - **You MUST create and host a privacy policy**
  - **Quick method**: Use https://www.privacypolicygenerator.info/
  - **Host it free on**: GitHub Pages, Netlify, or Google Sites
  - **See OAUTH_APP_DOMAIN_SETUP.md for detailed instructions**
- **Application terms of service link**: (Optional but recommended)
  - Create similar to privacy policy
  - Host on same free service
- **Authorized domains**: 
  - **Leave EMPTY** - Not needed for Android apps
  - Only required for web applications
- **Developer contact information**: `abdullah.nadeem492@gmail.com`

4. Click **"SAVE AND CONTINUE"**

**📋 See OAUTH_APP_DOMAIN_SETUP.md for detailed step-by-step instructions on creating and hosting privacy policy!**

### Step 3: Scopes (IMPORTANT)
1. You'll see "Scopes" page
2. Click **"ADD OR REMOVE SCOPES"**
3. Search and add these scopes:
   - `https://www.googleapis.com/auth/drive.file`
   - `https://www.googleapis.com/auth/drive.appdata`
4. Click **"UPDATE"** then **"SAVE AND CONTINUE"**

### Step 4: Test Users (For Development)
1. Scroll to **"Test users"** section
2. Click **"+ ADD USERS"**
3. Add your email: `abdullah.nadeem492@gmail.com`
4. Click **"ADD"**
5. Click **"SAVE AND CONTINUE"**

### Step 5: Summary
1. Review all settings
2. Click **"BACK TO DASHBOARD"**

### Step 6: Enable Google Drive API
1. Go to: **APIs & Services** → **Library**
2. Search: **"Google Drive API"**
3. Click on **"Google Drive API"**
4. Click **"ENABLE"**

### Step 7: Verify OAuth Client ID
1. Go to: **APIs & Services** → **Credentials**
2. Find your OAuth 2.0 Client ID: `39984977372-5p4nbbjeavnatjfdcnm4bctocgobd0ha`
3. Make sure it's configured as:
   - **Application type**: Android
   - **Package name**: `com.example.small_pos_app`
   - **SHA-1 certificate fingerprint**: (Your debug/release SHA-1)

## For Play Store Publication

### Important Notes:

1. **App Verification (May be Required)**
   - If Google requires verification, you'll see a warning
   - For sensitive scopes (Drive API), Google may require app verification
   - This is FREE but takes 4-6 weeks
   - You can publish to Play Store in "Testing" mode first

2. **Publishing Status**
   - **Testing**: Up to 100 test users (no verification needed)
   - **In production**: May require verification for sensitive scopes
   - You can start with "Testing" track on Play Store

3. **Privacy Policy (REQUIRED)**
   - Play Store requires a privacy policy URL
   - Create one at: https://www.privacypolicygenerator.info/
   - Must mention Google Drive API usage

4. **Production vs Testing**
   - During development: Use "Testing" mode (up to 100 users)
   - For production: Submit for verification if prompted
   - Verification is FREE but takes time

## Quick Checklist

- [ ] OAuth consent screen configured as "External"
- [ ] All required fields filled (especially privacy policy)
- [ ] Scopes added: `drive.file` and `drive.appdata`
- [ ] Test user added: `abdullah.nadeem492@gmail.com`
- [ ] Google Drive API enabled
- [ ] OAuth Client ID has correct package name and SHA-1
- [ ] Privacy policy URL created and added

## After Setup

1. Wait 5-10 minutes for changes to propagate
2. Try signing in again in your app
3. If still errors, check:
   - SHA-1 fingerprint is correct
   - Package name matches exactly
   - OAuth consent screen is published (not just saved)

## Troubleshooting

**Error 10 persists?**
- Make sure OAuth consent screen is saved (not just in draft)
- Check that your email is in test users list
- Verify SHA-1 fingerprint matches

**Verification Required?**
- This is normal for sensitive scopes
- You can still test with up to 100 users
- Submit verification request (it's free)

**Need Help?**
- Google Cloud Console Support: https://cloud.google.com/support
- OAuth Documentation: https://developers.google.com/identity/protocols/oauth2

