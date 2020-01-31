import 'dart:convert';
import 'dart:io';

mixin Uploader {
  void init() {
    final configFile = File('config/${runtimeType.toString()}.json');
    initConfig(json.decode(configFile.readAsStringSync()));
  }

  void initConfig(Map<String, dynamic> configs);

  Future<String> upload(String imageContent);
}
