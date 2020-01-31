import 'dart:convert';
import 'dart:io';

import 'package:clippy/server.dart' as cp;
import 'package:upload_image/src/azure_uploader.dart';

import 'src/uploader.dart';

Uploader uploader;

void upload() async {
  final process = await Process.start('bin/mac/ReadClipboard', []);
  final buffer = StringBuffer();
  process.stdout.listen((value) {
    buffer.write(utf8.decode(value));
  });
  final code = await process.exitCode;
  if (code != 0) {
    print('没有上传, 因为剪切板第一张不是图片');
    return;
  }

  uploader = AzureUploader();
  uploader.init();

  final lines = await LineSplitter.split(buffer.toString());

  final string =
      lines.where((test) => test.startsWith('base64:')).first.substring(7);

  final result = await uploader.upload(string);
  print('上传成功: url : $result');

  final clipResult = await cp.write(result);
  print('复制到剪切板: $clipResult');

  exit(0);
}
