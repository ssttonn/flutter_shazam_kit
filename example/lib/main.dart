import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shazam_kit/flutter_shazam_kit.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

const developerToken =
    "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjNGVjc1SFBRQ0sifQ.eyJpYXQiOjE2NjQ2ODgxNTYsImV4cCI6MTY4MDI0MDE1NiwiaXNzIjoiN1ZINlUyMlNWQiJ9._XCTaksMmYKi7vtxp7LaBgwYW4TnmBJlN1bk9pgPBkWd1xnMNmqQorruHeUtZWVrOXsWIpStiFGqAZZrIsulTg"; //use for android only

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterShazamKitPlugin = FlutterShazamKit();
  DetectState _state = DetectState.none;
  final List<MediaItem> _mediaItems = [];

  @override
  void initState() {
    super.initState();
    _flutterShazamKitPlugin
        .configureShazamKitSession(developerToken: developerToken)
        .then((value) {
      _flutterShazamKitPlugin.onMatchResultDiscovered((result) {
        if (result is Matched) {
          setState(() {
            _mediaItems.insertAll(0, result.mediaItems);
          });
        } else if (result is NoMatch) {
          // do something in no match case
        }
        _flutterShazamKitPlugin.endDetectionWithMicrophone();
      });
      _flutterShazamKitPlugin.onDetectStateChanged((state) {
        setState(() {
          _state = state;
        });
      });
      _flutterShazamKitPlugin.onError((error) {
        print(error.message);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _flutterShazamKitPlugin.endSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _body());
  }

  Widget _body() {
    final theme = Theme.of(context);
    return Column(
      children: [_detectButton(theme), Expanded(child: _detectedItems(theme))],
    );
  }

  Widget _detectButton(ThemeData theme) {
    return CupertinoButton(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_state == DetectState.none ? "Start Detect" : "End Detect",
                  style:
                      theme.textTheme.headline6?.copyWith(color: Colors.white)),
              if (_state == DetectState.detecting) ...[
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
          if (this._state != DetectState.none) {
            endDetect();
            return;
          }
          showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                'Detect from',
                style: theme.textTheme.subtitle1,
              ),
              actions: <CupertinoActionSheetAction>[
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    startDetect();
                  },
                  child: const Text('Microphone'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(context);
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      File file = File(result.files.single.path ?? "");
                      _flutterShazamKitPlugin
                          .startDetectionWithAudioFile(file)
                          .then((value) {
                        print("Finished");
                      });
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: const Text('Audio file'),
                ),
              ],
            ),
          );
        });
  }

  Widget _detectedItems(ThemeData theme) {
    return ListView.builder(
        itemCount: _mediaItems.length,
        shrinkWrap: true,
        itemBuilder: ((context, index) {
          MediaItem item = _mediaItems[index];
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

  startDetect() {
    _flutterShazamKitPlugin.startDetectionWithMicrophone();
  }

  endDetect() {
    _flutterShazamKitPlugin.endDetectionWithMicrophone();
  }
}
