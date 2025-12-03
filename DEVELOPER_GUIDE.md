# IdleMan - Developer Documentation

## Project Overview

IdleMan is an Android application built with Flutter that helps users manage compulsive app usage through tactile "Kinetic Neumorphism" based cognitive friction tasks. The app monitors specified applications using Android's AccessibilityService and displays interactive overlays when blocked apps are launched.

## Architecture

### Hybrid Architecture
- **Flutter Layer**: Handles all UI/UX, state management, and user interactions
- **Kotlin Native Layer**: Manages AccessibilityService, overlay windows, and system-level operations
- **Communication**: MethodChannel bridges Flutter and Kotlin

### Key Components

#### 1. Flutter Layer (lib/)

**Core**
- `theme/`: Theme system with Day/Night mode support
  - `neu_theme.dart`: Theme data model with neumorphic shadow calculations
  - `theme_provider.dart`: Riverpod notifier for theme state management
- `constants/`: App-wide constants and strings
- `services/`: Native communication service
- `providers/`: State management with Riverpod
  - `blocklist_provider.dart`: Manages blocked apps list
  - `stats_provider.dart`: Tracks usage statistics

**Features**
- `onboarding/`: Multi-step onboarding flow with zoom-out transitions
- `dashboard/`: Main home screen with stats
- `settings/`: Configuration and app management
- `overlays/`: Cognitive friction task screens
  - `bureaucrat_overlay.dart`: Form-based verification task
  - `chase_overlay.dart`: Interactive tap game

**Widgets**
- `neumorphic/`: Reusable neumorphic design components
  - `neu_card.dart`: Pop-out and pressed-in card containers
  - `neu_button.dart`: Tactile button with jelly animation
  - `neu_input.dart`: Pressed-in input fields
  - `neu_toggle.dart`: Animated toggle switch
  - `neu_background.dart`: Themed background container

#### 2. Kotlin Native Layer (android/)

**Services**
- `AppMonitorService.kt`: AccessibilityService that monitors app launches
  - Detects TYPE_WINDOW_STATE_CHANGED events
  - Maintains blocklist of package names
  - Triggers overlay when blocked app is detected

**Activities**
- `MainActivity.kt`: Main entry point
  - Sets up MethodChannels for Flutter communication
  - Handles permission requests
  - Provides installed apps list
- `OverlayActivity.kt`: Displays Flutter overlays
  - Configures as system alert window
  - Randomly selects friction task type
  - Returns to home on dismissal

## Design System: Kinetic Neumorphism

### Core Principles
1. **Soft Shapes**: High border radius on all elements (cards: 30px, buttons: 20px, inputs: 12px)
2. **Consistent Lighting**: Top-left light source for all shadows
3. **Tactile Depth**: 
   - Pop-out: Light shadow top-left, dark shadow bottom-right
   - Pressed-in: Inner shadows with inverted direction
4. **Ambient Motion**: (Removed)
5. **Kinetic Feedback**: Jelly bounce animations on tap with haptic feedback

### Theme System

**Day Mode**
- Background: `#E0E5EC` (Light Grey)
- Text: `#4D4D4D` (Dark Grey)
- Shadow Light: `#FFFFFF` (White)
- Shadow Dark: `#A3B1C6` (Medium Grey)
- Accent: `#6C63FF` (Purple)

**Night Mode**
- Background: `#292D32` (Dark Charcoal)
- Text: `#E0E5EC` (Light Grey)
- Shadow Light: `#353B41` (Lighter Grey)
- Shadow Dark: `#1E2226` (Near Black)
- Accent: `#9D96FF` (Light Purple)

### Animation Constants
- Fast: 200ms (button press)
- Medium: 350ms (transitions)
- Slow: 500ms (breathing effects)
- Jelly scale: 0.95 → 1.05 with elastic easing

## State Management

### Riverpod Providers

**themeProvider**
- Manages current theme (Day/Night)
- Persists preference in Hive
- Provides toggle and setter methods

**blocklistProvider**
- List of installed apps with block status
- Syncs with Hive for persistence
- Communicates blocked packages to native layer
- Provides toggle, block, and unblock methods

**statsProvider**
- Tracks daily interruption count
- Calculates time saved and improvement metrics
- Resets daily at midnight
- Records each interruption event

## Local Storage (Hive)

### Boxes
1. **themeBox**: Theme preferences
   - Key: `themeMode` (String: "day" or "night")

2. **blocklistBox**: Blocked apps
   - Key: `blockedApps` (List<String> of package names)

