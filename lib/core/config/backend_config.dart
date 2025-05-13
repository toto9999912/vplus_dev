import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

///開發環境初始設定
void initalizeFlavorConfig() {
  ///讀取 vscode 本地開發環境設定 launch.json ，預設為dev
  final environment = const String.fromEnvironment('ENV', defaultValue: 'dev');

  if (environment == 'dev') {
    // Initialize with development configuration
    // 開發區設定
    FlavorConfig(
      name: "DEVELOP",
      color: Colors.red,
      location: BannerLocation.bottomStart,
      variables: {"csharp": "http://192.168.0.125", "nestjs": "http://192.168.0.78:3001", "core": "http://192.168.0.66:5000"},
    );
  } else if (environment == 'prod') {
    // Initialize with production configuration
    // 正式區設定
    FlavorConfig(
      name: "PRODUCTION",
      color: Colors.blue,
      location: BannerLocation.bottomStart,
      variables: {
        "csharp": "http://35.221.198.223",
        "nestjs": "http://35.185.135.243:3001",
        "core": "https://procurement-api-tqy4nkx4ea-de.a.run.app",
      },
    );
  } else if (environment == 'local') {
    // Initialize with production configuration
    //正式區設定
    FlavorConfig(
      name: "LOCALHOST",
      color: Colors.green,
      location: BannerLocation.bottomStart,

      //因Android 模擬器限制，當嘗試連接本地環境伺服器，會連接到模擬器本身而不是本地伺服器
      //可使用模擬器提供的特殊 IP  10.0.2.2 或是 內網IP 處理
      //詳細參考以下文章
      //https://developer.android.com/studio/run/emulator-networking?hl=zh-tw
      variables: {"csharp": "http://192.168.0.125", "nestjs": "http://192.168.0.32:3001"},
    );
  }
}
