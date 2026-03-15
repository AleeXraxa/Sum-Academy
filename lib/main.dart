import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sum_academy/app/app.dart';
import 'package:sum_academy/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SumAcademyApp());
}
