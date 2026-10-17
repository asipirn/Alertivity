# Troubleshooting

| Problem | Check |
| --- | --- |
| Menu bar indicator is missing | Reopen Alertivity. In [Menu bar settings](https://github.com/nobbbbby/Alertivity/wiki/Settings#menu-bar), enable Show indicator and disable Only show on high activity. A hidden Dock icon does not mean the app has quit. |
| No notifications | Follow the [notification setup paths](https://github.com/nobbbbby/Alertivity/wiki/Settings#notifications), check Focus and the selected Cooldown, then check [when alerts are sent](https://github.com/nobbbbby/Alertivity/wiki/Notifications-and-Permissions#when-alerts-are-sent). |
| Detection or processes are missing | See [checks below](https://github.com/nobbbbby/Alertivity/wiki/Troubleshooting#detection-or-processes-are-missing). |
| Readings differ from Activity Monitor | Compare intervals and units using [reading limitations](https://github.com/nobbbbby/Alertivity/wiki/Metrics-and-Status#reading-limitations). |
| Activity Monitor opens without finding a process | See [permission checks below](https://github.com/nobbbbby/Alertivity/wiki/Troubleshooting#activity-monitor-opens-without-finding-the-process). |
| Launch at login fails | Follow the [General settings paths](https://github.com/nobbbbby/Alertivity/wiki/Settings#general). If registration fails, Alertivity refreshes its toggle to the system state. |
| Welcome guide or settings differ | Compare the installed build with the [version note on Home](https://github.com/nobbbbby/Alertivity/wiki/Home). Reopen onboarding using the [first-launch instructions](https://github.com/nobbbbby/Alertivity/wiki/Getting-Started#first-launch). |

## Detection or processes are missing

Check the [build variant](https://github.com/nobbbbby/Alertivity/wiki/Getting-Started#choose-a-build), check [Detection settings](https://github.com/nobbbbby/Alertivity/wiki/Settings#process-detection-and-whitelist), and wait for activity to remain above the limits for the selected duration. Check whether disk is the selected trigger, which hides the process section. Inspect logs if process sampling fails. Accessibility approval does not unlock process sampling in the sandboxed target.

## Activity Monitor opens without finding the process

Open **Apple menu → System Settings → Privacy & Security → Accessibility**, and separately **Privacy & Security → Automation**, to check access for Alertivity and System Events. Grant any requested permission, then retry. Section names can vary by macOS version. Search manually in Activity Monitor if UI automation fails or the sampled process has exited.

## Report a problem

Use the [repository issue tracker](https://github.com/nobbbbby/Alertivity/issues). Include the app version/build variant, macOS version, steps to reproduce, what you expected, what happened, and relevant settings. Include the commit ID if you built from source.

In Console.app, filter by subsystem `com.Nobby.Alertivity` (sandboxed) or `com.Nobby.Alertivity.standalone` (source build), with categories `lifecycle`, `metrics`, `notifications`, or `reviews`. Review logs and screenshots before sharing; remove private process paths and unrelated personal information.
