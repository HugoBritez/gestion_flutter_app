import 'package:flutter/material.dart';
import 'package:gestion_app/auth/views/login_screen.dart';
import 'package:gestion_app/auth/views/registrer_empresa_screen.dart';
import 'package:gestion_app/auth/views/register_invitado_screen.dart';
import 'package:gestion_app/home/views/home_screen.dart';
import 'package:gestion_app/settings/views/settings_screen.dart';
import 'package:gestion_app/inventory/views/inventory_list_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/settings': (context) => const SettingsScreen(),
  '/register/empresa': (context) => const RegisterEmpresaScreen(),
  '/register/invitado': (context) => const RegisterInvitadoScreen(),
  '/inventory': (context) => const InventoryListScreen(),
};

