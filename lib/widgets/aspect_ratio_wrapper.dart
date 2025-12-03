import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class AspectRatioWrapper extends StatefulWidget {
  final Widget child;

  const AspectRatioWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AspectRatioWrapper> createState() => _AspectRatioWrapperState();
}

class _AspectRatioWrapperState extends State<AspectRatioWrapper> {
  final SettingsService _settingsService = SettingsService.instance;
  bool _forceVerticalAspectRatio = false;

  @override
  void initState() {
    super.initState();
    _loadSetting();
    _settingsService.addListener(_onSettingChanged);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingChanged);
    super.dispose();
  }

  Future<void> _loadSetting() async {
    final enabled = await _settingsService.getForceVerticalAspectRatio();
    if (mounted) {
      setState(() {
        _forceVerticalAspectRatio = enabled;
      });
    }
  }

  void _onSettingChanged() {
    _loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    if (!_forceVerticalAspectRatio) {
      return widget.child;
    }

    // Force vertical aspect ratio (9:16, typical phone ratio)
    const double targetAspectRatio = 9.0 / 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenAspectRatio = screenWidth / screenHeight;

        // If screen is already vertical or narrower, no need to constrain
        if (screenAspectRatio <= targetAspectRatio) {
          return widget.child;
        }

        // Calculate the constrained width to maintain vertical aspect ratio
        final constrainedWidth = screenHeight * targetAspectRatio;
        final horizontalPadding = (screenWidth - constrainedWidth) / 2;

        return Container(
          color: Colors.black, // Black bars on sides
          child: Row(
            children: [
              SizedBox(width: horizontalPadding),
              SizedBox(
                width: constrainedWidth,
                child: widget.child,
              ),
              SizedBox(width: horizontalPadding),
            ],
          ),
        );
      },
    );
  }
}

