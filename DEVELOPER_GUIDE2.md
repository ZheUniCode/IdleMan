This is a comprehensive update. I have restructured the documentation to match the "Therapy Paper" aesthetic and the "Clinical Guardian" philosophy. This document serves as the single source of truth for the v16.0 architecture.

-----

# IDLEMAN: THE MINDFUL BOUNDARY SYSTEM

## Definitive Master Operational Specification (v16.0)

**Version:** 16.0.0
**Codename:** "Paper Garden"
**Classification:** Behavioral Health / Digital Boundary Architecture
**Visual Language:** "Therapy Paper" (Tactile, Serif, Calm)
**Status:** **ACTIVE DEVELOPMENT**

-----

## 1.0 PRODUCT MANIFESTO & ETHICAL FRAMEWORK

### 1.1 The Pivot: Compassionate Discipline

Previous iterations (v1.0 - v14.0) utilized "Antagonistic Design"—treating the user as an adversary to be defeated. This resulted in high churn ("The Rage Quit").

**Version 16.0** pivots to **Compassionate Discipline**.

  * **The Concept:** The application acts not as a Warden, but as a **Clinical Guardian**.
  * **The Mechanism:** We retain **Transaction Cost Theory** (making bad habits expensive), but reframe "Cost" as "Investment" and "Block" as "Space."
  * **The Outcome:** The user feels safe within the boundaries. Retention is driven by trust, not force.

### 1.2 The Ethical Data Promise (Local-First)

To differentiate from predatory blockers, IdleMan v16.0 adopts a strict "Local-First" architecture.

  * **Zero-Knowledge Notifications:** Notification content interception happens locally. Raw text from notifications (e.g., WhatsApp messages) is **never** transmitted to the cloud.
  * **No Shame Metrics:** We track "Time Reclaimed" (Positive), not "Time Wasted" (Negative).
  * **Opt-In Social:** Accountability is mutual (Co-op Garden), not hierarchical (Reporting/Snitching).

-----

## 2.0 SYSTEM ARCHITECTURE

The app utilizes a Hybrid Architecture to balance high-performance UI (Flutter) with aggressive system persistence (Kotlin Native).

### 2.1 The Stack

  * **UI Layer:** Flutter (Dart 3.0+)
      * Rendering Engine: Skia/Impeller
      * State Management: Riverpod (v2.0+)
      * Local DB: Hive (NoSQL, Key-Value)
  * **System Layer:** Kotlin (Android Native)
      * Service: `AccessibilityService` (Monitoring)
      * Window: `WindowManager` (Overlays)
      * Sync: `MethodChannel`
  * **Cloud Layer:** Firebase
      * Auth: Anonymous Auth (low friction) -\> Link to Email
      * DB: Firestore (Garden State)

### 2.2 Directory Structure

```text
lib/
├── core/
│   ├── theme/          # "Therapy Paper" Theme System
│   ├── logic/          # The Brain (Riverpod Providers)
│   └── services/       # Local Services (Hive, Audio, Haptics)
├── features/
│   ├── reflection/     # App Selection & Usage Stats
│   ├── defense/        # The Overlay System (Levels 1-3)
│   ├── garden/         # Social Co-op
│   └── digest/         # Notification Sanitization Engine
└── native/             # MethodChannel Interfaces
```

-----

## 3.0 VISUAL IDENTITY: "THERAPY PAPER"

The UI is designed to lower cortisol. It mimics high-end cardstock and fountain pen ink.

### 3.1 Color Palette ("The Calm")

| Semantic Name | Hex Code | Usage | Metaphor |
| :--- | :--- | :--- | :--- |
| **Canvas** | `#F7F5F2` | Scaffold Background | Warm, unbleached paper. |
| **Surface** | `#FFFFFF` | Cards / Modals | Fresh paper cardstock. |
| **Ink** | `#2D3436` | H1, H2, Body | Fountain pen ink (Soft Charcoal). |
| **Graphite** | `#636E72` | Metadata / Subtitles | Pencil markings. |
| **Boundary** | `#E76F51` | Timers / Blocks | Muted Terra Cotta (Correction pen). |
| **Growth** | `#84A98C` | Success / Streaks | Sage Green (Nature). |

