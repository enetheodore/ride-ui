import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:pip_view/pip_view.dart';
import 'package:floating/floating.dart';

class ProfileSetUpScreen extends StatefulWidget {
  const ProfileSetUpScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetUpScreen> createState() => _ProfileSetUpScreenState();
}

class _ProfileSetUpScreenState extends State<ProfileSetUpScreen>
    with WidgetsBindingObserver {
  late Floating floating;
  bool _appIsMinimized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    floating = Floating();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    floating.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.inactive) {
      floating.enable(aspectRatio: Rational.square());
    }
  }

  Future<void> enablePip(BuildContext context) async {
    final rational = Rational.landscape();
    final screenSize =
        MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
    final height = screenSize.width ~/ rational.aspectRatio;

    final status = await floating.enable(
      aspectRatio: rational,
      sourceRectHint: Rectangle<int>(
        0,
        (screenSize.height ~/ 2) - (height ~/ 2),
        screenSize.width.toInt(),
        height,
      ),
    );
    debugPrint('PiP enabled? $status');
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.dark(),
        home: PiPSwitcher(
          childWhenDisabled: Scaffold(
            body: Center(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'First Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            )),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FutureBuilder<bool>(
              future: floating.isPipAvailable,
              initialData: false,
              builder: (context, snapshot) => snapshot.data ?? false
                  ? FloatingActionButton.extended(
                      onPressed: () => enablePip(context),
                      label: const Text('Enable PiP'),
                      icon: const Icon(Icons.picture_in_picture),
                    )
                  : const Card(
                      child: Text('PiP unavailable'),
                    ),
            ),
          ),
          childWhenEnabled: Image.asset('assets/image.jpg'),
        ),
      );
}
