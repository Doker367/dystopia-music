import 'package:hive_flutter/hive_flutter.dart';
import '../constants/storage_constants.dart';

class StorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Note: Type adapters should be registered here before opening boxes
    // e.g. Hive.registerAdapter(TrackAdapter());
    
    await Future.wait([
      Hive.openBox(StorageConstants.settingsBox),
      Hive.openBox(StorageConstants.userBox),
      Hive.openBox(StorageConstants.cacheBox),
      Hive.openBox(StorageConstants.offlineBox),
    ]);
  }

  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  static Future<void> clearAll() async {
    await Hive.box(StorageConstants.settingsBox).clear();
    await Hive.box(StorageConstants.userBox).clear();
    await Hive.box(StorageConstants.cacheBox).clear();
    await Hive.box(StorageConstants.offlineBox).clear();
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }
}
