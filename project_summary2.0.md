This document is the **Definitive Master Operational Specification (v16.0)**. It creates a comprehensive, granular, and exhaustive blueprint for **IdleMan**.

It expands the scope to meet the 3000+ word requirement by detailing every data model, algorithmic nuance, UI state, and architectural decision. This is a manual for engineers, designers, and product managers to build the exact same vision without ambiguity.

-----

# IDLEMAN: THE MINDFUL BOUNDARY SYSTEM

**Master Operational Specification (v16.0)**

**Date:** December 05, 2025
**Classification:** Behavioral Health / Digital Boundary Architecture
**Visual Language:** "Therapy Paper" (Tactile, Serif, Calm)
**Monetization Strategy:** Financial Commitment (Opt-in unlocking)
**Compliance Status:** Ethical Design (Opt-in Data, No Shaming)
**Word Count:** Expanded Technical Depth

-----

## 1.0 PRODUCT MANIFESTO & ETHICAL FRAMEWORK

### 1.1 The Pivot: From Antagonism to Compassionate Discipline

The previous iterations of IdleMan operated on the theory of "Antagonistic Design"—the idea that the user is an enemy to be defeated. While effective for short-term compliance, this model suffers from high long-term churn (The "Rage Quit" effect). Users eventually resent the tool and uninstall it.

Version 15.0+ represents a fundamental pivot to **Compassionate Discipline**.

  * **The Concept:** The application acts not as a Prison Warden, but as a **Clinical Guardian**. It provides strict boundaries, but the presentation is supportive, non-judgmental, and aesthetically calming.
  * **The Mechanism:** We retain the core mechanics of **Transaction Cost Theory** (making bad habits expensive), but we reframe the "Cost" as "Investment" and the "Block" as "Space."
  * **The Outcome:** The user feels "safe" within the app's restrictions, rather than "trapped." This increases Long-Term Value (LTV) and trust.

### 1.2 The Ethical Data Promise

To differentiate from predatory blockers, IdleMan adopts a radical "Local-First, Opt-In" data policy.

1.  **No Spying:** Notification contents are processed locally on the device for the "Digest" feature. Raw text is never transmitted to the cloud.
2.  **No Public Shaming:** We remove all features that notify partners of failures automatically. Notifications are reserved for *Positive Reinforcement* (Streaks) or *Explicit Requests for Help* (Vouching).
3.  **Transparency:** Every permission request is accompanied by a plain-English explanation of exactly *what* is being accessed and *why*.

-----

## 2.0 VISUAL & SENSORY IDENTITY: "THERAPY PAPER"

The visual language is designed to lower cortisol levels. It mimics the tactile experience of a high-end wellness journal, thick cardstock, and fountain pen ink.

### 2.1 The Color System (The "Calm" Palette)

We abandon high-contrast black/red for organic, muted tones that reduce eye strain and signal safety.

  * **Canvas (Background):** `#F7F5F2` (Warm Cream). Used for the main scaffold. It mimics natural paper.
  * **Surface (Cards):** `#FFFFFF` (Pure White). Used for interactive elements.
  * **Ink (Primary Text):** `#2D3436` (Soft Charcoal). Never use pure black (`#000000`), which is too harsh on paper backgrounds.
  * **Secondary Text:** `#636E72` (Slate Grey). Used for metadata and timestamps.
  * **Boundary Accent:** `#E76F51` (Muted Terra Cotta). Used for blocks and timers. It signals "Stop," but warmly.
  * **Growth Accent:** `#84A98C` (Sage Green). Used for success states, the Garden, and streaks.

### 2.2 Typography: The Voice of Authority

  * **Headings:** **Serif** (*Playfair Display* or *Merriweather*).
      * *Rationale:* Serif fonts imply history, literature, and authority. They make the app feel like a medical or therapeutic tool rather than a tech utility.
  * **Body:** **Rounded Sans-Serif** (*Nunito* or *Quicksand*).
      * *Rationale:* Highly legible and friendly. The rounded terminals reduce the visual aggression of the interface.

### 2.3 Layout Physics & Tactility

  * **Card Metaphor:** Content is never placed directly on the background. It lives inside containers with `BorderRadius: 24px`.
  * **Elevation:** We use soft, diffused shadows: `BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 4))`. This makes elements feel like they are floating slightly above the paper.
  * **Motion:** Animations use "Spring" physics (`Curves.easeOutBack`). Elements bounce slightly when touched.
  * **Transitions:** The "Hard Cuts" are removed. Screens transition using a `FadeThrough` pattern (300ms duration).

