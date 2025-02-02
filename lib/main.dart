import 'package:flutter/material.dart';
import 'package:gestion_app/auth/views/login_screen.dart';
import 'package:gestion_app/home/views/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/providers/auth_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(prefs),
      child: MaterialApp(
        title: 'Gestión de Stock',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated
                ? const HomeScreen() // Crea esta página
                : const LoginScreen(); // Crea esta página

          },
        ),
      ),
    );
  }
}
