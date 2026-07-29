// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_routes.dart';

/// generated route for
/// [AboutScreen]
class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute({List<PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutScreen();
    },
  );
}

/// generated route for
/// [AddTransactionScreen]
class AddTransactionRoute extends PageRouteInfo<AddTransactionRouteArgs> {
  AddTransactionRoute({
    Key? key,
    ETransactionType initialType = ETransactionType.expense,
    DateTime? initialDateTime,
    TransactionRecord? initialRecord,
    List<PageRouteInfo>? children,
  }) : super(
         AddTransactionRoute.name,
         args: AddTransactionRouteArgs(
           key: key,
           initialType: initialType,
           initialDateTime: initialDateTime,
           initialRecord: initialRecord,
         ),
         initialChildren: children,
       );

  static const String name = 'AddTransactionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddTransactionRouteArgs>(
        orElse: () => const AddTransactionRouteArgs(),
      );
      return AddTransactionScreen(
        key: args.key,
        initialType: args.initialType,
        initialDateTime: args.initialDateTime,
        initialRecord: args.initialRecord,
      );
    },
  );
}

class AddTransactionRouteArgs {
  const AddTransactionRouteArgs({
    this.key,
    this.initialType = ETransactionType.expense,
    this.initialDateTime,
    this.initialRecord,
  });

  final Key? key;

  final ETransactionType initialType;

  final DateTime? initialDateTime;

  final TransactionRecord? initialRecord;

  @override
  String toString() {
    return 'AddTransactionRouteArgs{key: $key, initialType: $initialType, initialDateTime: $initialDateTime, initialRecord: $initialRecord}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddTransactionRouteArgs) return false;
    return key == other.key &&
        initialType == other.initialType &&
        initialDateTime == other.initialDateTime &&
        initialRecord == other.initialRecord;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      initialType.hashCode ^
      initialDateTime.hashCode ^
      initialRecord.hashCode;
}

/// generated route for
/// [AiInsightsScreen]
class AiInsightsRoute extends PageRouteInfo<void> {
  const AiInsightsRoute({List<PageRouteInfo>? children})
    : super(AiInsightsRoute.name, initialChildren: children);

  static const String name = 'AiInsightsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AiInsightsScreen();
    },
  );
}

/// generated route for
/// [AnalyticsScreen]
class AnalyticsRoute extends PageRouteInfo<void> {
  const AnalyticsRoute({List<PageRouteInfo>? children})
    : super(AnalyticsRoute.name, initialChildren: children);

  static const String name = 'AnalyticsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AnalyticsScreen();
    },
  );
}

/// generated route for
/// [BiometricScreen]
class BiometricRoute extends PageRouteInfo<BiometricRouteArgs> {
  BiometricRoute({
    Key? key,
    bool isOnboarding = false,
    List<PageRouteInfo>? children,
  }) : super(
         BiometricRoute.name,
         args: BiometricRouteArgs(key: key, isOnboarding: isOnboarding),
         initialChildren: children,
       );

  static const String name = 'BiometricRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BiometricRouteArgs>(
        orElse: () => const BiometricRouteArgs(),
      );
      return BiometricScreen(key: args.key, isOnboarding: args.isOnboarding);
    },
  );
}

class BiometricRouteArgs {
  const BiometricRouteArgs({this.key, this.isOnboarding = false});

  final Key? key;

  final bool isOnboarding;

  @override
  String toString() {
    return 'BiometricRouteArgs{key: $key, isOnboarding: $isOnboarding}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BiometricRouteArgs) return false;
    return key == other.key && isOnboarding == other.isOnboarding;
  }

  @override
  int get hashCode => key.hashCode ^ isOnboarding.hashCode;
}

/// generated route for
/// [BudgetScreen]
class BudgetRoute extends PageRouteInfo<void> {
  const BudgetRoute({List<PageRouteInfo>? children})
    : super(BudgetRoute.name, initialChildren: children);

