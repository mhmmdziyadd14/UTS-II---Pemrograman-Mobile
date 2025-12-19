Patch flutter_qiblah plugin (add Android namespace)
=================================

Two options: manual edit in pub cache (quick) or use the included PowerShell script to automate.

Automated (recommended for this quick fix):

1. Open a PowerShell in your project folder (no admin required):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\patch_flutter_qiblah.ps1
```

2. If the script reports success, run:

```bash
flutter clean
flutter pub get
flutter run
```

Manual alternative:

1. Open the plugin manifest in the pub cache:
   `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\flutter_qiblah-*/android/src/main/AndroidManifest.xml`
2. Copy the `package="..."` value.
3. Open `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\flutter_qiblah-*/android/build.gradle` and inside the `android {` block add:

```gradle
    namespace 'the.package.you.copied'
```

4. Save, then run `flutter clean` / `flutter pub get` / `flutter run` in your project.

Notes:
- Editing pub cache is temporary; it can be overwritten by later pub commands.
- For a permanent fix, copy the plugin into your project and use a `path:` dependency in `pubspec.yaml`.
