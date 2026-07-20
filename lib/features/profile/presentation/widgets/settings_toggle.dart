import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';

/// The house switch — emerald active track, white thumb. Shared by the
/// Settings screen and the profile sub-pages so every toggle reads the same.
class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primary,
      activeThumbColor: Colors.white,
    );
  }
}
