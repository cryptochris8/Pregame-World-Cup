# iOS Signing Guide — Codemagic + Apple Developer Portal

How to set up, maintain, and troubleshoot iOS code signing for apps built in Codemagic. Derived from the 2+ hour debugging session on 2026-04-21 that finally nailed down how all the pieces fit together.

---

## Core concepts

| Thing | Where it lives | What it does |
|---|---|---|
| **Apple Distribution Certificate** | Apple Developer Portal → Certificates | Cryptographic identity. Signs your app. Apple limits you to 2 per team. **One cert can sign many apps — reuse it.** |
| **Private key** | Codemagic vault (if Codemagic made the cert) or your local Mac Keychain (if you made it) | The secret half of the cert. Without it, a cert is unusable for signing. |
| **App ID (Identifier)** | Apple Developer Portal → Identifiers | Registers a bundle ID with Apple. Needed before you can make a profile for it. |
| **Provisioning Profile** | Apple Developer Portal → Profiles | Ties (Certificate + App ID + Entitlements) together for signing one specific app. **One per bundle ID.** Widgets/extensions need their own. |
| **ASC API Key** | App Store Connect → Users and Access → Integrations | Lets automation (Codemagic) talk to Apple on your behalf. Needs **Admin** access for full signing automation. |
| **Codemagic "Developer Portal" integration** | Codemagic → Teams → Integrations | Where you register your ASC API keys so Codemagic can use them during builds. |

---

## Codemagic UI quirks (read this first)

1. **There is only ONE Apple-related integration in Codemagic**, confusingly named **"Developer Portal"**. Despite `codemagic.yaml` referencing `app_store_connect: <name>`, there is no separate "App Store Connect" integration in the Team integrations page. Codemagic's Developer Portal integration handles both certs/profiles AND App Store Connect operations.

2. `codemagic.yaml`'s `integrations: app_store_connect: Pregame` looks up a key **named "Pregame"** inside the Developer Portal integration. The name must match exactly.

3. **Codemagic can create distribution certificates but cannot create provisioning profiles.** Profiles must be made manually in Apple Developer Portal. Codemagic can then "fetch" them once they exist.

---

## Setting up a new app from scratch

### Prerequisites
- App Store Connect account with access to your team
- Codemagic account connected to your repo
- App's bundle IDs decided (main + any extensions like widgets)

### Steps

**1. Register bundle IDs in Apple Developer Portal**
- `developer.apple.com/account` → Certificates, IDs & Profiles → **Identifiers** → **+**
- Select **App IDs** → App → explicit bundle ID (e.g., `com.yourname.yourapp`)
- Repeat for any extension bundle IDs (e.g., `com.yourname.yourapp.YourWidget`)

