import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:offline_queue/features/presentation/provider/note_provider.dart';
import 'package:offline_queue/features/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Connectivity().onConnectivityChanged.listen((event) {
    if (event != ConnectivityResult.none) {
      SyncManager().processQueue();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'OfflineQueue',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
