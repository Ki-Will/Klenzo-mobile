import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Hive Database
  await Hive.initFlutter();
  await Hive.openBox('offline_queue');
  await Hive.openBox('local_cache');

  runApp(
    const ProviderScope(
      child: KlenzoApp(),
    ),
  );
}
