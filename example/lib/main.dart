import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_shazam_kit/flutter_shazam_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterShazamKitPlugin = FlutterShazamKit();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FutureBuilder<bool>(
            future: _flutterShazamKitPlugin.isShazamKitAvailable(),
            builder: ((context, snapshot) {
              return Column(
                children: [
                  CupertinoButton(
                      child: Text("Start recording"),
                      onPressed: () {
                        _flutterShazamKitPlugin.startRecording();
                      }),
                  CupertinoButton(
                      child: Text("End recording"),
                      onPressed: () {
                        _flutterShazamKitPlugin.endRecording();
                      })
                ],
              );
            })),
      ),
    );
  }
}
