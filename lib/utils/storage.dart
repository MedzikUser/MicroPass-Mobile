import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memory_cache/memory_cache.dart';

const storage = FlutterSecureStorage();
final memoryCache = MemoryCache.instance;

class Storage {
  /// Insert variable into a storage.
  static insert(key, String value) async {
    // save the key to a suitable storage
    if (key.isInMemory) {
      // write the value to the in-memory storage
      memoryCache.create(key.key, value);
    } else {
      // write the value to the application storage
      await storage.write(key: key.key, value: value);
    }
  }

  /// Get variable value from the storage.
  static Future<String?> read(StorageKey key) async {
    // read the key to a suitable storage
    if (key.isInMemory) {
      // read the value from the in-memory storage
      return memoryCache.read<String>(key.key);
    } else {
      // read the value from the application storage
      return await storage.read(key: key.key);
    }
  }

  /// Delete key from the storage.
  static delete(StorageKey key) async {
    // deleate the key from a suitable storage
    if (key.isInMemory) {
      // delete the value from a in-memory storage
      return memoryCache.delete(key.key);
    } else {
      // delete value from a application storage
      return await storage.delete(key: key.key);
    }
  }

  /// Delete all keys from memory
  static dropMemory() async {
    memoryCache.invalidate();
  }

  /// Delete all keys.
  static deleteAll() async {
    // delete all keys from memory
    memoryCache.invalidate();

    // delete all keys from the application storage
    await storage.deleteAll();
  }
}

class StorageKey {
  final String key;

  /// If true, the key will be stored in memory,
  /// otherwise it will be stored in application storage.
  final bool isInMemory;

  const StorageKey(this.key, this.isInMemory);

  /// Save key to the application storage.
  static const _storage = false;

  /// Save key to the in-memory storage.
  static const _memory = true;

  static const accessToken = StorageKey('accessToken', _memory);
  static const refreshToken = StorageKey('refresh', _storage);
  static const email = StorageKey('email', _storage);

  /// Key with the aes secret key.
  /// * The key is stored in memory and deleted when the application is closed.
  static const encryptionKey = StorageKey('encryptionKey', _memory);

  static const cachedCiphers = StorageKey('ciphers', _storage);
  static const ciphersLastSync = StorageKey('ciphersLastSync', _storage);
}
