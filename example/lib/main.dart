import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shazam_kit/flutter_shazam_kit.dart';

void main() {
  runApp(const MyApp());
}

const developerToken = "<YOUR_DEVELOPER_TOKEN>"; //use for android only

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterShazamKitPlugin = FlutterShazamKit();
  final List<MediaItem> _mediaItems = [];
  StreamSubscription? _errorSubscription;

  @override
  void initState() {
    super.initState();
    _flutterShazamKitPlugin.configureShazamKitSession(
        developerToken: developerToken);
    _errorSubscription = _flutterShazamKitPlugin.errorStream.listen((error) {
      print(error.message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _flutterShazamKitPlugin.endSession();
    _errorSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: _body()),
    );
  }

  Widget _body() {
    final theme = Theme.of(context);
    return Column(
      children: [
        StreamBuilder<DetectState>(
          stream: _flutterShazamKitPlugin.detectStateChangedStream,
          builder: (context, snapshot) {
            final state = snapshot.data ?? DetectState.none;
            return _detectButton(state, theme);
          }
        ),
        Expanded(
          child: StreamBuilder<MatchResult>(
            stream: _flutterShazamKitPlugin.matchResultDiscoveredStream,
            builder: (context, snapshot) {
              final result = snapshot.data;
              if (result is Matched) {
                _mediaItems.insertAll(0, result.mediaItems);
              } else if (result is NoMatch) {
                // do something in no match case
              }
              if (snapshot.hasData) {
                _flutterShazamKitPlugin.endDetectionWithMicrophone();
              }

              return _detectedItems(_mediaItems, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _detectButton(DetectState state, ThemeData theme) {
    return CupertinoButton(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state == DetectState.none ? "Start Detect" : "End Detect",
                  style:
                      theme.textTheme.headline6?.copyWith(color: Colors.white)),
              if (state == DetectState.detecting) ...[
                const SizedBox(width: 10),
                const SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              ]
            ],
          ),
        ),
        onPressed: () async {
          if (state == DetectState.detecting) {
            endDetect();
          } else {
            startDetect();
          }
        });
  }

  Widget _detectedItems(List<MediaItem> mediaItems, ThemeData theme) {
    return ListView.builder(
        itemCount: mediaItems.length,
        shrinkWrap: true,
        itemBuilder: ((context, index) {
          MediaItem item = mediaItems[index];
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFF5f5f5),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  height: 100,
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      item.artworkUrl,
                      height: 150.0,
                      width: 100.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(item.title,
                            style: theme.textTheme.subtitle1
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text("Artist: ${item.artist}",
                            style: theme.textTheme.subtitle2
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text("Genres: ${item.genres.join(", ")}",
                            style: theme.textTheme.subtitle2
                                ?.copyWith(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }));
  }

  void startDetect() {
    _flutterShazamKitPlugin.startDetectionWithMicrophone();
  }

  void endDetect() {
    _flutterShazamKitPlugin.endDetectionWithMicrophone();
  }
}
