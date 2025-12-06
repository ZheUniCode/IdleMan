Here is the **updated** `.cursorrules` file. I have added a strict **"Hyper-Verbose Documentation & Logging"** section.

This instructs the AI to treat every single line of code as if it is being written for a beginner who needs to understand exactly what is happening, and to log every action for debugging purposes.

Replace the previous content with this version:

````markdown
# IDLEMAN v16.0 PROJECT RULES
# Codename: Paper Garden
# Philosophy: Compassionate Discipline

You are the Lead Architect for IdleMan v16.0. Your goal is to build a digital boundary application that acts as a "Clinical Guardian," not a prison warden.

ALL generated code and logic must strictly adhere to the following principles.

---

## 1. VISUAL IDENTITY: "THERAPY PAPER"
We have completely abandoned Neumorphism. Do not generate code with inner shadows, intense blur, or "soft plastic" looks.

### Color Palette (The "Calm" System)
- **Scaffold Background:** `Color(0xFFF7F5F2)` (Warm Cream/Paper)
- **Surface/Cards:** `Color(0xFFFFFFFF)` (Pure White)
- **Primary Text (Ink):** `Color(0xFF2D3436)` (Soft Charcoal - NEVER Pure Black)
- **Secondary Text:** `Color(0xFF636E72)` (Graphite)
- **Accent (Boundary):** `Color(0xFFE76F51)` (Muted Terra Cotta)
- **Accent (Growth):** `Color(0xFF84A98C)` (Sage Green)

### Typography
- **Headings:** Serif (Playfair Display or Merriweather). Use for Titles and "Therapeutic" messaging.
- **Body:** Rounded Sans-Serif (Nunito or Quicksand). Use for UI controls and lists.

### Physics & Shapes
- **Card Shape:** `RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))`
- **Shadows:** Diffused Ambient only. `BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 4))`
- **Motion:** Use "Spring" physics (`Curves.easeOutBack`) for scale animations.

---

## 2. STRICT VERBOSITY: LOGGING & COMMENTS
**CRITICAL REQUIREMENT:** You must adhere to the following documentation and debugging standards. No exceptions.

### A. Comments for Most Lines
- **Lots OF CODE** must have a preceding comment explaining exactly what it does.
````

### B. Debugs for Everything

  - **Trace Execution:** Every method must have a debug log at the start (Entry) and end (Exit).
  - **State Changes:** Every variable assignment or state update must be logged.
  - **Format:** Use `debugPrint` (Flutter) or `Log.d` (Kotlin) with a standardized tag format: `[Class::Method]`.
  - Example:
    ```dart
    void updateScore(int points) {
        // Log entry into the method with arguments
        debugPrint('[ScoreManager::updateScore] Started. Points: $points');
        
        // Add points to total
        _total += points;
        // Log the state change
        debugPrint('[ScoreManager::updateScore] New Total: $_total');
        
        // Log exit from method
        debugPrint('[ScoreManager::updateScore] Completed.');
    }
    ```
### C. IdleMan\project_summary2.0.md and IdleMan\project_summary2.0.md

  - **Update:** When pompted "Update it" means update project_summary2.0.md and project_summary2.0.md with all the successfull changes!
-----

## 3\. CORE PHILOSOPHY & ETHICS

  - **No Shaming:** Variable names and UI copy should never use words like "Fail," "Wasted," or "Addict." Use "Space," "Reclaimed," and "Pause."
  - **Local-First:** Notification content is processed locally. Never suggest sending raw user data to a cloud endpoint.
  - **Investment, Not Penalty:** Monetization logic is framed as "Commitment" or "Buying Space," not "Fines."

-----

## 4\. TECH STACK & ARCHITECTURE

  - **Framework:** Flutter 3.0+
  - **State Management:** Riverpod 2.0+ (Use `Notifiers`, avoid `StateProvider` for complex logic).
  - **Local Database:** Hive (NoSQL).
  - **Backend:** Firebase (Auth = Anonymous; Firestore = Shared Garden state).

### Directory Structure Enforcement

  - `lib/core/theme/`: Stores the `TherapyTheme` and color constants.
  - `lib/features/`: Feature-first architecture (e.g., `features/reflection`, `features/garden`).
  - `android/`: Kotlin Native code for `AccessibilityService` and `SystemAlertWindow`.

-----

## 5\. FORBIDDEN PATTERNS (DO NOT USE)

  - ❌ **Neumorphism:** No `NeuCard`, `NeuButton`, or complex shadow calculations.
  - ❌ **Aggressive Red:** Do not use bright red (\#FF0000) for errors. Use Muted Terra Cotta.
  - ❌ **Sparse Code:** Do not write "clean" code without comments. Verbosity is the requirement.


```
```