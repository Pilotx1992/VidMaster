import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidmaster/features/settings/presentation/providers/settings_provider.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
  });

  group('SettingsNotifier', () {
    test('should initialize with default values if no prefs exist', () {
      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(() => mockPrefs.getInt(any())).thenReturn(null);
      when(() => mockPrefs.getBool(any())).thenReturn(null);
      
      final notifier = SettingsNotifier(mockPrefs);
      final state = notifier.currentState;

      expect(state.themeMode, ThemeMode.dark);
      expect(state.locale, 'ar');
    });

    test('setThemeMode should update state and persist', () async {
      when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
      
      final notifier = SettingsNotifier(mockPrefs);
      notifier.setThemeMode(ThemeMode.light);

      expect(notifier.currentState.themeMode, ThemeMode.light);
      verify(() => mockPrefs.setInt('themeMode', ThemeMode.light.index)).called(1);
    });
  });
}

extension SettingsNotifierTestX on SettingsNotifier {
  AppSettings get currentState => state;
}
