import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unicorn_app_frontend/config/api_config.dart';
import 'package:unicorn_app_frontend/routes/router.dart';
import 'services/api_service.dart';

void testApiConnection() async {
  try {
    print('Testing connection to: ${ApiConfig.baseUrl}');
    
    // Test basic connectivity using health endpoint
    final isConnected = await ApiService.testConnection();
    print('Health check result: $isConnected');
    
    if (!isConnected) {
      print('Warning: Could not connect to the API server');
    }
  } catch (e) {
    print('Connection test failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  testApiConnection();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
