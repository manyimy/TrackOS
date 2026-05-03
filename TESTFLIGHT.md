# Test TrackOS on TestFlight

## Prerequisites
- Apple Developer Program account ($99/year)
- iPhone or iPad with iOS 17+
- GitHub account (for CI/CD)

## Setup Steps

### 1. Create App in App Store Connect
- Go to https://appstoreconnect.apple.com
- Create new app: **iOS** platform
- **Name:** TrackOS
- **Bundle ID:** `com.yourcompany.trackos` (replace `yourcompany` with your reverse-domain ID)
- **SKU:** `trackos` (any unique string)
- Leave other fields as default

### 2. Create App Store Connect API Key
- In App Store Connect, go **Users and Access** → **API Keys** (under "Integrations")
- Click **Generate API Key**
- Name: "TrackOS CI/CD"
- Access Level: **Admin**
- Download the `.p8` file
- **Copy the API Key ID** (e.g. `ABC123XYZ`)
- **Copy the Issuer ID** (e.g. `12345678-1234-1234-1234-123456789012`)

### 3. Add GitHub Secrets
Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions** and add:

| Secret Name | Value |
|---|---|
| `APP_STORE_CONNECT_API_KEY` | Content of your `.p8` file |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID (e.g. `ABC123XYZ`) |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID (e.g. `12345678-...`) |
| `APPLE_TEAM_ID` | From Developer.apple.com → Membership (e.g. `ABC123DEFG`) |
| `BUNDLE_ID` | `com.yourcompany.trackos` |

### 4. Generate Xcode Project (ONE-TIME SETUP)
**You need a Mac for ~1 hour to do this once. After that, everything is automated.**

**Free option:** Borrow a Mac from a friend, coworker, library, or local Mac Meetup

**On the Mac:**
```bash
# Clone your repo
git clone https://github.com/yourname/TrackOS.git
cd TrackOS

# Run setup script
bash scripts/setup-testflight.sh
```

This:
1. Generates `iOS/TrackOS.xcodeproj` from the Swift Package
2. Opens Xcode with instructions

**In Xcode** (on the borrowed Mac):
- Open `iOS/TrackOS.xcodeproj`
- Select **TrackOS** target → **Signing & Capabilities** tab
- Click **Sign in** (top-right) → sign with your Apple ID
- Select your Team (should auto-detect)
- Xcode creates provisioning profiles automatically ✓

**Commit & push:**
```bash
git add iOS/TrackOS.xcodeproj/
git commit -m "Add Xcode project with code signing"
git push origin main
```

**That's it!** Return the Mac. You're done with it forever.

Now you can test from Windows! 🎉

### 5. Trigger TestFlight Build
**From Windows 11:**
1. Push code to the `testflight` branch:
   ```bash
   git push origin HEAD:testflight
   ```
2. Go to GitHub repo → **Actions** tab
3. The **"Build & Upload to TestFlight"** workflow will start
4. Wait ~15 minutes for the build to finish
5. Check App Store Connect → **TestFlight** tab to see your build

### 6. Invite Testers & Test
1. In App Store Connect, go to your app → **TestFlight** tab
2. Click **Add Tester**
3. Invite people (or yourself) by email
4. They download **TestFlight app** from App Store
5. Accept the invite and install TrackOS

## Build Status
Check workflow runs at: **GitHub repo** → **Actions** tab

## Troubleshooting

**"Code signing failed"**
- Verify APPLE_TEAM_ID matches your Developer account
- Check BUNDLE_ID matches App Store Connect

**"API key invalid"**
- Copy the entire `.p8` file content (including `-----BEGIN PRIVATE KEY-----`)
- Verify API_KEY_ID and ISSUER_ID are correct

**"TestFlight upload rejected"**
- Check that app metadata (name, screenshots, description) is complete in App Store Connect
- Ensure your account has TestFlight permissions

## Next Steps
Once you've tested on TestFlight and are ready to ship:
- Add screenshots & description in App Store Connect
- Submit for App Review
- Once approved, release on the App Store
