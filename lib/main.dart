import 'package:apsara_wallet_mobile/app/app.dart';
import 'package:apsara_wallet_mobile/core/configs/config_service.dart';
import 'package:apsara_wallet_mobile/core/enums/environment_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfigService.initialize(EEnvironmentType.dev);

  runApp(const ProviderScope(child: MyApp()));
}
