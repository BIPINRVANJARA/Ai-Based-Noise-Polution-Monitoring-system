import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noiseguard/app.dart';
import 'package:noiseguard/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Initialization Warning: $e');
  }

  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('NotificationService Init Warning: $e');
  }

  runApp(const ProviderScope(child: NoiseGuardApp()));
}

