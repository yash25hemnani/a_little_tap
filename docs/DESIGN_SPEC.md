# A Little Tap — Design Spec

> "Small moments. Big connections."
> A couples app: send your partner a one-tap "feeling" (heart) with no typing needed. They get a notification and can tap back.

Source: reference mockup with 17 screens (provided 2026-10-20).

---

## Visual language

| Token | Value / notes |
|---|---|
| Background | Warm cream/blush gradient (≈ `#FFF6F2` → `#FDE8EC`) |
| Primary | Coral pink buttons (≈ `#EC6F80`), full-width pills, white label |
| Primary text | Deep plum/brown (≈ `#4A2B33`) for titles |
| Secondary text | Muted mauve-grey, small |
| Accent (tap back) | Lavender/periwinkle (≈ `#8E8CE0`, bg `#ECEBFB`) |
| Heart | Glossy 3D pink heart, soft glow and concentric pulse rings |
| Logo | "A Little Tap" in a script/handwritten font + a heart with sparkle lines |
| Cards | White, ~16px radius, subtle shadow / hairline border |
| Avatars | Round, 3D cartoon style (boy / girl), pastel ring background |
| Bottom nav | 3 tabs: Home · Moments · Settings (active = pink) |
| Feel | Soft, rounded, airy, lots of whitespace, floating hearts and confetti |

Note: current `lib/core/theme/app_colors.dart` uses `#FF4D6D` / `#FDEEF1`; the mockup's pink is softer and more muted.

---

## Screens

### Onboarding & auth
1. **Splash** — script logo, heart with sparkles, tagline "Small moments. Big connections.", a thin wavy line ending in a heart at the bottom.
2. **Onboarding 1** — two avatars with a small heart between them. "A Little Tap": *A simple way to stay close, no words needed.* Page dots, **Get Started**, Skip.
3. **Onboarding 2** — phone illustration with a heart. "Send a little tap": *Share a quick message, a feeling or just a heart.* **Next**, Skip.
4. **Onboarding 3** — avatars with hearts. "Stay connected": *Your partner will feel it, even from afar.* **Get Started**, Skip.
5. **Sign up / Create account** — back arrow, email, password (min 8 chars, eye toggle), **Continue**, "or", **Continue with Google**, "Already have an account? Log in".
6. **Pairing / Invite code** — "Pair with your partner". Segmented control: *Enter code* / *Create code*. Invite code input (format `XXXX-XXXX`, e.g. `7F3K-2Q9D`), **Continue**, "Don't have a code? Create one".

### Core loop
7. **Home – Send a Tap**
   - Header: partner avatar, name, status ("Online • 2m ago"), settings gear.
   - Big pulsing heart button in the centre: *Tap to send a little something*.
   - Quick feeling chips: **Miss you** (heart), **Thinking of you** (flower), **Here for you** (sun).
   - "Last tap from Alex" card: *Thinking of you • 3:24 PM* with a chevron.
   - Bottom nav.
8. **Feeling selector** (bottom sheet, opened by long press or more) — "Choose a feeling":
   - Miss you: *You're on my mind.*
   - Thinking of you: *Just wanted to say hi.*
   - Here for you: *You're not alone.*
   - Surprise me: *Send a random tap.*
   - Cancel.
9. **Sending animation** — full-screen heart with expanding rings and floating bubbles. "Sending…" plus the feeling label.
10. **Received tap (push notification)** — lock screen notification: "A Little Tap · Alex sent you a tap · Thinking of you".
11. **Received tap (in app)** — close X, partner avatar with floating confetti hearts, "Alex sent you a tap", feeling label, heart, **Tap back**, "View details".
12. **Tap back confirmation** — lavender theme, purple heart with rings, "You tapped back", *Right back at you*, **Done**.

### Secondary
13. **Moments / History** — "Our moments". Tabs: *Received* / *Sent*. List rows: avatar (or feeling icon), name/"You", feeling • time (relative: 3:24 PM, Yesterday, Apr 20), chevron. "View all".
14. **Settings**
    - Notifications: Push notifications (toggle), Vibration (toggle), Quiet hours (`10:00 PM – 7:00 AM`).
    - App: Pairing, Privacy, Help & Support.
    - **Log out** (soft pink button).
15. **Profile** (optional) — large avatar, name, online status, "Together since Apr 12, 2025". Rows: Change photo, Edit name, Pairing info. Card: "Your invite code 7F3K-2Q9D" with **Share**.
16. **Home-screen widget** (optional)
    - Last tap widget: heart, "Alex sent you a tap", feeling • time.
    - "Together N days" counter widget with both avatars and a heart.
17. **Edge cases**
    - **No internet**: wifi icon with error badge. "No internet connection. We'll sync your taps once you're back online." **Try again**.
    - **Partner offline**: sleepy heart (zZ). "Your partner is offline. They'll see your tap when they're back." **OK**.

---

## Data model (implied)

- **User**: id, email, name, avatar, inviteCode, online/lastSeen.
- **Pair**: userA, userB, togetherSince.
- **Tap**: id, from, to, feeling (`miss_you | thinking_of_you | here_for_you | surprise`), sentAt, isTapBack, readAt.
- **Settings**: pushEnabled, vibrationEnabled, quietHoursStart/End.

## Features needed

- Auth: email/password and Google sign-in.
- Pairing by an invite code.
- Realtime tap delivery and push notifications (FCM/APNs) that respect quiet hours.
- Haptics on send and receive.
- Presence (online / last seen).
- Offline queue that syncs when the connection returns.
- History, split into sent and received.
- Home-screen widgets for iOS and Android (optional).