  static const String name = 'BudgetRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BudgetScreen();
    },
  );
}

/// generated route for
/// [CategoriesScreen]
class CategoriesRoute extends PageRouteInfo<void> {
  const CategoriesRoute({List<PageRouteInfo>? children})
    : super(CategoriesRoute.name, initialChildren: children);

  static const String name = 'CategoriesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CategoriesScreen();
    },
  );
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardScreen();
    },
  );
}

/// generated route for
/// [EditProfileScreen]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfileScreen();
    },
  );
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [HelpSupportScreen]
class HelpSupportRoute extends PageRouteInfo<void> {
  const HelpSupportRoute({List<PageRouteInfo>? children})
    : super(HelpSupportRoute.name, initialChildren: children);

  static const String name = 'HelpSupportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HelpSupportScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [NotificationsScreen]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationsScreen();
    },
  );
}

/// generated route for
/// [OnBoardingScreen]
class OnBoardingRoute extends PageRouteInfo<void> {
  const OnBoardingRoute({List<PageRouteInfo>? children})
    : super(OnBoardingRoute.name, initialChildren: children);

  static const String name = 'OnBoardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnBoardingScreen();
    },
  );
}

/// generated route for
/// [OtpScreen]
class OtpRoute extends PageRouteInfo<void> {
  const OtpRoute({List<PageRouteInfo>? children})
    : super(OtpRoute.name, initialChildren: children);

  static const String name = 'OtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OtpScreen();
    },
  );
}

/// generated route for
/// [PinLoginScreen]
class PinLoginRoute extends PageRouteInfo<void> {
  const PinLoginRoute({List<PageRouteInfo>? children})
    : super(PinLoginRoute.name, initialChildren: children);

  static const String name = 'PinLoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PinLoginScreen();
    },
  );
}

/// generated route for
/// [PinSetupScreen]
class PinSetupRoute extends PageRouteInfo<PinSetupRouteArgs> {
  PinSetupRoute({
    Key? key,
    bool isOnboarding = false,
    List<PageRouteInfo>? children,
  }) : super(
         PinSetupRoute.name,
         args: PinSetupRouteArgs(key: key, isOnboarding: isOnboarding),
         initialChildren: children,
       );

  static const String name = 'PinSetupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PinSetupRouteArgs>(
        orElse: () => const PinSetupRouteArgs(),
      );
      return PinSetupScreen(key: args.key, isOnboarding: args.isOnboarding);
    },
  );
}

class PinSetupRouteArgs {
  const PinSetupRouteArgs({this.key, this.isOnboarding = false});

  final Key? key;

  final bool isOnboarding;

  @override
  String toString() {
    return 'PinSetupRouteArgs{key: $key, isOnboarding: $isOnboarding}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PinSetupRouteArgs) return false;
    return key == other.key && isOnboarding == other.isOnboarding;
  }

  @override
  int get hashCode => key.hashCode ^ isOnboarding.hashCode;
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
    : super(PrivacyPolicyRoute.name, initialChildren: children);

  static const String name = 'PrivacyPolicyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPolicyScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RecurringScreen]
class RecurringRoute extends PageRouteInfo<void> {
  const RecurringRoute({List<PageRouteInfo>? children})
    : super(RecurringRoute.name, initialChildren: children);

  static const String name = 'RecurringRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RecurringScreen();
    },
  );
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<ResetPasswordRouteArgs> {
  ResetPasswordRoute({
    Key? key,
    required String token,
    List<PageRouteInfo>? children,
  }) : super(
         ResetPasswordRoute.name,
         args: ResetPasswordRouteArgs(key: key, token: token),
         initialChildren: children,
       );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResetPasswordRouteArgs>();
      return ResetPasswordScreen(key: args.key, token: args.token);
    },
  );
}

