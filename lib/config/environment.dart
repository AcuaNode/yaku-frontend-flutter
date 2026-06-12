import 'package:flutter/foundation.dart';
import 'dart:io';

class Environment {
  static String get baseUrl {
    if (kIsWeb) {
      // Si es Chrome, usa localhost
      return 'http://localhost:8080/api'; 
    } else if (Platform.isAndroid) {
      // Si es  Android, usa su túnel
      return 'http://10.0.2.2:8080/api'; 
    } else {
      return 'http://localhost:8080/api';
    }
  }
}