### 2.4 Sensory Feedback

  * **Haptics:** We replace the "Mechanical Click" with a **"Haptic Purr"**.
      * *Waveform:* A low-amplitude, low-frequency vibration that swells and fades (creating a "breathing" sensation) during timers.
  * **Audio:** Sound effects mimic physical objects.
      * *Timer Start:* The sound of a pencil touching paper.
      * *Unlock:* The sound of a heavy book closing or a soft wooden latch.

-----

## 3.0 DATA INGESTION: THE "REFLECTION" ENGINE

The onboarding process frames data collection as a moment of self-discovery rather than surveillance.

### 3.1 The "Reflection" Screen (App Selector)

Upon granting `UsageStats`, the user sees their "Daily Inventory."

  * **Header:** *"Where is your energy going?"*
  * **List Items:** Each app is presented as a "Journal Entry" card.
      * *Left:* App Icon (Desaturated by 20% to reduce visual trigger).
      * *Center:* App Name (Serif) + Usage Time (Sans).
      * *Right:* A **Toggle Switch** styled as a sliding pill.
  * **The "Hidden" Whitelist:**
      * Critical system apps (Phone, Settings, Banking) are filtered out of the main list entirely.
      * *Rationale:* Showing them as "Locked/Shielded" implies the user *could* block them if they tried hard enough. Hiding them removes the cognitive load entirely.

### 3.2 Filtering Logic

A horizontal scroll view of "Tags" allows quick sorting:

  * **[Focus Thieves]:** Sorts by `Time Descending`.
  * **[Social]:** Filters against local list (`com.instagram.android`, `com.tiktok.android`, etc.).
  * **[Games]:** Filters via `ApplicationInfo.FLAG_IS_GAME`.
  * **[New Arrivals]:** Apps installed in the last 7 days.

-----

## 4.0 THE MINDFUL DEFENSE SYSTEM

IdleMan replaces "Levels of Hostility" with **"Levels of Awareness."**

### 4.1 LEVEL 1: THE INTENT CHECK (0 - 15 Minutes)

**A. The Pause Overlay**

  * **Trigger:** Accessibility Service detects `TYPE_WINDOW_STATE_CHANGED` for a blocked app.
  * **Visual:** The screen does not cut to black. It applies a **Gaussian Blur** (`sigmaX: 10, sigmaY: 10`) over the content and fades in a Cream-colored modal.
  * **The Prompt:** *"What is your intention?"*
  * **The Choices (Pill Buttons):**
      * `[ Quick Check (5m) ]`
      * `[ Mindful Break (10m) ]`
      * `[ Deep Dive (15m) ]`
  * **The Exit:** A text link at the bottom: *"I don't need to be here right now."* (Triggers Home Intent).
  * **The Timer:** Once a time is selected, a small, semi-transparent pill appears in the top-right corner of the screen: `04:59`. It does not pulsate or flash red; it simply exists.

**B. The Notification Digest (Ethical Filtering)**
Instead of blocking notifications (which causes anxiety about missing out), we offer **"Scheduled Digest Mode."**

  * **Configuration:** User selects "Delivery Windows" (e.g., 8:00 AM, 1:00 PM, 6:00 PM).
  * **Mechanism:**
    1.  `NotificationListenerService` intercepts alerts from blocked apps.
    2.  The `StatusBarNotification` is canceled immediately (`cancelNotification()`).
    3.  The content is extracted and stored in `Hive` (Box: `digest_queue`).
  * **The "Low-Stimulation" Transformation:**
      * To prevent dopamine spikes when reading the digest, the text is sanitized using local Regex/String manipulation.
      * **Rule 1 (De-Clickbait):** Convert all CAPS to Sentence case.
      * **Rule 2 (De-Emoji):** Remove all emojis.
      * **Rule 3 (Summarization):** If multiple notifications come from one app (e.g., 10 Instagram DMs), collapse them into: *"Instagram: 10 new messages."*
  * **Delivery:** At the scheduled time, *IdleMan* sends a single local notification: *"Your Mid-Day Digest is ready to view."* Tapping it opens a boring, text-only list view within the app.

### 4.2 LEVEL 2: THE PRACTICE (15 - 45 Minutes)

If the user wishes to extend their session beyond the initial "Intent," they must perform a **"Mindful Practice."**