### 3.2 Physics & Tactility

  * **Elevation:** No hard drop shadows. Use diffused ambient occlusion:
    `BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 4))`
  * **Corner Radius:**
      * Cards: `24.0`
      * Buttons: `100.0` (Pills)
  * **Typography:**
      * **Headers:** *Playfair Display* (Serif) – Authority, history.
      * **Body:** *Nunito* (Rounded Sans) – Approachability.

### 3.3 Sensory Feedback ("The Purr")

  * **Haptics:** Replace mechanical "clicks" with `HapticFeedback.heavyImpact()` for failures and custom waveform vibrations for breathing timers.
  * **Audio:** Skeuomorphic sounds (Paper tearing, pencil scribbling, book closing).

-----

## 4.0 THE REFLECTION ENGINE (Data Ingestion)

### 4.1 Native Bridge: `UsageStatsManager`

We do not ask the user to "Block" apps. We ask them to "Reflect."

**Kotlin Implementation:**
`AppMonitorService.kt` requests `UsageStatsManager.queryUsageStats()` with `INTERVAL_DAILY`.

### 4.2 Filtering Logic (The "Hidden Whitelist")

To reduce cognitive load, we filter out non-actionable apps before the UI renders.

**Dart Filter Logic:**

```dart
bool isReflectable(ApplicationInfo app) {
  const excluded = ['com.android.settings', 'com.android.vending', 'com.google.android.dialer'];
  if (excluded.contains(app.packageName)) return false;
  if (app.isSystemApp && !app.isUpdatedSystemApp) return false;
  return true;
}
```

-----

## 5.0 THE MINDFUL DEFENSE SYSTEM

This is the core loop. It replaces "Blocking" with "Levels of Awareness."

### 5.1 Level 1: The Intent Check (0 - 15m)

  * **Trigger:** `AccessibilityEvent` detects a flagged package.
  * **Visual:** `BackdropFilter` with Gaussian Blur (10.0). A Cream-colored modal slides up.
  * **Logic:**
      * User selects a duration (5m, 10m, 15m).
      * App allows pass-through.
      * **The Ghost Timer:** A semi-transparent pill overlay (`SystemAlertWindow`) sits in the corner.

### 5.2 Level 2: The Practice (15m - 45m)

If the user attempts to extend beyond the initial intent, they must pay a "Physiological Cost."

**Task A: The Mindful Walk (Pedometer)**

  * **Sensor:** `Sensor.TYPE_STEP_DETECTOR`
  * **The Jerk Filter:** To prevent "shaking the phone" to cheat:
      * Monitor `Sensor.TYPE_ACCELEROMETER`.
      * If G-force variance \> 2.5g within 500ms of a step event -\> **Invalidate Step**.
      * UI Feedback: *"Movement too chaotic. Walk naturally."*

**Task B: Focus Activation (Math)**

  * Generate 5 simple arithmetic problems.
  * **UX:** Flashcard style. No keyboard input; Numpad only.

### 5.3 Level 3: The Boundary (45m+)

The "Hard Stop." The app is effectively sealed.

  * **Bypass:** Only via Financial Commitment (Micro-transaction).
  * **Logic:** If `StrictMode` is enabled, the overlay draws with `WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY` and consumes all touch events.

-----

## 6.0 THE DIGEST ENGINE (Notification Sanitization)

Instead of blocking notifications (anxiety inducing), we batch and sanitize them.

### 6.1 Interception

**Service:** `NotificationListenerService`
**Action:**

1.  Intercept `onNotificationPosted`.
2.  If package is in `BoundaryMap`:
      * Extract `extras.getString(EXTRA_TITLE)` and `EXTRA_TEXT`.
      * Call `cancelNotification(key)`.
      * Save payload to Hive Box `digest_queue`.

### 6.2 The Sanitizer (Regex)

