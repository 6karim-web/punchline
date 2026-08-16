#!/usr/bin/env python3
"""Re-applies our Android configuration after `flutter create` regenerates it.

The CI regenerates android/ from scratch on every build, which wipes any
manual edit. Everything the app needs from the platform lives here instead,
so it survives. Idempotent: safe to run twice.
"""
import re
import sys
from pathlib import Path

MANIFEST = Path("android/app/src/main/AndroidManifest.xml")
GRADLE_KTS = Path("android/app/build.gradle.kts")
GRADLE = Path("android/app/build.gradle")

PERMISSIONS = [
    "android.permission.INTERNET",
    "android.permission.POST_NOTIFICATIONS",
    "android.permission.VIBRATE",
    "android.permission.RECEIVE_BOOT_COMPLETED",
    "android.permission.SCHEDULE_EXACT_ALARM",
    "android.permission.USE_EXACT_ALARM",
]

# Receivers required by flutter_local_notifications for alarms that must
# survive a reboot — without them every scheduled prayer is lost on restart.
RECEIVERS = """
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
"""


def patch_gradle() -> None:
    """flutter_local_notifications needs Java 8 desugaring or the build fails
    outright. Both Gradle dialects are handled because `flutter create` has
    switched between them across versions."""
    if GRADLE_KTS.exists():
        g = GRADLE_KTS.read_text(encoding="utf-8")
        if "isCoreLibraryDesugaringEnabled" not in g:
            g = g.replace(
                "compileOptions {",
                "compileOptions {\n        isCoreLibraryDesugaringEnabled = true",
                1,
            )
            g += (
                "\n\ndependencies {\n"
                '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n'
                "}\n"
            )
            GRADLE_KTS.write_text(g, encoding="utf-8")
            print("patched build.gradle.kts for desugaring")
        return

    if GRADLE.exists():
        g = GRADLE.read_text(encoding="utf-8")
        if "coreLibraryDesugaringEnabled" not in g:
            g = g.replace(
                "compileOptions {",
                "compileOptions {\n        coreLibraryDesugaringEnabled true",
                1,
            )
            g += (
                "\ndependencies {\n"
                "    coreLibraryDesugaring "
                "'com.android.tools:desugar_jdk_libs:2.1.4'\n"
                "}\n"
            )
            GRADLE.write_text(g, encoding="utf-8")
            print("patched build.gradle for desugaring")


def main() -> int:
    if not MANIFEST.exists():
        print(f"manifest not found at {MANIFEST}", file=sys.stderr)
        return 1

    xml = MANIFEST.read_text(encoding="utf-8")

    missing = [p for p in PERMISSIONS if f'"{p}"' not in xml]
    if missing:
        block = "\n".join(
            f'    <uses-permission android:name="{p}" />' for p in missing
        )
        xml = xml.replace("<manifest", "<manifest", 1)
        xml = re.sub(r"(<manifest[^>]*>)", r"\1\n" + block, xml, count=1)
        print(f"added {len(missing)} permissions")

    if "ScheduledNotificationBootReceiver" not in xml:
        xml = xml.replace("</application>", RECEIVERS + "    </application>", 1)
        print("added notification receivers")

    # A launcher label that reads as a product, not a package name.
    xml = re.sub(r'android:label="[^"]*"', 'android:label="Punchline"', xml,
                 count=1)

    MANIFEST.write_text(xml, encoding="utf-8")
    print("manifest patched")
    patch_gradle()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
