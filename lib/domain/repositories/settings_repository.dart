abstract class SettingsRepository {
  // Audio Quality
  Future<String> getAudioQuality();
  Future<void> setAudioQuality(String quality);
  
  // Downloads
  Future<bool> getDownloadOnlyWifi();
  Future<void> setDownloadOnlyWifi(bool enabled);
  
  // Theme
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode);
  
  Future<String> getAccentColor();
  Future<void> setAccentColor(String hexColor);
  
  // Playback
  Future<bool> getAnimationsEnabled();
  Future<void> setAnimationsEnabled(bool enabled);
  
  Future<bool> getCrossfadeEnabled();
  Future<void> setCrossfadeEnabled(bool enabled);
}
