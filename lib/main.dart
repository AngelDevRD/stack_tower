import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

// Punto de entrada de la app.
void main() {
  runApp(const ProviderScope(child: StackTowerApp()));
}