3. **statsBox**: Daily statistics
   - Key: `interruptions` (int)
   - Key: `lastReset` (int timestamp)

## Native Communication

### MethodChannel: `com.idleman/native`

**Methods from Flutter → Kotlin**
- `checkAccessibilityPermission()`: Returns bool
- `requestAccessibilityPermission()`: Opens settings
- `checkOverlayPermission()`: Returns bool
- `requestOverlayPermission()`: Opens settings
- `updateBlockedApps(packages)`: Syncs blocklist
- `getInstalledApps()`: Returns list of installed apps

**Methods from Kotlin → Flutter**
- `appBlocked(packageName, timestamp)`: Notifies when blocked app launched

## Permission Requirements

### Critical Permissions
1. **BIND_ACCESSIBILITY_SERVICE**: Monitor app launches
2. **SYSTEM_ALERT_WINDOW**: Display overlays over apps

### Implementation
- Both requested during onboarding
- Checked before enabling monitoring
- Deep links to system settings for manual grant

## Overlay System

### Flow
1. User launches blocked app
2. `AppMonitorService` detects package name via AccessibilityEvent
3. Service starts `OverlayActivity` with FLAG_ACTIVITY_NEW_TASK
4. Activity creates full-screen window with blur backdrop
5. Flutter renders friction task (Bureaucrat or Chase)
6. On completion, overlay closes and returns user to home screen

### Friction Tasks

**Bureaucrat** (Form-based)
- Fields: Reason (text), Duration (number), Code (text)
- Validation: All fields required, code must be "IDLE"
- Failure: Shake animation + haptic feedback
- Success: Overlay dismisses

**Chase** (Game-based)
- Target: Tap button 100 times
- Behavior: Button teleports to random position on each tap
- Feedback: Haptic on each tap, strong on completion
- Success: Auto-dismiss at 100 taps

## Building & Running

### Prerequisites
```bash
flutter --version  # 3.0.0+
flutter doctor     # Ensure Android toolchain is ready
```

### Development
```bash
flutter pub get
flutter run
```

### Release Build
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Testing

### Manual Test Checklist
- [ ] Theme toggle works correctly
  <!-- Splash screen removed -->
- [ ] Onboarding zoom transition smooth
- [ ] Dashboard shows live stats
- [ ] Settings lists installed apps
- [ ] Toggle apps in blocklist
- [ ] Accessibility permission requested
- [ ] Overlay permission requested
- [ ] Bureaucrat overlay appears on blocked app
- [ ] Chase overlay appears on blocked app
- [ ] Form validation works
- [ ] Button teleports correctly
- [ ] Haptic feedback triggers
- [ ] Overlay closes properly
- [ ] Stats increment on interruption

## Known Limitations

1. **Accessibility Service**: May be killed by aggressive battery optimization
2. **Overlay Drawing**: Some OEMs restrict overlay permissions
3. **App Detection**: Can only detect apps after they start, not prevent launch
4. **Fonts**: Nunito font files need to be added to `assets/fonts/`
5. **Icons**: App icon needs to be created for all densities

## Future Enhancements

### Phase 2
- [ ] Schedule-based blocking (time windows)
- [ ] Usage analytics and trends
- [ ] Multiple friction task types
- [ ] Customizable difficulty levels
- [ ] Export/import blocklist

### Phase 3
- [ ] Widget for quick stats
- [ ] Notification-based monitoring
- [ ] Cloud backup of preferences
- [ ] Social features (accountability partners)

## Troubleshooting

### Accessibility Service Not Working
1. Verify permission granted in Settings → Accessibility
2. Check if service is running: `adb shell dumpsys accessibility`
3. Restart device if service won't start

### Overlays Not Appearing
1. Check SYSTEM_ALERT_WINDOW permission granted
2. Verify app is not in battery optimization whitelist
3. Test on different OEM (some restrict overlays)

### Theme Not Persisting
1. Verify Hive initialization in main()
2. Check app data not being cleared
3. Debug with `flutter logs`

## Code Style

### Flutter/Dart
- Follow official Dart style guide
- Use `const` constructors wherever possible
- Prefer composition over inheritance
- Keep widgets small and focused
- Use named parameters for clarity

### Kotlin
- Follow official Kotlin conventions
- Use nullable types appropriately
- Prefer data classes for models
- Keep services lightweight

## Contact & Support

For issues, feature requests, or contributions, please create an issue in the repository.

---

**Last Updated**: November 23, 2025
**Version**: 1.0.0
                                                                                                                      
