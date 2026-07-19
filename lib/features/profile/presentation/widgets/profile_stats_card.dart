import 'package:flutter/material.dart';

import 'package:apsara_wallet_mobile/core/themes/app_colors.dart';
import 'package:apsara_wallet_mobile/core/themes/app_font.dart';
import 'package:apsara_wallet_mobile/core/themes/app_radius.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/profile/data/profile_mock_data.dart';

/// The white stats strip that straddles the profile header's lower edge —
/// Wallets · Transactions · Budgets, each a big number over a small label,
/// separated by hairline rules.
class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key, required this.data});

  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _Stat(value: '${data.walletCount}', label: 'Wallets')),
          const _Separator(),
          Expanded(
            child: _Stat(
              value: '${data.transactionCount}',
              label: 'Transactions',
            ),
          ),
          const _Separator(),
          Expanded(child: _Stat(value: '${data.budgetCount}', label: 'Budgets')),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppFont.titleLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppFont.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.surfaceVariant,
    );
  }
}
