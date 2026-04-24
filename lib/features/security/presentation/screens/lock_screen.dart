// ─────────────────────────────────────────────────
// Lock Screen
// ─────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Auto-trigger biometric on open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appAuthProvider.notifier).authenticateWithBiometric();
    });

    // Listen for successful auth and navigate away.
    ref.listenManual(appAuthProvider, (_, state) {
      if (state.screenStatus == AuthScreenStatus.authenticated) {
        context.go(AppRoutes.videos);
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appAuthProvider);
    final notifier = ref.read(appAuthProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 64, color: Color(0xFF1565C0)),
                const SizedBox(height: 24),
                const Text(
                  'VidMaster',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your PIN to continue',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 40),

                // PIN field
                TextField(
                  controller: _pinController,
                  obscureText: _obscure,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: '● ● ● ●',
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white38,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  onSubmitted: (pin) => notifier.authenticateWithPin(pin),
                ),

                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                // Confirm button
                FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () => notifier
                          .authenticateWithPin(_pinController.text),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Unlock'),
                ),

                const SizedBox(height: 16),

                // Biometric retry
                TextButton.icon(
                  onPressed: notifier.authenticateWithBiometric,
                  icon: const Icon(Icons.fingerprint,
                      color: Color(0xFFF9A825)),
                  label: const Text(
                    'Use biometrics',
                    style: TextStyle(color: Color(0xFFF9A825)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