**2. Create an ASC API Key (Admin access)**
- App Store Connect → **Users and Access** → **Integrations** tab
- Click **+** → Name it after the app (e.g., `MyApp-Admin`) → **Access: Admin** (critical — App Manager won't work)
- Generate → **immediately download the `.p8` file** (only shown once)
- Note the **Key ID** and **Issuer ID** (issuer is shared team-wide)

**3. Add the key to Codemagic**
- Codemagic → **Teams** → **Integrations** → **Developer Portal** → **Manage keys** → **Add another key**
- Name: must match what `codemagic.yaml` references in `app_store_connect:` (e.g., `MyApp`)
- Issuer ID, Key ID, `.p8` file → Save

**4. Generate or reuse the Distribution certificate**

If you already have a working distribution cert from a prior app:
- **Skip this step.** One cert signs all your apps.

If this is your first app:
- Codemagic → Developer Portal → Manage keys → **Create distribution certificate**
- Name it generically like `distribution` or `yourteam_distribution` (not app-specific, since it's shared)
- Codemagic stores the private key in its vault
- The cert appears in Apple Developer Portal automatically

**5. Create provisioning profiles in Apple Developer Portal**
- `developer.apple.com` → **Profiles** → **+** → **App Store** (under Distribution)
- App ID: pick the main app's bundle ID → Continue
- Certificate: select the Codemagic-generated distribution cert → Continue
- Profile Name: `<AppName> App Store` → Generate
- **Repeat for each extension bundle ID** (widget, etc.)

**6. Fetch profiles in Codemagic**
- Codemagic → Developer Portal → Manage keys → **Fetch signing files** (or equivalent)
- Codemagic pulls down the profiles you just created and stores them

**7. Configure `codemagic.yaml`**
```yaml
workflows:
  ios-workflow:
    integrations:
      app_store_connect: MyApp  # must match the key name in step 3
    environment:
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.yourname.yourapp  # main app only
```

**8. Trigger a build** — automatic signing will now find the cert + profiles and succeed.

---

## Adding a new app to an existing certificate

Reuse the shared distribution cert; don't create a new one.

1. Register the new app's bundle IDs in Apple Developer Portal.
2. Create an ASC Admin API key for the new app (separate keys per app is optional but cleaner).
3. Add key to Codemagic Developer Portal integration.
4. **Skip cert creation** — reuse the existing one.
5. Apple Developer Portal → Profiles → create App Store profiles for each new bundle ID, pointing at the shared cert.
6. Codemagic → fetch profiles.
7. Set up new app's `codemagic.yaml` with the new key name reference.
8. Trigger build.

---

## Rotating an expired or compromised certificate

Distribution certs expire yearly. Plan a rotation before they do.

1. **Before expiry**, in Codemagic → create a new distribution cert.
2. Apple Developer Portal → Profiles: for each profile, edit → replace old cert with new cert. (Or delete old profiles and create new ones.)
3. Codemagic → fetch signing files (refreshes).
4. Trigger builds to verify.
5. **Once all apps have been built with the new cert**, revoke the old cert.
6. If you revoke BEFORE the switch-over, all your apps' profiles become Invalid and builds fail. Don't do that.

---

## Troubleshooting

### "No matching profiles found for bundle identifier X"

What it actually means: Codemagic can't find a usable profile for that bundle ID. Causes:

- No profile exists in Apple Developer Portal for that bundle ID → create one
- The profile exists but Codemagic can't authenticate with Apple to read it → API key is deleted/revoked/wrong role. Check the key in Codemagic matches a valid entry in ASC Integrations with Admin access
- The profile's certificate is orphaned (private key not accessible) → Codemagic filters out profiles it can't actually sign with. Fix: revoke orphaned certs, generate fresh Codemagic-owned ones

### "No matching certificate found for every requested profile"

Codemagic has profiles but every cert they reference has a private key it can't access. Typically:
- Cert was created by an API key that was later deleted (key holds private key → key gone → private key inaccessible)
- You're trying to manually sign with a cert you uploaded but the `.p12` was missing the private key

Fix: revoke orphaned certs, have Codemagic regenerate. Or for manual signing, regenerate `.p12` WITH the private key included.

### Silent auth failures

If an API key Codemagic uses gets revoked/deleted without Codemagic knowing, builds fail with confusing errors about missing profiles or certs. The real error is authentication. Verify every key in Codemagic Manage keys still exists under the same Key ID in ASC Integrations.

### Accidentally have duplicate Distribution certs

Apple allows max 2. If you're at the limit and need a new one, revoke an unused one first. Duplicate Distribution certs with the same name are legal but cause confusion — prefer one active cert for all your team's apps.

### Widget / extension signing fails

An app with widgets/extensions has multiple bundle IDs. Each needs its own App Store provisioning profile, even though they share the distribution cert. Missing a profile for an extension causes the whole build to fail — the error usually names the main app bundle ID, not the extension.

Check: does every bundle ID in `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER = ...;`) have a matching profile in Apple Developer Portal?

---

## Things to never do

- Don't create a separate distribution cert for every app. You'll hit Apple's 2-per-team limit.
- Don't upload `.mobileprovision` files manually to Codemagic when using automatic signing. Mixing the two paradigms causes Codemagic to get confused about which to use.
- Don't delete an ASC API key without first checking what certs it created. Deleting the key orphans every cert it generated.
- Don't build against a new cert without first updating all profiles to point at it. Profiles referencing an old/revoked cert fail silently.

---

## Quick reference — naming conventions used here

| Thing | Suggested name |
|---|---|
| Shared distribution cert | `distribution` or `pregame_distribution` |
| ASC API key (per app) | `<AppName>-Admin` (e.g., `Pregame-Admin`) |
| Codemagic Developer Portal key name | `<AppName>` (e.g., `Pregame`) — must match `codemagic.yaml` |
| Provisioning profile | `<AppName> App Store` (e.g., `Pregame App Store`) |
| Widget profile | `<AppName> Widget App Store` |

---

*Last verified working: 2026-04-21 (Pregame World Cup V7 submission).*
