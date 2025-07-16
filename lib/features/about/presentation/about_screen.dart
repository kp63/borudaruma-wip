import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:app_settings/app_settings.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String version = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('このアプリについて')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.apps),
            title: Text('アプリ名'),
            subtitle: Text('ボルダルマ'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('バージョン'),
            subtitle: Text(version),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('アプリ設定を開く'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              AppSettings.openAppSettings();
            },
          ),
        ],
      ),
    );
  }
}