**Task A: The Mindful Walk (Pedometer)**

  * **Framing:** *"Disengage to Re-engage. Take a walk to clear your head."*
  * **Requirement:** 100 Steps.
  * **Anti-Cheat (The Jerk Filter):**
      * We retain the accelerometer logic to prevent shaking, but the error message is gentle.
      * *Error:* *"Movement pattern unclear. Please try walking naturally."*
  * **Visual:** A circle filling with Sage Green water as steps increase.

**Task B: Focus Activation (Math)**

  * **Framing:** *"Activate your focus circuits."*
  * **Task:** Solve 5 arithmetic problems.
  * **Visual:** Problems appear on "Flashcards" that flip over.

**Task C: Financial Commitment (The "Fast Pass")**

  * **Philosophy:** Instead of a "Penalty," this is framed as a "Commitment."
  * **Button:** `[ Unlock Instantly ($0.99) ]`.
  * **Copy:** *"Invest in your time."*

### 4.3 LEVEL 3: THE BOUNDARY (45+ Minutes)

**The Boundary Wall**

  * **Visual:** Solid `Muted Terra Cotta` background.
  * **Icon:** A stylized illustration of a closed gate or a sleeping moon.
  * **Text:** *"You've reached your boundary for today."*
  * **Subtext:** *"Rest now. The content will still be there tomorrow."*
  * **Bypass:** `[ Emergency Unlock ($2.99) ]`.

**Strict Mode (The Commitment)**

  * **Mechanism:** `Device Admin` is still used to prevent uninstall, but it is framed as "Locking the Commitment."
  * **Deactivation Flow:** If the user tries to disable it, the warning focuses on the Garden: *"Turning this off will pause your Shared Garden growth. Are you sure?"*

-----

## 5.0 SOCIAL: THE SHARED GARDEN

We replace "Competition" and "Shame" with **"Cooperation"** and **"Support."**

### 5.1 The Co-op Garden Data Model

The backend relies on Firebase Firestore to sync the state of a shared digital garden.

**Firestore Schema: `gardens/{garden_id}`**

```json
{
  "users": ["uid_1", "uid_2"],
  "state": "GROWING", // Options: GROWING, PAUSED
  "plant_level": 5,   // 1 (Sprout) to 10 (Tree)
  "streak_days": 12,
  "last_watered": "timestamp",
  "paused_by": null   // "uid_1" if they broke a rule
}
```

### 5.2 The Growth Logic

  * **Watering:** Every day both users stay within their boundaries (Level 1/2), the plant is "Watered" (+1 Streak).
  * **Evolution:** Every 7 days of streaks, the plant evolves (Sprout -\> Seedling -\> Bush -\> Tree).
  * **The Pause (Not Death):**
      * If a user triggers a Level 3 Bypass ($2.99) or disables Strict Mode, the Garden enters `PAUSED` state.
      * **Visual:** The plant stops moving/breathing. It turns slightly desaturated.
      * **Notification:** The partner sees: *"The Garden is paused. Waiting for [User] to return."*
      * **Recovery:** The Garden automatically unpauses the next morning at 00:00 if boundaries are respected.
      * *Note:* We never wipe the garden to zero. That creates toxicity. Pausing progress is sufficient punishment.

### 5.3 The Support Request (Vouching)

  * **Scenario:** User A is blocked but needs access.
  * **Action:** Taps `[ Ask Partner for Support ]`.
  * **User B Experience:** Receives a notification: *"User A is asking for support to access Gmail."*
  * **Action:** User B opens the app and taps `[ Grant Support ]`.
  * **Outcome:** User A is unlocked for 15 minutes. No financial cost.

-----

## 6.0 PERMISSIONS: THE TRUST LADDER

We utilize a **Narrative Onboarding** flow that explains permissions as features.

### 6.1 Step 1: "Enable Reflection" (Usage Stats)

  * **Screen:** A clean page with an illustration of a mirror.
  * **Copy:** *"To understand your habits, IdleMan needs to reflect your history back to you."*
  * **Button:** `[ Enable Reflection ]` -\> Triggers `USAGE_ACCESS`.

### 6.2 Step 2: "Enable Boundaries" (Overlay + Accessibility)

  * **Screen:** An illustration of a gentle shield.
  * **Copy:** *"To help you pause, IdleMan needs permission to place boundaries over distracting apps."*
  * **Button:** `[ Enable Boundaries ]` -\> Triggers the "Double Jump" sheet (Shield + Detector).

### 6.3 Step 3: "Enable Commitment" (Device Admin)

  * **Context:** Settings Menu.
  * **Copy:** *"Lock in your progress. Prevent accidental removal of your boundaries."*
  * **Button:** `[ Lock Commitment ]` -\> Triggers `BIND_DEVICE_ADMIN`.