class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({this.key, required this.token});

  final Key? key;

  final String token;

  @override
  String toString() {
    return 'ResetPasswordRouteArgs{key: $key, token: $token}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResetPasswordRouteArgs) return false;
    return key == other.key && token == other.token;
  }

  @override
  int get hashCode => key.hashCode ^ token.hashCode;
}

/// generated route for
/// [SavingsGoalsScreen]
class SavingsGoalsRoute extends PageRouteInfo<void> {
  const SavingsGoalsRoute({List<PageRouteInfo>? children})
    : super(SavingsGoalsRoute.name, initialChildren: children);

  static const String name = 'SavingsGoalsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SavingsGoalsScreen();
    },
  );
}

/// generated route for
/// [ScanReceiptScreen]
class ScanReceiptRoute extends PageRouteInfo<void> {
  const ScanReceiptRoute({List<PageRouteInfo>? children})
    : super(ScanReceiptRoute.name, initialChildren: children);

  static const String name = 'ScanReceiptRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScanReceiptScreen();
    },
  );
}

/// generated route for
/// [SecurityScreen]
class SecurityRoute extends PageRouteInfo<void> {
  const SecurityRoute({List<PageRouteInfo>? children})
    : super(SecurityRoute.name, initialChildren: children);

  static const String name = 'SecurityRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SecurityScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [TermsOfServiceScreen]
class TermsOfServiceRoute extends PageRouteInfo<void> {
  const TermsOfServiceRoute({List<PageRouteInfo>? children})
    : super(TermsOfServiceRoute.name, initialChildren: children);

  static const String name = 'TermsOfServiceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TermsOfServiceScreen();
    },
  );
}

/// generated route for
/// [TransactionDetailScreen]
class TransactionDetailRoute extends PageRouteInfo<TransactionDetailRouteArgs> {
  TransactionDetailRoute({
    Key? key,
    required String id,
    List<PageRouteInfo>? children,
  }) : super(
         TransactionDetailRoute.name,
         args: TransactionDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'TransactionDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TransactionDetailRouteArgs>();
      return TransactionDetailScreen(key: args.key, id: args.id);
    },
  );
}

class TransactionDetailRouteArgs {
  const TransactionDetailRouteArgs({this.key, required this.id});

  final Key? key;

  final String id;

  @override
  String toString() {
    return 'TransactionDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [TransactionsListScreen]
class TransactionsListRoute extends PageRouteInfo<void> {
  const TransactionsListRoute({List<PageRouteInfo>? children})
    : super(TransactionsListRoute.name, initialChildren: children);

  static const String name = 'TransactionsListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TransactionsListScreen();
    },
  );
}

/// generated route for
/// [WalletDetailScreen]
class WalletDetailRoute extends PageRouteInfo<WalletDetailRouteArgs> {
  WalletDetailRoute({
    Key? key,
    required int index,
    List<PageRouteInfo>? children,
  }) : super(
         WalletDetailRoute.name,
         args: WalletDetailRouteArgs(key: key, index: index),
         initialChildren: children,
       );

  static const String name = 'WalletDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WalletDetailRouteArgs>();
      return WalletDetailScreen(key: args.key, index: args.index);
    },
  );
}

class WalletDetailRouteArgs {
  const WalletDetailRouteArgs({this.key, required this.index});

  final Key? key;

  final int index;

  @override
  String toString() {
    return 'WalletDetailRouteArgs{key: $key, index: $index}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WalletDetailRouteArgs) return false;
    return key == other.key && index == other.index;
  }

  @override
  int get hashCode => key.hashCode ^ index.hashCode;
}

/// generated route for
/// [WalletsScreen]
class WalletsRoute extends PageRouteInfo<void> {
  const WalletsRoute({List<PageRouteInfo>? children})
    : super(WalletsRoute.name, initialChildren: children);

  static const String name = 'WalletsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WalletsScreen();
    },
  );
}

/// generated route for
/// [WelcomeScreen]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomeScreen();
    },
  );
}
