import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:upload_image/src/uploader.dart';
import 'package:http/http.dart' as http;

class AzureUploader with Uploader {
  String org;
  String project;
  String repo;
  String username;
  String password;

  String get url =>
      'https://dev.azure.com/$org/$project/_apis/git/repositories/$repo/pushes?api-version=5.0';

  @override
  void initConfig(Map<String, dynamic> configs) {
    org = configs['org'];
    project = configs['project'];
    repo = configs['repo'];
    username = configs['user'];
    password = configs['token'];
  }

  @override
  Future<String> upload(String imageContent) async {
    final lastCommitId = await _getLastCommitId();
    print('lastCommitId = $lastCommitId');
    return _upload(imageContent, lastCommitId);
  }

  Future<String> _getLastCommitId() async {
    final response = await http.get(url);
    final map = json.decode(response.body);
    final commitResponse = await http.get(map['value'][0]['url']);
    return json.decode(commitResponse.body)['commits'][0]['commitId'];
  }

  Future<String> _upload(String imageContent, String lastCommitId) async {
    final token = base64.encode(ascii.encode('$username:$password'));
    final now = DateTime.now();
    final dt = now.toLocal().toString();
    final ms = now.millisecondsSinceEpoch;

    final pathName = '$ms.png';

    final body = {
      'refUpdates': [
        {
          'name': 'refs/heads/master',
          'oldObjectId': lastCommitId,
        },
      ],
      'commits': [
        {
          'comment': 'add image at $dt',
          'changes': [
            {
              'changeType': 'add',
              'item': {
                'path': pathName,
              },
              'newContent': {
                'content': imageContent,
                'contentType': 'base64Encoded',
              }
            }
          ],
        }
      ],
    };

    final httpClient = HttpClient();
    // httpClient.findProxy = (proxy) {
    //   return 'PROXY localhost:8888';
    // };

    final client = IOClient(httpClient);

    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Basic $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    client.close();
    httpClient.close();

    final commitResult = json.decode(response.body);

    final repoUrl = commitResult['repository']['url'];

    final itemUrl =
        '$repoUrl/items?path=%2F${pathName}&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=octetStream&api-version=5.0';

    return itemUrl;
  }
}
