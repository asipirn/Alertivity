# Alertivity

**Your Mac’s vital signs, always visible.**

Alertivity monitors CPU, memory, disk, network, and process activity. It turns those signals into a simple **Normal**, **Elevated**, or **Critical** status so you can spot problems before they interrupt your work.

![Alertivity menu bar](img/menubar.png)

[![Download on the Mac App Store](img/appstore.svg)](https://apps.apple.com/app/alertivity/id6756399719)

## Highlights

- **At-a-glance health** — one clear status for your Mac
- **Live metrics** — CPU, memory, disk, and network activity
- **Smart menu bar icon** — show a chosen metric or automatically follow the busiest one
- **Useful alerts** — get notified when critical activity persists
- **Process insights** — identify, inspect, ignore, or terminate resource-heavy processes¹
- **Made for macOS** — launch at login, optional Dock icon, and a localized SwiftUI interface

¹ Process monitoring is available in the non-sandboxed build.

## Choose a Version

### Mac App Store

The sandboxed version provides system-wide health monitoring and critical-status notifications. Process-level monitoring is unavailable because of App Store sandbox restrictions.

[Download Alertivity from the Mac App Store](https://apps.apple.com/app/alertivity/id6756399719)

### Non-sandboxed

Build from source to unlock process-level activity, custom CPU and memory thresholds, ignored-process rules, and quick actions for Activity Monitor or force quit.

## Build from Source

Requirements: **macOS 14 (Sonoma) or later** and **Xcode 15 or later**.

1. Open `Alertivity.xcodeproj` in Xcode.
2. Select the **Alertivity (Non-sandboxed)** scheme.
3. Press **Run**.

Or build from Terminal:

```sh
xcodebuild \
  -scheme 'Alertivity (Non-sandboxed)' \
  -configuration Release \
  -destination 'platform=macOS' \
  build
```

## Getting Started

For layout review, open `Alertivity/OnboardingLayoutPreviews.swift` in Xcode Canvas. The selected horizontal layout is shown with CPU, network, and status readings to check the fixed center divider. These previews use sample metrics and do not start monitoring or change preferences.

On first launch, a two-step welcome window introduces the menu bar with a compact horizontal live metric preview, then offers optional notifications. Preview style choices do not change preferences until **Use This** is selected; Continue, Skip, and closing the guide never apply a preview selection. Applying a style saves immediately without changing auto switch. The apply button stays inside the preview card, at its natural size with its right edge aligned beneath the style picker. The compact preview uses native text and symbols with the same live values and formatting as the menu bar. Equal-width columns keep the middle divider fixed while the reading and selected style change. Step one places auto switch to the busiest critical metric under **More Options**, directly below the preview. Step two keeps notification setup, launch at login, and Settings separate. Auto switch changes apply immediately and persist; enabling it also enables metric icons. Finish with **Done**, or choose **Skip for Now**. Closing the window also skips it. Monitoring runs throughout, and permission is requested only after an explicit action. Denying notifications never blocks monitoring.

Reopen **Getting Started…** from **Help → Getting Started…**. Settings → Notifications shows current macOS authorization and guidance for restoring denied access. Preferences apply immediately; skipping or replaying the guide preserves them. The App Store guide focuses on overall system activity; source builds also point to process insights in the menu bar. Process-action permission handling stays with the relevant actions.

The design follows [Apple’s onboarding HIG](https://developer.apple.com/design/human-interface-guidelines/onboarding): brief, optional guidance, safe interaction before setup, deferred customization, and an easy way to revisit it. The permission request occurs only when people choose to set up alerts, following [Apple’s notification permission guidance](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications). General system instructions and process-action permissions stay with their relevant features instead of adding an onboarding step. Optional guidance lives in the Help menu, following [Apple’s offering-help guidance](https://developer.apple.com/design/human-interface-guidelines/offering-help); Settings contains preferences.

### Onboarding implementation (AL-73)

`SettingsStore` persists `app.onboarding.outcome` as `pending`, `completed`, or `skipped`. Missing or invalid values offer guidance once, including on the first launch after updating an older installation. Replaying the singleton welcome scene never resets existing thresholds or preferences. Closing a pending guide records `skipped`; completed and skipped installations do not automatically open it again. The launch check runs once per process to tolerate menu label recreation. A small `NSViewRepresentable` disables `NSWindow` restoration on macOS 14 and later. An explicit, non-persisted replay request distinguishes a menu action from automatic scene creation; completed or skipped guidance dismisses an unsolicited window before activation. The menu scene observes preference and metrics updates even while its indicator is hidden.

`NotificationManager` refreshes authorization before an explicit request, serializes concurrent requests, and publishes status and failures on the main actor. The shared permission view refreshes on app activation after System Settings changes. It opens the System Settings application using its bundle identifier and provides navigation instructions rather than relying on undocumented pane URLs. Login-item registration continues to use `SMAppService`; macOS may require approval in General → Login Items. Significant onboarding transitions and permission failures use the existing OSLog categories without recording user data.

## Privacy & Permissions

Alertivity monitors activity locally. Notifications require macOS authorization. Revealing a process in Activity Monitor may require Accessibility permission for System Events.

## Languages

English, German, French, Japanese, and Simplified Chinese.

## Development

Both app targets require macOS 14 or later. Debug and Release pin this minimum explicitly so Xcode updates do not change compatibility. This baseline supports native SwiftUI Settings access and modern login-item registration without older-system fallbacks.

App Store review requests use persisted usage milestones and conservative frequency limits. The standard Alertivity application menu includes a manual review link.

Onboarding coverage includes persisted outcomes and preference preservation, authorization denial and retry, external permission changes, and UI checks for completion, skip, close, the interactive preview, preference preservation while previewing, explicit style application and persistence across relaunch, restoring a hidden indicator, and replay from the Help menu. UI tests isolate app preferences and skip login-item registration. Optional onboarding screenshots require `ALERTIVITY_CAPTURE_ONBOARDING=1` in the test-runner environment because macOS window capture can fail on secondary displays.

Run the Swift Testing and UI test suites with:

```sh
xcodebuild \
  -project Alertivity.xcodeproj \
  -scheme 'Alertivity (Non-sandboxed)' \
  -testPlan Alertivity \
  -destination 'platform=macOS' \
  test
```