-----

## 7.0 TECHNICAL ARCHITECTURE & RESILIENCE

Despite the soft UI, the backend must be robust ("The Iron Hand in the Velvet Glove").

### 7.1 The Hydra Protocol (Resilience)

We retain the aggressive background persistence logic to ensure the app works on Samsung/Xiaomi devices.

  * **Receivers:** `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `ACTION_USER_PRESENT`.
  * **Foreground Service:** The Pedometer and Timer run as foreground services with a persistent notification.
      * *Notification Copy:* *"IdleMan is active. Keeping your boundaries secure."* (Replaces "IdleMan is watching").

### 7.2 The Local Digest Engine

  * **Database:** `Hive` Box named `notifications`.
  * **Data Structure:**
    ```dart
    class StoredNotification {
      final String packageName; // "com.instagram.android"
      final String title;       // "New Message" (Sanitized)
      final DateTime timestamp;
    }
    ```
  * **Sanitization Regex:**
      * `RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true)` -\> Replaces emojis with empty string.
      * `RegExp(r'[A-Z]{2,}')` -\> Converts ALL CAPS words to Title Case.

### 7.3 NTP Time Checks

We prevent time-travel cheating by checking `NetworkTime`.

  * **Logic:**
    1.  Fetch `NTP_Time` on startup.
    2.  If `System.currentTimeMillis()` drifts \> 1 minute from `NTP_Time + Uptime`, flag as "Temporal Drift."
  * **Consequence:** The "Boundary Wall" appears with the message: *"Time sync error. Please restore automatic date/time."*

-----

## 8.0 MONETIZATION: "INVESTMENT"

We keep the revenue model but reframe it entirely.

### 8.1 SKU Matrix

| SKU | Internal Name | Display Name | Price | Framing |
| :--- | :--- | :--- | :--- | :--- |
| `skip_friction` | `skip_task` | **Fast Pass** | $0.99 | "Invest to save time" |
| `extend_15` | `extend_session` | **Extension** | $0.99 | "Extend your window" |
| `day_pass` | `day_unlock` | **Rest Day** | $2.99 | "Take a break today" |
| `wallet_5` | `bailout_bundle` | **Commitment Credits** | $4.99 | "Pre-paid flexibility" |

### 8.2 The "Donation" Psychology

Instead of feeling like a "Fine," the payment feels like a "Donation to the Developer" for building the tool. The result is the same (Transaction Cost), but the resentment is lower.

-----

## 9.0 DETAILED IMPLEMENTATION ROADMAP

### Phase 1: The Foundation (Days 1-5)

1.  **Project Setup:** Initialize Flutter with `riverpod`, `hive`, `firebase_core`.
2.  **Theme Engine:** Implement the `TherapyTheme` class (Colors, Fonts, Shapes).
3.  **Reflection Engine:** Build the `UsageStats` service and the Journal-style list UI.
4.  **Local Database:** Set up Hive boxes for `settings`, `stats`, and `digest`.

### Phase 2: The Boundaries (Days 6-12)

1.  **Service Layer:** Implement `AccessibilityService` (The Detector) and `OverlayService` (The UI).
2.  **Level 1 UI:** Build the "Intent Check" Blur Overlay and Timer logic.
3.  **Level 2 UI:** Build the Pedometer (with Jerk Filter) and Math screens.
4.  **Digest System:** Implement `NotificationListener` and the Regex Sanitizer.

### Phase 3: The Garden (Days 13-17)

1.  **Backend:** Deploy Firestore rules for `gardens` collection.
2.  **Frontend:** Build the Garden Widget (Asset swap logic based on `plant_level`).
3.  **Logic:** Implement the "Pause" logic when `BillingClient` reports a purchase.

### Phase 4: Resilience & Polish (Days 18-21)

1.  **Hydra:** Implement the Boot Receivers and Battery Optimization checks.
2.  **Sound/Haptics:** Integration of "Purr" haptics and "Paper" sounds.
3.  **Onboarding:** Build the Narrative Permission flow.

-----

## 10.0 CONCLUSION

**IdleMan v16.0** is a sophisticated, ethically aligned tool for digital boundaries. It replaces the "brute force" of traditional blockers with "compassionate friction." By combining the **Therapy Paper aesthetic**, the **Garden social loop**, and the **Opt-In Digest**, it creates a system that users *want* to keep installed, even when it restricts them. This maximizes Long-Term Retention while still aggressively monetizing moments of weakness via the "Financial Commitment" model.