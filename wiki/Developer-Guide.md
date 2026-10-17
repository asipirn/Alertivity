# Developer guide

## Build

Use a current stable Xcode compatible with the project’s assets and host macOS. The documentation was checked with Xcode 27.0; older versions have not been verified. See [Getting started](https://github.com/nobbbbby/Alertivity/wiki/Getting-Started#choose-a-build) for platform requirements and target differences.

```sh
git clone https://github.com/nobbbbby/Alertivity.git
cd Alertivity
open Alertivity.xcodeproj
```

Select **Alertivity (Non-sandboxed)** for process features or **Alertivity** for the sandboxed target. Under **Signing & Capabilities**, select your Apple development team. Add your account through **Xcode → Settings → Accounts** if needed, then Run. To build from Terminal:

```sh
xcodebuild \
  -project Alertivity.xcodeproj \
  -scheme 'Alertivity (Non-sandboxed)' \
  -configuration Release \
  -destination 'platform=macOS' \
  build
```

For Terminal builds, add `DEVELOPMENT_TEAM=YOUR_TEAM_ID` to select your team.

## Tests

Run the Swift Testing and UI suites with:

```sh
xcodebuild \
  -project Alertivity.xcodeproj \
  -scheme 'Alertivity (Non-sandboxed)' \
  -testPlan Alertivity \
  -destination 'platform=macOS' \
  test
```

UI tests isolate app preferences and skip login registration. Onboarding coverage checks persisted outcomes, preference preservation, permission changes, explicit style application, and replay. Optional screenshots require `ALERTIVITY_CAPTURE_ONBOARDING=1` in the test-runner environment; capture can fail on secondary displays.

For layout review, open `Alertivity/OnboardingLayoutPreviews.swift` in Xcode Canvas. Its sample readings do not start monitoring or change preferences. Equal-width preview columns keep the center divider fixed as values change.

## Source files

| Behavior | Files in `Alertivity/` |
| --- | --- |
| Scenes, menu commands, login registration, indicator selection | `AlertivityApp.swift` |
| Sampling and process filtering | `SystemMetricsProvider.swift` |
| Sampling schedule and status transitions | `ActivityMonitor.swift` |
| Readings, severity, and explanations | `ActivityMetrics.swift`, `ActivityStatus.swift` |
| Threshold defaults and validation | `MonitoringPreferences.swift` |
| Persistence and onboarding outcome | `SettingsStore.swift` |
| Configuration and permission UI | `SettingsView.swift`, `NotificationPermissionView.swift` |
| Alert timing, shared cooldown, and actions | `NotificationManager.swift` |
| Process actions | `ProcessActions.swift` |
| Onboarding and previews | `OnboardingView.swift`, `OnboardingLayoutPreviews.swift` |
| Review qualification and presentation | `ReviewRequestStore.swift`, `ReviewSettingsView.swift` |
| Logging and translations | `AppLogger.swift`, `Localization.swift`, `Localizable.xcstrings` |

## Window and permission handling

Onboarding stores `pending`, `completed`, or `skipped`. Closing a pending guide records `skipped`; replay never resets preferences. An in-memory replay flag distinguishes a Help menu action from automatic scene creation. Window restoration is disabled for the guide, and an unsolicited restored guide dismisses before activation. The launch check runs once per process because SwiftUI can recreate menu labels.

Notification requests are serialized and refresh authorization first. Permission UI refreshes on app activation after external changes. Settings opens through native SwiftUI APIs; login registration uses `SMAppService`. System Settings opens by application bundle identifier with navigation guidance, avoiding undocumented pane URLs.

Use the existing OSLog categories for state changes and errors. Do not log sensitive process data. See [Design decisions](https://github.com/nobbbbby/Alertivity/wiki/Design-Decisions) and [Editing the wiki](https://github.com/nobbbbby/Alertivity/wiki/Maintaining-the-Wiki).

## Menu summaries

`ActivityStatus.menuSummary(for:)` formats the thresholds reached by the current readings. Notification wording uses separate strings. Localized list formatting and line wrapping handle multiple affected metrics. Formatting runs on every refresh and emits no logs; sampling and alert delivery use their existing log categories.
