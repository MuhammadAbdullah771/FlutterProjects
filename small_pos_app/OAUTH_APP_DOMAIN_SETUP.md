# How to Fill OAuth Consent Screen - App Domain Section

## Step-by-Step Guide for Free Plan + Play Store

### Step 1: Create a Free Privacy Policy

**Option A: Use Privacy Policy Generator (Easiest)**
1. Go to: https://www.privacypolicygenerator.info/
2. Fill in:
   - **App Name**: VendoraX POS
   - **Company Name**: Your name or company
   - **Email**: abdullah.nadeem492@gmail.com
   - **Website URL**: (You can use a placeholder or GitHub page)
   - **Data Collection**: Check "Google Drive API" (for backup feature)
3. Click "Generate Privacy Policy"
4. Copy the generated HTML
5. Host it on a free service:
   - **GitHub Pages** (Free): https://pages.github.com/
   - **Netlify** (Free): https://www.netlify.com/
   - **Vercel** (Free): https://vercel.com/
   - **Google Sites** (Free): https://sites.google.com/

**Option B: Use Simple Text Privacy Policy**
Create a simple text file with:
```
Privacy Policy for VendoraX POS

Last updated: [Today's Date]

We collect and store:
- Product inventory data
- Customer information
- Sales transactions
- Store settings

Data Storage:
- Local device storage (SQLite)
- Optional: Google Drive backup (if enabled by user)

We do not share your data with third parties except:
- Google Drive (only if you enable backup feature)

Contact: abdullah.nadeem492@gmail.com
```

Host this on any free hosting service.

### Step 2: Fill Out App Domain Fields

#### Application Home Page
**What to put:**
- If you have a website: Put your website URL (e.g., `https://yourwebsite.com`)
- If you don't have a website: Use one of these:
  - GitHub repository: `https://github.com/yourusername/vendorax-pos`
  - Play Store listing (once published): `https://play.google.com/store/apps/details?id=com.example.small_pos_app`
  - Simple placeholder: `https://vendorax-pos.app` (you can create a free domain later)

**Example:** `https://github.com/yourusername/vendorax-pos`

#### Application Privacy Policy Link (REQUIRED)
**This is MANDATORY for Play Store!**

1. Create privacy policy using Step 1 above
2. Host it on free service (GitHub Pages, Netlify, etc.)
3. Get the URL (e.g., `https://yourusername.github.io/privacy-policy`)
4. Paste it in this field

**Example:** `https://yourusername.github.io/vendorax-pos-privacy-policy`

**Quick GitHub Pages Setup:**
1. Create a new GitHub repository: `vendorax-pos-privacy`
2. Create `index.html` with your privacy policy
3. Go to Settings → Pages
4. Enable GitHub Pages
5. Your URL will be: `https://yourusername.github.io/vendorax-pos-privacy`

#### Application Terms of Service Link (Optional but Recommended)
**What to put:**
- Similar to privacy policy, create a simple terms of service
- Host on same free service
- Or use: `https://yourusername.github.io/vendorax-pos-terms`

**Simple Terms Template:**
```
Terms of Service for VendoraX POS

1. Use of the app is at your own risk
2. We are not responsible for data loss
3. Users are responsible for backing up their data
4. The app is provided "as is" without warranties

Contact: abdullah.nadeem492@gmail.com
```

### Step 3: Authorized Domains

**For Android Apps: This is usually NOT required!**

- Authorized domains are mainly for **web applications**
- For Android apps, you typically don't need to add domains here
- **Leave this section empty** unless Google specifically asks for it

**Only add domains if:**
- You're using a web client ID (not Android client ID)
- Google explicitly requires it during verification

### Step 4: Branding Verification (Right Column)

**What it means:**
- Google wants to verify your app's branding before showing it to users
- This is required for production apps

**What to do:**
1. Click "Verify branding" button
2. Fill out the verification form:
   - App name: VendoraX POS
   - App logo: Upload your app icon
   - Support email: abdullah.nadeem492@gmail.com
   - Privacy policy URL: (Use the one from Step 2)
3. Submit for verification
4. **Note:** Verification can take 4-6 weeks, but it's FREE
5. **You can still publish to Play Store "Testing" track** while waiting

### Step 5: Save and Continue

1. Fill in all required fields (Privacy Policy is mandatory)
2. Click "SAVE AND CONTINUE"
3. Proceed to next steps (Scopes, Test Users, etc.)

## Quick Checklist

- [ ] Privacy Policy created and hosted (REQUIRED)
- [ ] Privacy Policy URL added to "Application privacy policy link"
- [ ] Home page URL added (can be GitHub or Play Store link)
- [ ] Terms of Service created (optional but recommended)
- [ ] Authorized domains: Leave empty (not needed for Android)
- [ ] Click "SAVE AND CONTINUE"

## Free Hosting Options for Privacy Policy

### Option 1: GitHub Pages (Recommended - Free)
1. Create GitHub account (if you don't have one)
2. Create new repository: `vendorax-privacy-policy`
3. Create `index.html` file with privacy policy
4. Go to repository Settings → Pages
5. Enable GitHub Pages
6. Your URL: `https://yourusername.github.io/vendorax-privacy-policy`

### Option 2: Netlify (Free)
1. Go to https://www.netlify.com/
2. Sign up (free)
3. Create new site
4. Upload HTML file
5. Get free URL: `https://your-site.netlify.app`

### Option 3: Google Sites (Free)
1. Go to https://sites.google.com/
2. Create new site
3. Add privacy policy content
4. Publish
5. Get URL: `https://sites.google.com/view/your-site`

## Important Notes

1. **Privacy Policy is MANDATORY** for Play Store apps
2. **Home page can be simple** - GitHub repo or Play Store link works
3. **Terms of Service is optional** but recommended
4. **Authorized domains not needed** for Android apps
5. **Branding verification** can be done later (you can test with up to 100 users first)

## After Filling Out

1. Click "SAVE AND CONTINUE"
2. Proceed to add Scopes (drive.file, drive.appdata)
3. Add Test Users (your email)
4. Enable Google Drive API
5. Wait 5-10 minutes for changes to propagate
6. Try signing in again in your app