We remove dopamine triggers (Emojis, CAPS) locally before storing.

```dart
String sanitize(String input) {
  // 1. Remove Emojis
  var text = input.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), '');
  // 2. Fix ALL CAPS
  text = text.replaceAllMapped(RegExp(r'\b[A-Z]{2,}\b'), (match) {
    return match.group(0)!.substring(0, 1) + match.group(0)!.substring(1).toLowerCase();
  });
  return text.trim();
}
```

### 6.3 Delivery

At user-scheduled times (e.g., 1 PM, 6 PM), a local notification triggers: *"Your Mid-Day Digest is ready."*

-----

## 7.0 SOCIAL: THE SHARED GARDEN

Cooperative Multiplayer. If one user fails, the shared garden stops growing.

[Image of Firebase Firestore Data Model Diagram]

### 7.1 Firestore Schema

**Path:** `gardens/{garden_id}`

```json
{
  "participants": ["uid_A", "uid_B"],
  "state": "GROWING", // or "PAUSED"
  "streak_count": 14,
  "plant_type": "MONSTERA",
  "plant_stage": 3, // 1=Sprout, 2=Seedling, 3=Plant, 4=Tree
  "last_watered": "2025-12-05T00:00:00Z",
  "history": [
    {
      "date": "2025-12-04",
      "status": "SUCCESS"
    }
  ]
}
```

### 7.2 The Logic

  * **Watering:** Triggered automatically at 00:00 Local Time if no Level 3 Bypasses occurred.
  * **The Pause:** If User A buys a "Rest Day" or breaches Strict Mode -\> `state: PAUSED`. User B receives a notification: *"The Garden is resting while User A recovers."*

-----

## 8.0 ARCHITECTURE: THE HYDRA PROTOCOL

Ensuring the app survives background kills.

### 8.1 Resilience Strategy

1.  **Foreground Service:** Run a visible notification ("IdleMan is active") tied to the Pedometer service.
2.  **WorkManager:** Periodic task every 15 minutes to check if `AccessibilityService` is alive. If not, trigger a high-priority notification to the user.
3.  **Boot Receiver:** `BOOT_COMPLETED` listener to restart monitoring immediately on device restart.

### 8.2 Time Anti-Cheat

We validate time against NTP (Network Time Protocol) to prevent "System Clock Rewind" cheats.

  * Fetch `NTP_Time` on init.
  * If `System.currentTimeMillis()` deviates \> 60s from `NTP_Time + Uptime`, trigger **Time Tamper Lockdown**.

-----

## 9.0 MONETIZATION: "INVESTMENT"

**Framing:** All payments are framed as "Investments" or "Commitments," never "Penalties."

| SKU | Display Name | Logic |
| :--- | :--- | :--- |
| `skip_task` | **Fast Pass** | Bypasses Level 2 (Walking/Math). |
| `day_unlock` | **Rest Day** | Disables boundaries for 24h. Pauses Garden. |
| `bailout_bundle` | **Commitment Credits** | Bundle of 5 Fast Passes. |

-----

## 10.0 IMPLEMENTATION ROADMAP

### Phase 1: The Foundation (Week 1)

  * [ ] Setup Flutter 3.0 + Riverpod + Hive.
  * [ ] Implement "Therapy Paper" Theme Extension.
  * [ ] Build "Reflection" UI (Usage Stats List).

### Phase 2: The Defense (Week 2)

  * [ ] Kotlin: `AccessibilityService` detection logic.
  * [ ] Kotlin: `SystemAlertWindow` implementation.
  * [ ] Dart: Level 1 (Intent) & Level 2 (Pedometer) logic.

### Phase 3: The Garden (Week 3)

  * [ ] Firebase Auth (Anonymous).
  * [ ] Firestore `gardens` collection & security rules.
  * [ ] Garden UI (Rive animations for plant growth).

### Phase 4: Integration (Week 4)

  * [ ] Notification Listener & Regex Sanitizer.
  * [ ] Billing Client integration.
  * [ ] "Hydra" resilience checks.

-----