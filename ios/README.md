# iOS Build Configuration for Pregame App

## Codemagic Setup Instructions

### Prerequisites
1. **Apple Developer Account**: Ensure you have an active Apple Developer account
2. **App Store Connect**: App should be registered in App Store Connect
3. **Bundle ID**: `com.pregame.app` (already configured)

### Required Environment Variables in Codemagic

#### App Store Connect API
- `APP_STORE_CONNECT_ISSUER_ID`: Your App Store Connect issuer ID
- `APP_STORE_CONNECT_KEY_IDENTIFIER`: Your App Store Connect key identifier  
- `APP_STORE_CONNECT_PRIVATE_KEY`: Your App Store Connect private key

#### Code Signing
- `CERTIFICATE_PRIVATE_KEY`: Your iOS distribution certificate private key
- Set up automatic code signing in Codemagic dashboard

### Firebase Configuration
- The `GoogleService-Info.plist` is already configured for bundle ID `com.pregame.app`
- Ensure Firebase project has iOS app registered with this bundle ID

### Build Configuration
- **Minimum iOS Version**: 12.0
- **Supported Devices**: iPhone and iPad
- **Orientations**: Portrait, Landscape Left, Landscape Right
- **Background Modes**: Background fetch, Remote notifications

### Required Permissions
The app requests the following permissions:
- **Location Services**: For finding nearby venues
- **Camera**: For sharing game day photos
- **Photo Library**: For accessing and saving photos
- **Microphone**: For voice messages

### Build Process
1. Connect your GitHub repository to Codemagic
2. Use the provided `codemagic.yaml` configuration
3. Configure environment variables in Codemagic dashboard
4. Set up code signing certificates
5. Run the iOS workflow

### App Store Submission
The app is configured for:
- TestFlight distribution
- App Store submission
- Automatic version numbering

### Troubleshooting
- Ensure all certificates are valid and not expired
- Verify bundle ID matches in all configuration files
- Check that Firebase iOS configuration is correct
- Ensure all required permissions are properly declared

### Next Steps
1. Register app in App Store Connect with bundle ID `com.pregame.app`
2. Generate and configure signing certificates
3. Set up Codemagic environment variables
4. Run first build and test on TestFlight 