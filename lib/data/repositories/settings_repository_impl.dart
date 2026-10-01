import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  Box get _settingsBox => Hive.box('settings');

  @override
  Future<String> getAudioQuality() async {
    return _settingsBox.get('audioQuality', defaultValue: 'High') as String;
  }

  @override
  Future<void> setAudioQuality(String quality) async {
    await _settingsBox.put('audioQuality', quality);
  }

  @override
  Future<bool> getDownloadOnlyWifi() async {
    return _settingsBox.get('downloadOnlyWifi', defaultValue: true) as bool;
  }

  @override
  Future<void> setDownloadOnlyWifi(bool enabled) async {
    await _settingsBox.put('downloadOnlyWifi', enabled);
  }

  @override
  Future<String> getThemeMode() async {
    return _settingsBox.get('themeMode', defaultValue: 'system') as String;
  }

  @override
  Future<void> setThemeMode(String mode) async {
    await _settingsBox.put('themeMode', mode);
  }

  @override
  Future<String> getAccentColor() async {
    return _settingsBox.get('accentColor', defaultValue: '#A8B545') as String;
  }

  @override
  Future<void> setAccentColor(String hexColor) async {
    await _settingsBox.put('accentColor', hexColor);
  }

  @override
  Future<bool> getAnimationsEnabled() async {
    return _settingsBox.get('animationsEnabled', defaultValue: true) as bool;
  }

  @override
  Future<void> setAnimationsEnabled(bool enabled) async {
    await _settingsBox.put('animationsEnabled', enabled);
  }

  @override
  Future<bool> getCrossfadeEnabled() async {
    return _settingsBox.get('crossfadeEnabled', defaultValue: false) as bool;
  }

  @override
  Future<void> setCrossfadeEnabled(bool enabled) async {
    await _settingsBox.put('crossfadeEnabled', enabled);
  }
}
