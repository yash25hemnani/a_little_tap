<p align="center">
  <img src="assets/images/icon.png" alt="A Little Tap" width="120" />
</p>

<h1 align="center">A Little Tap</h1>

<p align="center">
  Send your partner a feeling they can actually feel.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Android-brightgreen" alt="Platform: Android" />
  <img src="https://img.shields.io/badge/framework-Flutter-blue" alt="Framework: Flutter" />
  <img src="https://img.shields.io/badge/language-Dart-teal" alt="Language: Dart" />
  <img src="https://img.shields.io/badge/state-Riverpod-9cf" alt="State: Riverpod" />
  <img src="https://img.shields.io/badge/backend-Firebase-orange" alt="Backend: Firebase" />
  <img src="https://img.shields.io/badge/push-Cloudflare%20Workers-f38020" alt="Push: Cloudflare Workers" />
  <img src="https://img.shields.io/badge/version-1.0.0-ec6f80" alt="Version: 1.0.0" />
</p>

---

A Little Tap is a small app for two people. Tap the heart, and your partner's phone buzzes with a pattern that means something: two heartbeats for *Miss you*, three slow waves for *Thinking of you*, a warm swell for *Here for you*.

No typing and no reading. It's a way to say "I'm here" in the middle of a busy day.

## What you can do

**Send a tap**
Tap the heart on Home to send your current feeling. Hold it to pick a different one. Your partner gets a notification and feels the vibration, even when the app is closed.

**Make feelings your own**
Each feeling has a name, an icon, a colour and its own vibration. Edit the three starters or create new ones, and draw the vibration pattern yourself in the waveform editor.

**See when they're around**
Your partner's card on Home shows a green dot while they have the app open, and "Last seen" when they don't.

**Look back on your moments**
Every tap you've sent and received is kept in Moments, split into *Received* and *Sent*. Open any one to see it again.

**Keep your dates together**
Keepsakes is a shared calendar for birthdays, anniversaries, dates and trips. Either of you can add, edit or delete a date, and it shows up on both phones straight away. Yearly dates count up for you ("3 years").

**Get reminded**
You both get a reminder at 9 AM the day before a date, and another at midnight on the day. Tap the reminder to open the date.

**Stay in control**
Turn notifications or vibration off any time in Settings.

## Getting the app

A Little Tap runs on **Android**.

1. Download the latest APK from this repository's [Releases](../../releases) page.
2. Open it on your phone and allow installing from that source if Android asks.
3. Sign up with your email, then share your invite code with your partner, or enter theirs, to pair up.

You'll both need the app, and you need to be paired before you can send taps.

## Your privacy

- **Only the two of you** can see your taps, moments and dates. The database rules check this on every request.
- **What's stored:** your email, display name, feelings, taps, shared dates, notification settings, and when you were last online.
- **No ads and no tracking.** Notifications are only ever sent to the two people in a couple.
- **Logging out** stops notifications to that phone straight away.

---

## For developers

### How it fits together

```
Flutter app ──▶ Firebase Auth       (email sign-in)
            ──▶ Cloud Firestore     (users, couples, taps, dates)
            ──▶ Cloudflare Worker ──▶ Firebase Cloud Messaging ──▶ partner's phone
                    ▲
                    └── daily schedule (date reminders)
```

- **App:** Flutter with Riverpod. Data lives in Firestore, and screens update live from it.
- **Notifications:** a [Cloudflare Worker](https://github.com/yash25hemnani/little-tap-cloudflare-worker) sends data-only FCM messages. The app shows the notification itself and plays the feeling's vibration pattern, which a standard notification can't do.
- **Reminders:** the same worker runs on a schedule twice a day and sends reminders for upcoming dates.
- **Presence:** each phone writes a heartbeat to its own user document while the app is open. A partner counts as online if their last heartbeat is under 2 minutes old.

### Tech stack

| Area | Packages |
|---|---|
| State | `flutter_riverpod` |
| Backend | `firebase_core`, `firebase_auth`, `cloud_firestore` |
| Notifications | `firebase_messaging`, `flutter_local_notifications` |
| Haptics | `vibration` |
| Calendar | `table_calendar` |
| UI | `google_fonts`, `avatar_glow` |

### Data model

```
users/{uid}                     profile, settings, fcmTokens, online, lastSeen
  feelings/{id}                 that user's feelings
inviteCodes/{code}              → uid
pairRequests/{fromUid}_{toUid}  pending pair requests
couples/{coupleId}              members: [uidA, uidB]
  moments/{id}                  one per tap
  events/{id}                   shared calendar dates
```

### Project structure

```
lib/
  core/        layout, theme, shared formatting
  features/
    auth/          sign-up, sign-in, user profile
    pairing/       invite codes and pair requests
    couple/        the paired couple and partner
    home/          send a tap, received tap screen, partner card
    feelings/      feeling list and editor, vibration playback
    moments/       tap history with paging
    keepsakes/     shared calendar, event details, add and edit sheet
    notifications/ push registration and local notifications
    presence/      online heartbeat
    settings/      toggles and log out
    splash/
```

Each feature follows the same layout: `models/`, `repositories/` (Firestore access), `providers/` (Riverpod) and `screens/` or `widgets/`.

### Running it locally

**You'll need:** the Flutter SDK (Dart `^3.11`), Android Studio with an Android SDK, the Firebase CLI, and FlutterFire CLI.

1. **Clone and install packages**
   ```bash
   git clone https://github.com/yash25hemnani/a_little_tap.git
   cd a_little_tap
   flutter pub get
   ```

2. **Connect your own Firebase project**
   ```bash
   flutterfire configure
   ```
   This creates `lib/firebase_options.dart` and `android/app/google-services.json`. In the Firebase console, turn on **Email/Password** sign-in and create a Firestore database.

3. **Deploy the security rules and indexes**
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```

4. **Run**
   ```bash
   flutter run
   ```

Push notifications and reminders need the [worker](https://github.com/yash25hemnani/little-tap-cloudflare-worker) deployed against the same Firebase project. Without it, everything else still works, and taps still arrive while the app is open.

### Release builds

Release signing reads `android/key.properties`, which is not committed:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=C:/path/to/upload-keystore.jks
```

Without that file, release builds fall back to the debug key.

Raise `version:` in `pubspec.yaml` before every build, so the new APK installs over the old one. Then:

```bash
flutter build apk --release        # sideloading
flutter build appbundle --release  # Play Store
```
