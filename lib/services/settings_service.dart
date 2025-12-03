import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const String _forceVerticalAspectRatioKey = 'neon_escape_force_vertical_aspect';
  
  bool? _forceVerticalAspectRatio;
  bool _isLoading = false;

  Future<bool> getForceVerticalAspectRatio() async {
    if (_forceVerticalAspectRatio != null) {
      return _forceVerticalAspectRatio!;
    }
    
    if (_isLoading) {
      // Wait a bit if already loading
      await Future.delayed(const Duration(milliseconds: 100));
      return _forceVerticalAspectRatio ?? false;
    }
    
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _forceVerticalAspectRatio = prefs.getBool(_forceVerticalAspectRatioKey) ?? false;
      return _forceVerticalAspectRatio!;
    } on MissingPluginException {
      _forceVerticalAspectRatio = false;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> setForceVerticalAspectRatio(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_forceVerticalAspectRatioKey, enabled);
      _forceVerticalAspectRatio = enabled;
      notifyListeners();
    } on MissingPluginException {
      return;
    }
  }
}

