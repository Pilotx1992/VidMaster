import 'package:flutter/material.dart';

import 'core/widgets/main_shell.dart';

/// Legacy entry widget kept for documentation parity.
///
/// The app uses `go_router` + `ShellRoute` (see `core/router/app_router.dart`),
/// so most flows don't need to reference this directly.
class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context) => MainShell(child: child);
}

