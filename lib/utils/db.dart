import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:micropass_api/micropass_api.dart';

class CipherDB {
  static const boxName = 'cipher';

  static Future<void> insert(Cipher cipher) async {
    var box = await Hive.openBox(boxName);

    await box.put(cipher.id, cipher.toJson());
  }

  static Future<void> update(String id, Cipher cipher) async {
    var box = await Hive.openBox(boxName);

    await box.put(id, cipher.toJson());
  }

  static Future<Cipher> get(String id) async {
    var box = await Hive.openBox(boxName);

    var cipherJson = await box.get(id);
    var cipher = Cipher.fromMap(json.decode(cipherJson));

    return cipher;
  }

  static Future<void> delete(String id) async {
    var box = await Hive.openBox(boxName);

    await box.delete(id);
  }

  static Future<Map<dynamic, dynamic>> toMap() async {
    var box = await Hive.openBox(boxName);

    return box.toMap();
  }
}
