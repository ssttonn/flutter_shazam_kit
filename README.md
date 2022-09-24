# Flutter Shazam Kit

![shazamkit_logo.png](https://ibb.co/W6x3zvh)

A plugin that helps you detect songs through your device's microphone

Note: This plugin depends on Apple's ShazamKit, requires IOS 15 or higher, and requires Android API level 23 (Android 6.0) or higher.

## Configuration

### Android configuration

1. Add [android.permission.RECORD_AUDIO](https://developer.android.com/reference/android/Manifest.permission#RECORD_AUDIO) permission to your `AndroidManifest.xml`.

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

1. Go to this [Download Page](https://developer.apple.com/download/all/?q=Android%20ShazamKit) and download the latest version of ShazamKit for Android, once you have downloaded it, create a new folder called `libs` inside your android’s `app` folder and place the `.aar` file inside that `libs` folder.

Your android project’s structure should look like this:

![Untitled](Flutter%20Shazam%20Kit%20e81251fe359048b281336714e94e0cfa/Untitled.png)

1. Inside your app-level `build.gradle`, change `minSdkVersion` to 23 and sync your project again.

```groovy
minSdkVersion 23
```

1.
