//===----------------------------------------------------------------------===//
//
// This source file is part of the LiveVoice SDK project
//
// Copyright (c) LiveVoice GmbH
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import 'package:flutter/material.dart';
import 'package:livevoice_sdk_flutter/livevoice_sdk_flutter.dart';

import 'screens/home_screen.dart';
import 'shared/demo_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the SDK once. On Android this also configures the foreground
  // service used while audio is playing; it is ignored on iOS.
  await initialize(
    androidServiceConfig: const LiveVoiceServiceEnabled(
      message: 'Channel %s is playing!',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Owns the selected API key preset for the lifetime of the app and joins the
  // demo event on launch.
  final DemoSession _session = DemoSession()..restoreCustomCredentials();

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoSessionScope(
      session: _session,
      child: MaterialApp(
        title: 'LiveVoice SDK',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.light),
        darkTheme: ThemeData(brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
