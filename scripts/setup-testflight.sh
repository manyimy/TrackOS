#!/bin/bash
set -e

echo "🔧 TrackOS TestFlight Setup"
echo "============================"
echo ""

# Check if on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script requires macOS. You're on $OSTYPE"
    exit 1
fi

# Step 1: Generate Xcode project
echo "📦 Generating Xcode project from Swift Package..."
cd iOS
swift package generate-xcodeproj
cd ..

echo "✅ Xcode project generated at: iOS/TrackOS.xcodeproj"
echo ""

# Step 2: Instructions
echo "📋 Next steps:"
echo ""
echo "1️⃣  Open the Xcode project:"
echo "    open iOS/TrackOS.xcodeproj"
echo ""
echo "2️⃣  In Xcode, select the 'TrackOS' target and go to Signing & Capabilities:"
echo "    - Select your Team ID"
echo "    - Set Bundle ID to: com.yourcompany.trackos"
echo "    - Let Xcode create the provisioning profile automatically"
echo ""
echo "3️⃣  Commit the changes to git:"
echo "    git add iOS/TrackOS.xcodeproj/"
echo "    git commit -m 'Add Xcode project with code signing'"
echo ""
echo "4️⃣  Set up GitHub secrets (see TESTFLIGHT.md for details)"
echo ""
echo "5️⃣  Push to 'testflight' branch to trigger the build:"
echo "    git push origin HEAD:testflight"
echo ""
echo "📖 For detailed instructions, see: TESTFLIGHT.md"
