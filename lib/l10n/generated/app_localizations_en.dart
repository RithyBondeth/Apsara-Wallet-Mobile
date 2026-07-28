// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonLogin => 'Login';

  @override
  String get commonGetStarted => 'Get Started';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonForgotPassword => 'Forgot Password?';

  @override
  String get authIdentifierLabel => 'Email or Phone Number';

  @override
  String get authIdentifierHint => 'Enter email or phone number';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithFacebook => 'Continue with Facebook';

  @override
  String get authOrContinueWith => 'or continue with';

  @override
  String get welcomeGreeting => 'Welcome to';

  @override
  String get welcomeTagline =>
      'Your smart companion for\nbetter financial management.';

  @override
  String get welcomeNewHerePrompt => 'New here? ';

  @override
  String get welcomeCreateAccountCta => 'Create an account';

  @override
  String get onboardingTitle1 => 'All your money,\nbeautifully in one place';

  @override
  String get onboardingBody1 =>
      'Track balances, cards and spending across USD and KHR — with the elegance Apsara brings to every detail.';

  @override
  String get onboardingTitle2 => 'Send & receive\nin a few taps';

  @override
  String get onboardingBody2 =>
      'Instant transfers and QR payments across Cambodia. Fast, secure, and effortless — day or night.';

  @override
  String get onboardingTitle3 => 'Insights that\ngrow your wealth';

  @override
  String get onboardingBody3 =>
      'Smart budgets and clear analytics turn everyday spending into confident financial decisions.';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Welcome back! Please login to continue.';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginNoAccountPrompt => 'Don\'t have an account? ';

  @override
  String get loginSignUpCta => 'Sign up';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Join Apsara Wallet in a few easy steps.';

  @override
  String get registerNameLabel => 'Full Name';

  @override
  String get registerNameHint => 'Enter your full name';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => 'Create a password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm Password';

  @override
  String get registerConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authErrorNameRequired => 'Please enter your name';

  @override
  String get authErrorEmailRequired => 'Please enter your email';

  @override
  String get authErrorEmailInvalid => 'Please enter a valid email address';

  @override
  String get authErrorPasswordRequired => 'Please enter your password';

  @override
  String get authErrorPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get authErrorPasswordMismatch => 'Passwords don\'t match';

  @override
  String get authSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get authSocialComingSoon => 'This sign-in method isn\'t available yet';

  @override
  String get walletAddFailed => 'Couldn\'t add the wallet. Please try again.';

  @override
  String get addTxNoWallet => 'Add a wallet first to record a transaction';

  @override
  String get addTxNoWalletShort => 'No wallet';

  @override
  String get addTxSaveFailed =>
      'Couldn\'t save the transaction. Please try again.';

  @override
  String get emptyWalletsTitle => 'Create your first wallet';

  @override
  String get emptyWalletsBody =>
      'Add a wallet to start tracking your income and expenses.';

  @override
  String get emptyWalletsCta => 'Create wallet';

  @override
  String get emptyTransactionsTitle => 'No transactions yet';

  @override
  String get emptyTransactionsBody => 'Tap the + button to add your first one.';

  @override
  String get budgetEmptyTitle => 'No budgets yet';

  @override
  String get budgetEmptyBody =>
      'Set a monthly limit for a category to track your spending.';

  @override
  String get lockTitle => 'Enter your PIN';

  @override
  String get lockSubtitle => 'Unlock to continue';

  @override
  String get lockIncorrectPin => 'Incorrect PIN. Please try again.';

  @override
  String lockLockedOut(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s.';
  }

  @override
  String get lockUseBiometric => 'Use biometric unlock';

  @override
  String get lockBiometricReason => 'Unlock Apsara Wallet';

  @override
  String get lockUsePassword => 'Use password instead';

  @override
  String get pinConfirmTitle => 'Confirm your PIN';

  @override
  String get pinConfirmSubtitle => 'Re-enter your PIN to confirm';

  @override
  String get pinMismatch => 'PINs don\'t match. Start again.';

  @override
  String get pinUpdated => 'App-lock PIN saved';

  @override
  String get securityBiometricUnavailable =>
      'No biometrics enrolled on this device';

  @override
  String get securityNeedPinFirst => 'Set an app-lock PIN first';

  @override
  String get securityEnableBiometricReason =>
      'Confirm it\'s you to enable biometric unlock';

  @override
  String get securityAppLockOn => 'App lock is on';

  @override
  String get securityAppLockOff => 'App lock is off';

  @override
  String get registerHasAccountPrompt => 'Already have an account? ';

  @override
  String get forgotPasswordSubtitle =>
      'Enter the email or phone linked to your account and we\'ll send you a reset code.';

  @override
  String get forgotPasswordSendCta => 'Send Reset Code';

  @override
  String get forgotPasswordBackToLogin => 'Back to Login';

  @override
  String get forgotPasswordSent =>
      'If that account exists, you\'ll receive reset instructions.';

  @override
  String get forgotPasswordFailed =>
      'Couldn\'t start the reset. Please try again.';

  @override
  String get resetPasswordSuccess => 'Password updated. Please sign in.';

  @override
  String get resetPasswordFailed =>
      'This reset link is invalid or has expired.';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordSubtitle => 'Choose a new password for your account.';

  @override
  String get resetPasswordNewLabel => 'New Password';

  @override
  String get resetPasswordNewHint => 'Enter new password';

  @override
  String get resetPasswordConfirmLabel => 'Confirm New Password';

  @override
  String get resetPasswordConfirmHint => 'Re-enter new password';

  @override
  String get resetPasswordSaveCta => 'Save New Password';

  @override
  String get otpTitle => 'Verification Code';

  @override
  String get otpSubtitle =>
      'We\'ve sent a 6-digit code to your email or phone. Enter it below to continue.';

  @override
  String get otpResendPrompt => 'Didn\'t receive the code? ';

  @override
  String get otpResendCta => 'Resend';

  @override
  String get otpVerifyCta => 'Verify';

  @override
  String get pinLoginTitle => 'Enter Your PIN';

  @override
  String get pinLoginSubtitle => 'Welcome back — unlock your wallet.';

  @override
  String get pinLoginUsePasswordCta => 'Use password instead';

  @override
  String get pinSetupTitle => 'Set Your PIN';

  @override
  String get pinSetupSubtitle => 'A 4-digit PIN keeps your wallet extra safe.';

  @override
  String get biometricTitle => 'Enable Biometric Login';

  @override
  String get biometricSubtitle =>
      'Sign in with your fingerprint or face — fast, secure and effortless.';

  @override
  String get biometricEnableCta => 'Enable Biometric';

  @override
  String get biometricLaterCta => 'Maybe Later';

  @override
  String get addTxTitle => 'Add Transaction';

  @override
  String get addTxEditTitle => 'Edit Transaction';

  @override
  String get addTxAmount => 'Amount';

  @override
  String get addTxCategory => 'Category';

  @override
  String get addTxWallet => 'Wallet';

  @override
  String get addTxFromWallet => 'From Wallet';

  @override
  String get addTxToWallet => 'To Wallet';

  @override
  String get addTxDateTime => 'Date & Time';

  @override
  String get addTxTitleLabel => 'Title';

  @override
  String get addTxTitleHint => 'e.g. Coffee, Groceries, Taxi';

  @override
  String get addTxNote => 'Note (Optional)';

  @override
  String get addTxNoteHint => 'What was this for?';

  @override
  String get addTxReceipt => 'Add Receipt';

  @override
  String get addTxScanOrUpload => 'Scan or upload receipt';

  @override
  String get addTxSave => 'Save Transaction';

  @override
  String get addTxSaved => 'Transaction saved';

  @override
  String get addTxChooseCategory => 'Choose Category';

  @override
  String get addTxChooseWallet => 'Choose Wallet';

  @override
  String get addTxChooseCurrency => 'Currency';

  @override
  String get categoryFoodDining => 'Food & Dining';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBills => 'Bills & Utilities';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryPersonalCare => 'Personal Care';

  @override
  String get categoryGifts => 'Gifts & Donations';

  @override
  String get categoryOthers => 'Others';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryInvestment => 'Investment';

  @override
  String get commonSave => 'Save';

  @override
  String get analyticsRangeWeek => 'This Week';

  @override
  String get analyticsRangeMonth => 'This Month';

  @override
  String get analyticsRangeYear => 'This Year';

  @override
  String get analyticsSelectRange => 'Time Range';

  @override
  String get analyticsEmptyTitle => 'Nothing to analyze yet';

  @override
  String get analyticsEmptyBody =>
      'Add some expenses in this period and your breakdown and trends will appear here.';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetAdd => 'Add Budget';

  @override
  String get budgetProgress => 'Budget Progress';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetByCategory => 'Budget by Category';

  @override
  String get budgetMonthlyLimit => 'Monthly Limit';

  @override
  String get budgetAdded => 'Budget added';

  @override
  String get budgetEditTitle => 'Edit Budget';

  @override
  String get budgetDelete => 'Delete budget';

  @override
  String get budgetUpdated => 'Budget updated';

  @override
  String get budgetDeleted => 'Budget removed';

  @override
  String get categoriesTitle => 'Category';

  @override
  String get categoriesSearchHint => 'Search categories';

  @override
  String get categoriesEditTitle => 'Edit Category';

  @override
  String get categoriesNewTitle => 'New Category';

  @override
  String get categoriesNameLabel => 'Name';

  @override
  String get categoriesIconLabel => 'Icon';

  @override
  String get categoriesColorLabel => 'Color';

  @override
  String get categoriesSaved => 'Category saved';

  @override
  String get categoriesSaveFailed =>
      'Couldn\'t save the category. Please try again.';

  @override
  String get categoriesDelete => 'Delete category';

  @override
  String get categoriesDeleted => 'Category removed';

  @override
  String get profileCategories => 'Categories';

  @override
  String get profileCategoriesSubtitle => 'Manage icons & colors';

  @override
  String get insightsTitle => 'AI Insights';

  @override
  String get insightsToday => 'Today\'s Insight';

  @override
  String get insightsHealthScore => 'Financial Health Score';

  @override
  String get insightsMore => 'More Insights';

  @override
  String get insightsScoreNeedsWork => 'Needs work';

  @override
  String get insightsScoreFair => 'Fair';

  @override
  String get insightsScoreGood => 'Good';

  @override
  String get insightsScoreExcellent => 'Excellent';

  @override
  String insightsHealthSavings(int pct) {
    return 'You saved $pct% of your income this month.';
  }

  @override
  String insightsHealthOverspent(int pct) {
    return 'You spent $pct% more than you earned this month.';
  }

  @override
  String get insightsEncourageNeedsWork =>
      'Let\'s turn this around — small changes add up fast.';

  @override
  String get insightsEncourageFair =>
      'You\'re getting there. A little more discipline goes a long way.';

  @override
  String get insightsEncourageGood =>
      'You\'re on the right track — keep it up!';

  @override
  String get insightsEncourageExcellent =>
      'Outstanding money habits. Keep the momentum going!';

  @override
  String insightTopCategory(String category, String amount, int pct) {
    return '$category was your biggest expense — $amount ($pct% of spending).';
  }

  @override
  String insightBusiestDay(String day) {
    return 'You spend the most on ${day}s.';
  }

  @override
  String insightCategoryUp(int pct, String category) {
    return 'You spent $pct% more on $category than last month.';
  }

  @override
  String insightCategoryDown(int pct, String category) {
    return 'You spent $pct% less on $category than last month.';
  }

  @override
  String insightSavingsPositive(String amount, int pct) {
    return 'You saved $amount this month — $pct% of your income.';
  }

  @override
  String insightOverspend(String amount) {
    return 'You spent $amount more than you earned this month.';
  }

  @override
  String get insightsCoachSaving =>
      'Great discipline — consider moving some into savings.';

  @override
  String get insightsCoachOverspend =>
      'Try trimming non-essentials to get back in the green.';

  @override
  String get insightsCoachReduce =>
      'Small cuts here would make the biggest difference.';

  @override
  String get insightsCoachKeepGoing =>
      'Nice progress — keep the good habit going.';

  @override
  String get insightsCoachTopCategory =>
      'Watch this category to keep your spending on track.';

  @override
  String get insightsCoachDefault =>
      'Keep tracking to stay on top of your money.';

  @override
  String get insightsEmptyTitle => 'Not enough data yet';

  @override
  String get insightsEmptyBody =>
      'Add a few transactions and I\'ll start spotting patterns in your spending.';

  @override
  String get insightsFooter =>
      'Insights are generated on your device from your own transactions.';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get txListTitle => 'Transactions';

  @override
  String get txSearchHint => 'Search transactions';

  @override
  String get txFilterAll => 'All';

  @override
  String get txEmptyTitle => 'No transactions found';

  @override
  String get txEmptyBody => 'Try a different search or filter.';

  @override
  String get txFilters => 'Filters';

  @override
  String get txFilterCategory => 'Category';

  @override
  String get txFilterDateRange => 'Date range';

  @override
  String get txFilterFrom => 'From';

  @override
  String get txFilterTo => 'To';

  @override
  String get txFilterAny => 'Any';

  @override
  String get txFilterClearAll => 'Clear all';

  @override
  String get txFilterApply => 'Apply';

  @override
  String get txDetailTitle => 'Transaction Details';

  @override
  String get txDetailType => 'Type';

  @override
  String get txDetailStatus => 'Status';

  @override
  String get txStatusCompleted => 'Completed';

  @override
  String get txDetailNote => 'Note';

  @override
  String get txEdit => 'Edit';

  @override
  String get txDelete => 'Delete';

  @override
  String get txDeleteTitle => 'Delete transaction?';

  @override
  String get txDeleteBody => 'This transaction will be permanently removed.';

  @override
  String get txDeleted => 'Transaction deleted';

  @override
  String get securityTitle => 'Security & Privacy';

  @override
  String get securitySectionAuth => 'Authentication';

  @override
  String get securityChangePin => 'Change PIN';

  @override
  String get securityChangePinSubtitle => 'Update your 6-digit PIN';

  @override
  String get securityBiometric => 'Biometric Login';

  @override
  String get securityBiometricSubtitle => 'Use fingerprint or face to sign in';

  @override
  String get securityTwoFactor => 'Two-Factor Authentication';

  @override
  String get securityTwoFactorSubtitle => 'Add an extra layer of security';

  @override
  String get securitySectionPrivacy => 'Privacy';

  @override
  String get securityChangePassword => 'Change Password';

  @override
  String get securityChangePasswordSubtitle => 'Update your account password';

  @override
  String get securityAppLock => 'App Lock';

  @override
  String get securityAppLockSubtitle => 'Require unlock when opening the app';

  @override
  String get securityHideBalance => 'Hide Balance by Default';

  @override
  String get securityHideBalanceSubtitle =>
      'Keep amounts hidden until revealed';

  @override
  String get rewardsTitle => 'Rewards & Offers';

  @override
  String get rewardsPointsLabel => 'Your Points';

  @override
  String get rewardsTier => 'Gold Tier';

  @override
  String get rewardsRedeem => 'Redeem';

  @override
  String get rewardsSectionOffers => 'Available Offers';

  @override
  String get rewardsClaim => 'Claim';

  @override
  String get rewardsClaimed => 'Offer claimed';

  @override
  String get rewardsOffer1Title => '5% Cashback on Dining';

  @override
  String get rewardsOffer1Body => 'Valid until Aug 31';

  @override
  String get rewardsOffer2Title => 'Free Transfer Fees';

  @override
  String get rewardsOffer2Body => 'For all local transfers this month';

  @override
  String get rewardsOffer3Title => 'Double Points Weekend';

  @override
  String get rewardsOffer3Body => 'Earn 2× points on all spending';

  @override
  String get savingsTitle => 'Savings Goals';

  @override
  String get savingsAddGoal => 'Add Goal';

  @override
  String get savingsTotalSaved => 'Total Saved';

  @override
  String savingsTargetOf(String amount) {
    return 'of KHR $amount target';
  }

  @override
  String get savingsAddFunds => 'Add Funds';

  @override
  String get savingsGoalName => 'Goal Name';

  @override
  String get savingsGoalTarget => 'Target Amount';

  @override
  String get savingsGoalIcon => 'Icon';

  @override
  String get savingsGoalColor => 'Color';

  @override
  String get savingsGoalAdded => 'Goal added';

  @override
  String get savingsFundsAdded => 'Funds added';

  @override
  String get savingsError => 'Something went wrong. Please try again.';

  @override
  String get savingsEmptyTitle => 'No savings goals yet';

  @override
  String get savingsEmptyBody =>
      'Set a target — a trip, an emergency fund, a new phone — and track your progress toward it.';

  @override
  String get savingsGoalVacation => 'Vacation Fund';

  @override
  String get savingsGoalEmergency => 'Emergency Fund';

  @override
  String get savingsGoalLaptop => 'New Laptop';

  @override
  String get savingsGoalMotorbike => 'Motorbike';

  @override
  String get profileSavingsGoals => 'Savings Goals';

  @override
  String get profileSavingsGoalsSubtitle => 'Set targets & track progress';

  @override
  String get profileRecurring => 'Recurring';

  @override
  String get profileRecurringSubtitle => 'Bills, subscriptions & salary';

  @override
  String get recurringTitle => 'Recurring';

  @override
  String get recurringAdd => 'Add Recurring';

  @override
  String get recurringEditTitle => 'Edit Recurring';

  @override
  String get recurringDelete => 'Delete';

  @override
  String get recurringSaved => 'Recurring entry added';

  @override
  String get recurringUpdated => 'Recurring entry updated';

  @override
  String get recurringDeleted => 'Recurring entry removed';

  @override
  String get commonUndo => 'Undo';

  @override
  String recurringActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recurring entries',
      one: '1 recurring entry',
      zero: 'No recurring entries',
    );
    return '$_temp0';
  }

  @override
  String recurringMonthlyEstimate(String amount) {
    return '≈ $amount / month';
  }

  @override
  String recurringDue(String date) {
    return 'Due $date';
  }

  @override
  String get recurringWeekly => 'Weekly';

  @override
  String get recurringMonthly => 'Monthly';

  @override
  String get recurringFrequency => 'Frequency';

  @override
  String get recurringStarts => 'Starts';

  @override
  String get recurringEmptyTitle => 'No recurring entries yet';

  @override
  String get recurringEmptyBody =>
      'Add bills, subscriptions or salary that repeat, and they\'ll show up here.';

  @override
  String get recurringError => 'Something went wrong. Please try again.';

  @override
  String recurringPosted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recurring entries posted',
      one: '1 recurring entry posted',
    );
    return '$_temp0';
  }

  @override
  String get helpTitle => 'Help & Support';

  @override
  String get helpSectionContact => 'Get in Touch';

  @override
  String get helpChat => 'Live Chat';

  @override
  String get helpChatSubtitle => 'Chat with our team';

  @override
  String get helpEmail => 'Email Us';

  @override
  String get helpCall => 'Call Center';

  @override
  String get helpSectionFaq => 'Frequently Asked';

  @override
  String get helpFaq1Q => 'How do I add a new wallet?';

  @override
  String get helpFaq1A =>
      'Open Wallets and tap “+ Add Wallet” to link a new bank or e-wallet account.';

  @override
  String get helpFaq2Q => 'Is my financial data secure?';

  @override
  String get helpFaq2A =>
      'Yes. Your data is encrypted and protected by your PIN and biometrics.';

  @override
  String get helpFaq3Q => 'How do I scan a receipt?';

  @override
  String get helpFaq3A =>
      'Tap the “+” button and choose Scan Receipt to capture and auto-fill a transaction.';

  @override
  String get aboutTitle => 'About Apsara Wallet';

  @override
  String get aboutTagline => 'Smart Finance, Better Future';

  @override
  String get aboutMission =>
      'Empowering every Cambodian to build better financial habits with smart tracking and AI insights.';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutTerms => 'Terms of Service';

  @override
  String get aboutPrivacy => 'Privacy Policy';

  @override
  String get aboutLicenses => 'Open-Source Licenses';

  @override
  String get aboutRate => 'Rate the App';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifMarkAllRead => 'Mark all read';

  @override
  String get notifAllRead => 'All caught up — everything\'s marked read';

  @override
  String get notifToday => 'Today';

  @override
  String get notifEarlier => 'Earlier';

  @override
  String get notifEmptyTitle => 'You\'re all caught up';

  @override
  String get notifEmptyBody => 'New notifications will appear here.';

  @override
  String notifMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String notifHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String get notifYesterday => 'Yesterday';

  @override
  String notifDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get notifTypeRecurringTitle => 'Recurring entries posted';

  @override
  String notifTypeRecurringBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recurring entries were added to your ledger.',
      one: '1 recurring entry was added to your ledger.',
    );
    return '$_temp0';
  }

  @override
  String get notifTypeSavingsDoneTitle => 'Goal reached! 🎉';

  @override
  String notifTypeSavingsDoneBody(String name) {
    return 'You hit your \"$name\" savings goal.';
  }

  @override
  String get notifTypeSavingsHalfTitle => 'Halfway there';

  @override
  String notifTypeSavingsHalfBody(String name) {
    return '\"$name\" is halfway to its target.';
  }

  @override
  String get notifTypeBudgetTitle => 'Budget alert';

  @override
  String notifTypeBudgetBody(String category) {
    return 'You\'ve reached your $category budget for this month.';
  }

  @override
  String get notifTypeSecurityLoginTitle => 'New sign-in';

  @override
  String get notifTypeSecurityLoginBody =>
      'Your account was just signed in to. If this wasn\'t you, reset your password.';

  @override
  String get notifTypeSecurityPasswordTitle => 'Password changed';

  @override
  String get notifTypeSecurityPasswordBody =>
      'Your account password was just changed.';

  @override
  String get notifTypeSecurityProfileTitle => 'Profile updated';

  @override
  String get notifTypeSecurityProfileBody =>
      'Your profile details were updated.';

  @override
  String get notifTxTitle => 'Income recorded';

  @override
  String get notifTxBody => 'KHR 3,500,000 salary was added to your records.';

  @override
  String get notifBudgetTitle => 'Budget alert';

  @override
  String get notifBudgetBody => 'You\'ve used 63% of your monthly budget.';

  @override
  String get notifSecurityTitle => 'New sign-in detected';

  @override
  String get notifSecurityBody =>
      'A new device just signed in to your account.';

  @override
  String get notifRewardTitle => 'Savings milestone';

  @override
  String get notifRewardBody =>
      'You\'ve reached 75% of your Motorbike goal — keep it up!';

  @override
  String get notifInsightTitle => 'Weekly insight ready';

  @override
  String get notifInsightBody =>
      'Your spending report for this week is ready to view.';

  @override
  String get notifBillTitle => 'Upcoming bill';

  @override
  String get notifBillBody =>
      'Your electricity bill of KHR 85,000 is due in 3 days.';

  @override
  String get navHome => 'Home';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navWallets => 'Wallets';

  @override
  String get navProfile => 'Profile';

  @override
  String get navScan => 'Scan';

  @override
  String get dashboardAppBarTitle => 'Dashboard';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get dashboardGreeting => 'Good morning!';

  @override
  String get dashboardTotalBalance => 'Total Balance';

  @override
  String get dashboardMonthOverviewTitle => 'This Month Overview';

  @override
  String get dashboardIncome => 'Income';

  @override
  String get dashboardExpense => 'Expense';

  @override
  String get dashboardBudget => 'Budget';

  @override
  String get dashboardRemaining => 'Remaining';

  @override
  String get dashboardAddIncome => 'Add Income';

  @override
  String get dashboardAddExpense => 'Add Expense';

  @override
  String get dashboardTransfer => 'Transfer';

  @override
  String get dashboardScan => 'Scan';

  @override
  String get dashboardRecentTransactions => 'Recent Transactions';

  @override
  String get dashboardSeeAll => 'See All';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profilePersonalInfo => 'Personal Information';

  @override
  String get profilePersonalInfoSubtitle => 'Name, email & phone';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileChooseAvatar => 'Choose Avatar';

  @override
  String get editProfileNameLabel => 'Full Name';

  @override
  String get editProfileEmailLabel => 'Email';

  @override
  String get editProfilePhoneLabel => 'Phone Number';

  @override
  String get editProfileSave => 'Save Changes';

  @override
  String get editProfileSaved => 'Profile updated';

  @override
  String get editProfileSaveFailed =>
      'Couldn\'t update your profile. Please try again.';

  @override
  String get editProfileNameRequired => 'Please enter your name';

  @override
  String get editProfileEmailInvalid => 'Enter a valid email';

  @override
  String get editProfilePhoneInvalid => 'Enter a valid phone number';

  @override
  String get profileMyWallets => 'My Wallets';

  @override
  String profileLinkedAccounts(int count) {
    return '$count linked accounts';
  }

  @override
  String get profileSecurityPrivacy => 'Security & Privacy';

  @override
  String get profileSecuritySubtitle => 'PIN, biometrics & password';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Language, currency & appearance';

  @override
  String get profileRewardsOffers => 'Rewards & Offers';

  @override
  String get profileSectionSupport => 'Support';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileAboutApp => 'About Apsara Wallet';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutConfirmTitle => 'Sign out?';

  @override
  String get profileSignOutConfirmBody =>
      'You\'ll need to log in again to access your wallet.';

  @override
  String get profileStatsWallets => 'Wallets';

  @override
  String get profileStatsTransactions => 'Transactions';

  @override
  String get profileStatsBudgets => 'Budgets';

  @override
  String profileMemberSince(int year) {
    return 'Member since $year';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrimaryCurrency => 'Primary Currency';

  @override
  String get settingsCurrencyKhr => 'KHR — Cambodian Riel';

  @override
  String get settingsCurrencyUsd => 'USD — US Dollar';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsPushNotifications => 'Push Notifications';

  @override
  String get settingsTransactionAlerts => 'Transaction Alerts';

  @override
  String get settingsBudgetWarnings => 'Budget Warnings';

  @override
  String get settingsPromotions => 'Promotions & Offers';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsBiometricLogin => 'Biometric Login';

  @override
  String get settingsBiometricSubtitle => 'Face ID / fingerprint';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsRateApp => 'Rate Apsara Wallet';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get walletsTitle => 'Wallets';

  @override
  String walletsCountTotal(int count) {
    return '$count total';
  }

  @override
  String walletsWalletCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wallets',
      one: '1 wallet',
    );
    return '$_temp0';
  }

  @override
  String get walletsAddWallet => 'Add Wallet';

  @override
  String get walletCardPrimaryBadge => 'Primary';

  @override
  String get walletBalanceLabel => 'Balance';

  @override
  String get walletRecentActivity => 'Recent Activity';

  @override
  String get walletNoActivity => 'No transactions for this wallet yet';

  @override
  String get walletNameLabel => 'Wallet Name';

  @override
  String get walletNameHint => 'e.g. ABA Bank, Cash';

  @override
  String get walletTypeLabel => 'Type';

  @override
  String get walletTypeBank => 'Bank Account';

  @override
  String get walletTypeCash => 'Cash';

  @override
  String get walletTypeEwallet => 'E-Wallet';

  @override
  String get walletInitialBalance => 'Initial Balance';

  @override
  String get walletBalanceEditLabel => 'Balance';

  @override
  String get walletColorLabel => 'Color';

  @override
  String get walletAdded => 'Wallet added';

  @override
  String get walletsEditWallet => 'Edit Wallet';

  @override
  String get walletEditAction => 'Edit wallet';

  @override
  String get walletDeleteAction => 'Delete wallet';

  @override
  String get walletUpdated => 'Wallet updated';

  @override
  String get walletUpdateFailed =>
      'Couldn\'t update the wallet. Please try again.';

  @override
  String get walletDeleted => 'Wallet deleted';

  @override
  String get walletDeleteConfirmTitle => 'Delete this wallet?';

  @override
  String walletDeleteConfirmBody(String name) {
    return '$name will be removed. This can\'t be undone.';
  }

  @override
  String get walletDeleteHasTransactions =>
      'This wallet still has transactions. Move or delete them first.';

  @override
  String get walletDeleteFailed =>
      'Couldn\'t delete the wallet. Please try again.';

  @override
  String get menuTitle => 'Menu';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsTabOverview => 'Overview';

  @override
  String get analyticsTabCategories => 'Categories';

  @override
  String get analyticsTabTrends => 'Trends';

  @override
  String get analyticsMonthlyTrend => 'Monthly Trend';

  @override
  String get analyticsSpendingByCategory => 'Spending by Category';

  @override
  String get analyticsDailyExpenseTrend => 'Daily Expense Trend';

  @override
  String get analyticsExpenseBreakdown => 'Expense Breakdown';

  @override
  String get analyticsTotalExpense => 'Total Expense';

  @override
  String get analyticsAvgPerDay => 'Avg / Day';

  @override
  String get analyticsPeakDay => 'Peak Day';

  @override
  String get analyticsTotal => 'Total';

  @override
  String get scanReceiptTitle => 'Scan Receipt';

  @override
  String get scanAlignReceipt => 'Align the receipt within the frame';

  @override
  String get scanReadingReceipt => 'Reading your receipt…';

  @override
  String get scanGallery => 'Gallery';

  @override
  String get scanManual => 'Manual';

  @override
  String get scanErrorCapture =>
      'Could not capture the photo. Please try again.';

  @override
  String get scanErrorGallery =>
      'Could not open that image. Please try another.';

  @override
  String get scanErrorOcr =>
      'Could not read the receipt. Try again or enter it manually.';

  @override
  String get scanExpenseSaved => 'Expense saved';

  @override
  String get scanCameraAccessNeeded => 'Camera access needed';

  @override
  String get scanCameraUnavailable => 'Camera unavailable';

  @override
  String get scanCameraDeniedBody =>
      'Enable camera access in Settings, or import a receipt from your gallery.';

  @override
  String get scanCameraUnavailableBody =>
      'Import a receipt from your gallery or enter it manually.';

  @override
  String get scanOpenSettings => 'Open Settings';

  @override
  String get scanReviewTitle => 'Review receipt';

  @override
  String get scanReviewSubtitle =>
      'Check the details, edit anything, then save';

  @override
  String get scanFieldMerchant => 'Merchant';

  @override
  String get scanFieldMerchantHint => 'Merchant name';

  @override
  String get scanFieldDate => 'Date';

  @override
  String get scanFieldDateHint => 'e.g. 19 Jul 2026';

  @override
  String get scanFieldCategory => 'Category';

  @override
  String get scanSaveExpense => 'Save Expense';

  @override
  String get scanRetake => 'Retake';

  @override
  String get scanItemsTitle => 'Items';

  @override
  String get scanSumToTotal => 'Sum → Total';

  @override
  String get scanNoItems => 'No items detected — add them manually if needed.';

  @override
  String get scanItemNameHint => 'Item name';

  @override
  String get scanAddItem => 'Add item';

  @override
  String get scanTotalLabel => 'Total';

  @override
  String get settingsLanguageLabel => 'Language';
}
