# Flutter Shazam Kit
[![Version](https://img.shields.io/pub/v/flutter_shazam_kit?color=%23212121&label=Version&style=for-the-badge)](https://pub.dev/packages/flutter_shazam_kit)
[![Publisher](https://img.shields.io/pub/publisher/flutter_shazam_kit?color=E94560&style=for-the-badge)](https://pub.dev/publishers/sstonn.xyz)
[![Points](https://img.shields.io/pub/points/flutter_shazam_kit?color=FF9F29&style=for-the-badge)](https://pub.dev/packages/flutter_shazam_kit)
[![LINCENSE](https://img.shields.io/github/license/ssttonn/flutter_shazam_kit?color=0F3460&style=for-the-badge)](https://github.com/ssttonn/flutter_shazam_kit/blob/master/LICENSE)

<p align="center">
<img src="https://github.com/ssttonn/flutter_shazam_kit/blob/master/images/shazamkit_logo.png?raw=true" width="600"/>
</p>

A plugin that helps you detect songs through your device's microphone

Note: 

- This plugin depends on Apple's [ShazamKit](https://developer.apple.com/shazamkit/), requires IOS 15 or higher, and requires Android API level 23 (Android 6.0) or higher.
- In the early versions of this plugin, I only use `ShazamCatalog`, it was the default catalog used as library for music detection and I plan to implement `CustomCatalog` in the future.
<p align="center">
<img src="https://github.com/ssttonn/flutter_shazam_kit/blob/master/images/sample-flow.gif?raw=true" width="300"/>
</p>

## Configuration

### Android configuration

1. Add [android.permission.RECORD_AUDIO](https://developer.android.com/reference/android/Manifest.permission#RECORD_AUDIO) permission and [android.permission.INTERNET](https://developer.android.com/reference/android/Manifest.permission#INTERNET) permission  to your `AndroidManifest.xml`.

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<uses-permission android:name="android.permission.INTERNET"/>
```

2. Go to this [Download Page](https://developer.apple.com/download/all/?q=Android%20ShazamKit) and download the latest version of ShazamKit for Android, once you have downloaded it, create a new folder called `libs` inside your android’s `app` folder and place the `.aar` file inside that `libs` folder.

Your android project’s structure should look like this:

![Untitled](https://github.com/ssttonn/flutter_shazam_kit/blob/master/images/android-project-structure.png?raw=true)

3. Inside your app-level `build.gradle`, change `minSdkVersion` to 23 and sync your project again.

```groovy
minSdkVersion 23
```

4. In order to use `ShazamCatalog` on Android, you need to have an Apple Developer Token to access ShazamKit service provided by Apple, please follow this [link](https://help.apple.com/developer-account/#/deva27624586) for more details.
    
    If you don’t know how to do that, please follow those steps below:
    
    1/ Create a media identifier
    
    - Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources), click Identifiers in the sidebar.
    - On the top left, click the add button (+), select **Media IDs**, then click **Continue**.
    - Enter description and identifier for the Media ID, then enable ShazamKit and click Continue.
    
    ![Untitled](https://github.com/ssttonn/flutter_shazam_kit/blob/master/images/music-services-android.png?raw=true)
    
    - Click Register and you should see new Media ID in identifier list.
    
    2/ Create a private key (`.p8`)
    
    - Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources), click Keys in the sidebar.
    - On the top left, click the add button (+), then enter your key name.
    - Enable **Media Services (MusicKit, ShazamKit)** checkbox, the click Configure button on the right.
    
    ![Untitled](https://github.com/ssttonn/flutter_shazam_kit/blob/master/images/media-id-android.png?raw=true)
    
    - Select the Media ID you created earlier and click Save.
    
    ![Untitled](https://github.com/ssttonn/flutter_shazam_kit/blob/master/images/media-id.png?raw=true)
    
    - Click Continue and then click Register.
    - Download the private key (`.p8` file) and remember your Key ID.
    
    ![Untitled](https://github.com/ssttonn/flutter_shazam_kit/blob/master/images/private-key-android.png?raw=true)
    
    3/ Generate a Developer Token
    
    - Please refer to this [link](https://developer.apple.com/documentation/applemusicapi/generating_developer_tokens) to learn how to generate a developer token.
    - Due to apple policy, Developer Token can only be valid for up to 6 months. So you should have a remote place to store and refresh your Developer Token once it is generated, you can either use a Backend Server or an alternative solution like [Firebase Remote Config](https://firebase.google.com/products/remote-config?gclid=Cj0KCQjw1bqZBhDXARIsANTjCPLa35qab-Sc8xEPfTHU2wZ3g46jJqkwgvtHrEy_11v4N280KrTyfxgaAhwCEALw_wcB&gclsrc=aw.ds) or something similar to store, generate and refresh your Developer Token.
    - For testing purposes you can use the following Node JS snippet or you can use [my repository](https://github.com/ssttonn/nodewebtoken) to create it.
        
        Note: This code snippet use the famous [jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken) library so you need to install this library first before using this code snippet.
        
    ```js
    "use strict";
    const fs = require("fs");
    const jwt = require("jsonwebtoken");
    
    const privateKey = fs.readFileSync("<YOUR_P8_FILE_NAME>.p8").toString();
    const teamId = "<YOUR_TEAM_ID>";
    const keyId = "<YOUR_KEY_ID>";
    const jwtToken = jwt.sign({}, privateKey, {
        algorithm: "ES256",
        issuer: teamId,
        expiresIn: "180d", // due to apple policy, developer key can only valid for 180 days
        header: {
            alg: "ES256",
            kid: keyId,
            typ: "JWT"
        }
    });
    
    console.log(jwtToken);
    ```
    

### IOS configuration

1. Add [Privacy - Microphone Usage Description](https://developer.apple.com/documentation/bundleresources/information_property_list/nsmicrophoneusagedescription) permission to your `Info.plist`.

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Need microphone access for detecting musics</string>
```

2. Update your `Podfile` global IOS platform to IOS 15.0

```
# Uncomment this line to define a global platform for your project
platform :ios, '15.0'
```

3. Register new App ID
    - Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources), click Identifiers in the sidebar.
    - On the top left, click the add button (+), select ****App IDs****, then click **Continue**.
    - Select **App** type for this identifier, then click **Continue**.
    - Fill out description and Bundle ID (must be your App Bundle ID), switch to **App Services** tab and enable **ShazamKit** service, the click **Continue**.
    - Click **Register** button to register new App ID**.**
    - You should see your new App ID in Identifier list.

## How to use
### Initialize

Initialization configuration

```dart
final _flutterShazamKitPlugin = FlutterShazamKit();

@override
void initState() {
  super.initState();
  _flutterShazamKitPlugin
      .configureShazamKitSession(developerToken: developerToken);
}

@override
void dispose() {
  super.dispose();
  _flutterShazamKitPlugin.endSession();
}
```

Listen for the matching event

```dart
_flutterShazamKitPlugin.matchResultDiscoveredStream.listen((result) {
  if (result is Matched) {
    print(result.mediaItems);
  } else if (result is NoMatch) {
    // do something in no match case
  }
});
```

Listen for detecting state changed

```dart
_flutterShazamKitPlugin.detectStateChangedStream.listen((state) {
  print(state);
});
```

Listen for errors

```dart
_flutterShazamKitPlugin.errorStream.listen((error) {
  print(error.message);
});
```

### Detect by microphone

Starting to detect by microphone

```dart
_flutterShazamKitPlugin.startDetectingByMicrophone();
```

End detect

```dart
_flutterShazamKitPlugin.endDetecting();
```

See the `main.dart` in the `example` folder for a complete example.
