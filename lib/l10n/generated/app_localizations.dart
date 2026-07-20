import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @commonLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get commonLogin;

  /// No description provided for @commonGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get commonGetStarted;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get commonForgotPassword;

  /// No description provided for @authIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone Number'**
  String get authIdentifierLabel;

  /// No description provided for @authIdentifierHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email or phone number'**
  String get authIdentifierHint;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get authContinueWithFacebook;

  /// No description provided for @authOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get authOrContinueWith;

  /// No description provided for @welcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeGreeting;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Your smart companion for\nbetter financial management.'**
  String get welcomeTagline;

  /// No description provided for @welcomeNewHerePrompt.
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get welcomeNewHerePrompt;

  /// No description provided for @welcomeCreateAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get welcomeCreateAccountCta;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'All your money,\nbeautifully in one place'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Track balances, cards and spending across USD and KHR — with the elegance Apsara brings to every detail.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Send & receive\nin a few taps'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Instant transfers and QR payments across Cambodia. Fast, secure, and effortless — day or night.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Insights that\ngrow your wealth'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Smart budgets and clear analytics turn everyday spending into confident financial decisions.'**
  String get onboardingBody3;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Please login to continue.'**
  String get loginSubtitle;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccountPrompt;

  /// No description provided for @loginSignUpCta.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUpCta;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Apsara Wallet in a few easy steps.'**
  String get registerSubtitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerNameLabel;

  /// No description provided for @registerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get registerNameHint;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get registerPasswordHint;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerHasAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHasAccountPrompt;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email or phone linked to your account and we\'ll send you a reset code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSendCta.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get forgotPasswordSendCta;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordNewLabel;

  /// No description provided for @resetPasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get resetPasswordNewHint;

  /// No description provided for @resetPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get resetPasswordConfirmLabel;

  /// No description provided for @resetPasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get resetPasswordConfirmHint;

  /// No description provided for @resetPasswordSaveCta.
  ///
  /// In en, this message translates to:
  /// **'Save New Password'**
  String get resetPasswordSaveCta;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to your email or phone. Enter it below to continue.'**
  String get otpSubtitle;

  /// No description provided for @otpResendPrompt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get otpResendPrompt;

  /// No description provided for @otpResendCta.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get otpResendCta;

  /// No description provided for @otpVerifyCta.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerifyCta;

  /// No description provided for @pinLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Your PIN'**
  String get pinLoginTitle;

  /// No description provided for @pinLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back — unlock your wallet.'**
  String get pinLoginSubtitle;

  /// No description provided for @pinLoginUsePasswordCta.
  ///
  /// In en, this message translates to:
  /// **'Use password instead'**
  String get pinLoginUsePasswordCta;

  /// No description provided for @pinSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your PIN'**
  String get pinSetupTitle;

  /// No description provided for @pinSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A 4-digit PIN keeps your wallet extra safe.'**
  String get pinSetupSubtitle;

  /// No description provided for @biometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get biometricTitle;

  /// No description provided for @biometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your fingerprint or face — fast, secure and effortless.'**
  String get biometricSubtitle;

  /// No description provided for @biometricEnableCta.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric'**
  String get biometricEnableCta;

  /// No description provided for @biometricLaterCta.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get biometricLaterCta;

  /// No description provided for @addTxTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTxTitle;

  /// No description provided for @addTxAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addTxAmount;

  /// No description provided for @addTxCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addTxCategory;

  /// No description provided for @addTxWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get addTxWallet;

  /// No description provided for @addTxFromWallet.
  ///
  /// In en, this message translates to:
  /// **'From Wallet'**
  String get addTxFromWallet;

  /// No description provided for @addTxToWallet.
  ///
  /// In en, this message translates to:
  /// **'To Wallet'**
  String get addTxToWallet;

  /// No description provided for @addTxDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get addTxDateTime;

  /// No description provided for @addTxTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get addTxTitleLabel;

  /// No description provided for @addTxTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Coffee, Groceries, Taxi'**
  String get addTxTitleHint;

  /// No description provided for @addTxNote.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get addTxNote;

  /// No description provided for @addTxNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What was this for?'**
  String get addTxNoteHint;

  /// No description provided for @addTxReceipt.
  ///
  /// In en, this message translates to:
  /// **'Add Receipt'**
  String get addTxReceipt;

  /// No description provided for @addTxScanOrUpload.
  ///
  /// In en, this message translates to:
  /// **'Scan or upload receipt'**
  String get addTxScanOrUpload;

  /// No description provided for @addTxSave.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get addTxSave;

  /// No description provided for @addTxSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved'**
  String get addTxSaved;

  /// No description provided for @addTxChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose Category'**
  String get addTxChooseCategory;

  /// No description provided for @addTxChooseWallet.
  ///
  /// In en, this message translates to:
  /// **'Choose Wallet'**
  String get addTxChooseWallet;

  /// No description provided for @addTxChooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get addTxChooseCurrency;

  /// No description provided for @categoryFoodDining.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get categoryFoodDining;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills & Utilities'**
  String get categoryBills;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get categoryPersonalCare;

  /// No description provided for @categoryGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts & Donations'**
  String get categoryGifts;

  /// No description provided for @categoryOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get categoryOthers;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categoryInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get categoryInvestment;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @analyticsRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get analyticsRangeWeek;

  /// No description provided for @analyticsRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get analyticsRangeMonth;

  /// No description provided for @analyticsRangeYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get analyticsRangeYear;

  /// No description provided for @analyticsSelectRange.
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get analyticsSelectRange;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// No description provided for @budgetAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get budgetAdd;

  /// No description provided for @budgetProgress.
  ///
  /// In en, this message translates to:
  /// **'Budget Progress'**
  String get budgetProgress;

  /// No description provided for @budgetSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get budgetSpent;

  /// No description provided for @budgetByCategory.
  ///
  /// In en, this message translates to:
  /// **'Budget by Category'**
  String get budgetByCategory;

  /// No description provided for @budgetMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get budgetMonthlyLimit;

  /// No description provided for @budgetAdded.
  ///
  /// In en, this message translates to:
  /// **'Budget added'**
  String get budgetAdded;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoriesTitle;

  /// No description provided for @categoriesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get categoriesSearchHint;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get categoriesNewTitle;

  /// No description provided for @categoriesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoriesNameLabel;

  /// No description provided for @categoriesIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoriesIconLabel;

  /// No description provided for @categoriesColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoriesColorLabel;

  /// No description provided for @categoriesSaved.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get categoriesSaved;

  /// No description provided for @profileCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get profileCategories;

  /// No description provided for @profileCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage icons & colors'**
  String get profileCategoriesSubtitle;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get insightsTitle;

  /// No description provided for @insightsToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Insight'**
  String get insightsToday;

  /// No description provided for @insightsTodayBody1.
  ///
  /// In en, this message translates to:
  /// **'You spent 18% more on Food & Dining compared to last month.'**
  String get insightsTodayBody1;

  /// No description provided for @insightsTodayBody2.
  ///
  /// In en, this message translates to:
  /// **'Try cooking at home more to save around KHR 200,000 this month.'**
  String get insightsTodayBody2;

  /// No description provided for @insightsHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Financial Health Score'**
  String get insightsHealthScore;

  /// No description provided for @insightsScoreGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get insightsScoreGood;

  /// No description provided for @insightsHealthBody1.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the right track!'**
  String get insightsHealthBody1;

  /// No description provided for @insightsHealthBody2.
  ///
  /// In en, this message translates to:
  /// **'Keep it up and you will reach your goals soon.'**
  String get insightsHealthBody2;

  /// No description provided for @insightsMore.
  ///
  /// In en, this message translates to:
  /// **'More Insights'**
  String get insightsMore;

  /// No description provided for @insightsWeekendTip.
  ///
  /// In en, this message translates to:
  /// **'Your spending is highest on Sunday. Try planning your budget for weekends.'**
  String get insightsWeekendTip;

  /// No description provided for @insightsSubscriptionsTip.
  ///
  /// In en, this message translates to:
  /// **'3 subscriptions renew this week — totalling KHR 62,000.'**
  String get insightsSubscriptionsTip;

  /// No description provided for @insightsSavingTip.
  ///
  /// In en, this message translates to:
  /// **'Setting aside KHR 50,000 weekly would reach your savings goal by October.'**
  String get insightsSavingTip;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @txListTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get txListTitle;

  /// No description provided for @txSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get txSearchHint;

  /// No description provided for @txFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get txFilterAll;

  /// No description provided for @txEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get txEmptyTitle;

  /// No description provided for @txEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter.'**
  String get txEmptyBody;

  /// No description provided for @txDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get txDetailTitle;

  /// No description provided for @txDetailType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get txDetailType;

  /// No description provided for @txDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get txDetailStatus;

  /// No description provided for @txStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get txStatusCompleted;

  /// No description provided for @txDetailNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get txDetailNote;

  /// No description provided for @txEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get txEdit;

  /// No description provided for @txDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get txDelete;

  /// No description provided for @txDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get txDeleteTitle;

  /// No description provided for @txDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This transaction will be permanently removed.'**
  String get txDeleteBody;

  /// No description provided for @txDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get txDeleted;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get securityTitle;

  /// No description provided for @securitySectionAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get securitySectionAuth;

  /// No description provided for @securityChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get securityChangePin;

  /// No description provided for @securityChangePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your 6-digit PIN'**
  String get securityChangePinSubtitle;

  /// No description provided for @securityBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get securityBiometric;

  /// No description provided for @securityBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face to sign in'**
  String get securityBiometricSubtitle;

  /// No description provided for @securityTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get securityTwoFactor;

  /// No description provided for @securityTwoFactorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add an extra layer of security'**
  String get securityTwoFactorSubtitle;

  /// No description provided for @securitySectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get securitySectionPrivacy;

  /// No description provided for @securityChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get securityChangePassword;

  /// No description provided for @securityChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get securityChangePasswordSubtitle;

  /// No description provided for @securityAppLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get securityAppLock;

  /// No description provided for @securityAppLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require unlock when opening the app'**
  String get securityAppLockSubtitle;

  /// No description provided for @securityHideBalance.
  ///
  /// In en, this message translates to:
  /// **'Hide Balance by Default'**
  String get securityHideBalance;

  /// No description provided for @securityHideBalanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep amounts hidden until revealed'**
  String get securityHideBalanceSubtitle;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rewards & Offers'**
  String get rewardsTitle;

  /// No description provided for @rewardsPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Points'**
  String get rewardsPointsLabel;

  /// No description provided for @rewardsTier.
  ///
  /// In en, this message translates to:
  /// **'Gold Tier'**
  String get rewardsTier;

  /// No description provided for @rewardsRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get rewardsRedeem;

  /// No description provided for @rewardsSectionOffers.
  ///
  /// In en, this message translates to:
  /// **'Available Offers'**
  String get rewardsSectionOffers;

  /// No description provided for @rewardsClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get rewardsClaim;

  /// No description provided for @rewardsClaimed.
  ///
  /// In en, this message translates to:
  /// **'Offer claimed'**
  String get rewardsClaimed;

  /// No description provided for @rewardsOffer1Title.
  ///
  /// In en, this message translates to:
  /// **'5% Cashback on Dining'**
  String get rewardsOffer1Title;

  /// No description provided for @rewardsOffer1Body.
  ///
  /// In en, this message translates to:
  /// **'Valid until Aug 31'**
  String get rewardsOffer1Body;

  /// No description provided for @rewardsOffer2Title.
  ///
  /// In en, this message translates to:
  /// **'Free Transfer Fees'**
  String get rewardsOffer2Title;

  /// No description provided for @rewardsOffer2Body.
  ///
  /// In en, this message translates to:
  /// **'For all local transfers this month'**
  String get rewardsOffer2Body;

  /// No description provided for @rewardsOffer3Title.
  ///
  /// In en, this message translates to:
  /// **'Double Points Weekend'**
  String get rewardsOffer3Title;

  /// No description provided for @rewardsOffer3Body.
  ///
  /// In en, this message translates to:
  /// **'Earn 2× points on all spending'**
  String get rewardsOffer3Body;

  /// No description provided for @savingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsTitle;

  /// No description provided for @savingsAddGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get savingsAddGoal;

  /// No description provided for @savingsTotalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total Saved'**
  String get savingsTotalSaved;

  /// No description provided for @savingsTargetOf.
  ///
  /// In en, this message translates to:
  /// **'of KHR {amount} target'**
  String savingsTargetOf(String amount);

  /// No description provided for @savingsAddFunds.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get savingsAddFunds;

  /// No description provided for @savingsGoalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get savingsGoalName;

  /// No description provided for @savingsGoalTarget.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get savingsGoalTarget;

  /// No description provided for @savingsGoalAdded.
  ///
  /// In en, this message translates to:
  /// **'Goal added'**
  String get savingsGoalAdded;

  /// No description provided for @savingsFundsAdded.
  ///
  /// In en, this message translates to:
  /// **'Funds added'**
  String get savingsFundsAdded;

  /// No description provided for @savingsGoalVacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation Fund'**
  String get savingsGoalVacation;

  /// No description provided for @savingsGoalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get savingsGoalEmergency;

  /// No description provided for @savingsGoalLaptop.
  ///
  /// In en, this message translates to:
  /// **'New Laptop'**
  String get savingsGoalLaptop;

  /// No description provided for @savingsGoalMotorbike.
  ///
  /// In en, this message translates to:
  /// **'Motorbike'**
  String get savingsGoalMotorbike;

  /// No description provided for @profileSavingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get profileSavingsGoals;

  /// No description provided for @profileSavingsGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set targets & track progress'**
  String get profileSavingsGoalsSubtitle;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpTitle;

  /// No description provided for @helpSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Get in Touch'**
  String get helpSectionContact;

  /// No description provided for @helpChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get helpChat;

  /// No description provided for @helpChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with our team'**
  String get helpChatSubtitle;

  /// No description provided for @helpEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get helpEmail;

  /// No description provided for @helpCall.
  ///
  /// In en, this message translates to:
  /// **'Call Center'**
  String get helpCall;

  /// No description provided for @helpSectionFaq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked'**
  String get helpSectionFaq;

  /// No description provided for @helpFaq1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new wallet?'**
  String get helpFaq1Q;

  /// No description provided for @helpFaq1A.
  ///
  /// In en, this message translates to:
  /// **'Open Wallets and tap “+ Add Wallet” to link a new bank or e-wallet account.'**
  String get helpFaq1A;

  /// No description provided for @helpFaq2Q.
  ///
  /// In en, this message translates to:
  /// **'Is my financial data secure?'**
  String get helpFaq2Q;

  /// No description provided for @helpFaq2A.
  ///
  /// In en, this message translates to:
  /// **'Yes. Your data is encrypted and protected by your PIN and biometrics.'**
  String get helpFaq2A;

  /// No description provided for @helpFaq3Q.
  ///
  /// In en, this message translates to:
  /// **'How do I scan a receipt?'**
  String get helpFaq3Q;

  /// No description provided for @helpFaq3A.
  ///
  /// In en, this message translates to:
  /// **'Tap the “+” button and choose Scan Receipt to capture and auto-fill a transaction.'**
  String get helpFaq3A;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Apsara Wallet'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Finance, Better Future'**
  String get aboutTagline;

  /// No description provided for @aboutMission.
  ///
  /// In en, this message translates to:
  /// **'Empowering every Cambodian to build better financial habits with smart tracking and AI insights.'**
  String get aboutMission;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get aboutTerms;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacy;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-Source Licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutRate.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get aboutRate;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notifMarkAllRead;

  /// No description provided for @notifAllRead.
  ///
  /// In en, this message translates to:
  /// **'All caught up — everything\'s marked read'**
  String get notifAllRead;

  /// No description provided for @notifToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notifToday;

  /// No description provided for @notifEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notifEarlier;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New notifications will appear here.'**
  String get notifEmptyBody;

  /// No description provided for @notifMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String notifMinutesAgo(int count);

  /// No description provided for @notifHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notifHoursAgo(int count);

  /// No description provided for @notifYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notifYesterday;

  /// No description provided for @notifDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String notifDaysAgo(int count);

  /// No description provided for @notifTxTitle.
  ///
  /// In en, this message translates to:
  /// **'Income recorded'**
  String get notifTxTitle;

  /// No description provided for @notifTxBody.
  ///
  /// In en, this message translates to:
  /// **'KHR 3,500,000 salary was added to your records.'**
  String get notifTxBody;

  /// No description provided for @notifBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget alert'**
  String get notifBudgetTitle;

  /// No description provided for @notifBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used 63% of your monthly budget.'**
  String get notifBudgetBody;

  /// No description provided for @notifSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'New sign-in detected'**
  String get notifSecurityTitle;

  /// No description provided for @notifSecurityBody.
  ///
  /// In en, this message translates to:
  /// **'A new device just signed in to your account.'**
  String get notifSecurityBody;

  /// No description provided for @notifRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings milestone'**
  String get notifRewardTitle;

  /// No description provided for @notifRewardBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached 75% of your Motorbike goal — keep it up!'**
  String get notifRewardBody;

  /// No description provided for @notifInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly insight ready'**
  String get notifInsightTitle;

  /// No description provided for @notifInsightBody.
  ///
  /// In en, this message translates to:
  /// **'Your spending report for this week is ready to view.'**
  String get notifInsightBody;

  /// No description provided for @notifBillTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming bill'**
  String get notifBillTitle;

  /// No description provided for @notifBillBody.
  ///
  /// In en, this message translates to:
  /// **'Your electricity bill of KHR 85,000 is due in 3 days.'**
  String get notifBillBody;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get navWallets;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @dashboardAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardAppBarTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good morning!'**
  String get dashboardGreeting;

  /// No description provided for @dashboardTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get dashboardTotalBalance;

  /// No description provided for @dashboardMonthOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'This Month Overview'**
  String get dashboardMonthOverviewTitle;

  /// No description provided for @dashboardIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get dashboardIncome;

  /// No description provided for @dashboardExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get dashboardExpense;

  /// No description provided for @dashboardBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get dashboardBudget;

  /// No description provided for @dashboardAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get dashboardAddIncome;

  /// No description provided for @dashboardAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get dashboardAddExpense;

  /// No description provided for @dashboardTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get dashboardTransfer;

  /// No description provided for @dashboardScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get dashboardScan;

  /// No description provided for @dashboardRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get dashboardRecentTransactions;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get dashboardSeeAll;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profilePersonalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, email & phone'**
  String get profilePersonalInfoSubtitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileChooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get editProfileChooseAvatar;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get editProfileEmailLabel;

  /// No description provided for @editProfilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get editProfilePhoneLabel;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProfileSave;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get editProfileSaved;

  /// No description provided for @editProfileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get editProfileNameRequired;

  /// No description provided for @editProfileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get editProfileEmailInvalid;

  /// No description provided for @editProfilePhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get editProfilePhoneInvalid;

  /// No description provided for @profileMyWallets.
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get profileMyWallets;

  /// No description provided for @profileLinkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'{count} linked accounts'**
  String profileLinkedAccounts(int count);

  /// No description provided for @profileSecurityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get profileSecurityPrivacy;

  /// No description provided for @profileSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'PIN, biometrics & password'**
  String get profileSecuritySubtitle;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, currency & appearance'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileRewardsOffers.
  ///
  /// In en, this message translates to:
  /// **'Rewards & Offers'**
  String get profileRewardsOffers;

  /// No description provided for @profileSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSectionSupport;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Apsara Wallet'**
  String get profileAboutApp;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutConfirmTitle;

  /// No description provided for @profileSignOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to log in again to access your wallet.'**
  String get profileSignOutConfirmBody;

  /// No description provided for @profileStatsWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get profileStatsWallets;

  /// No description provided for @profileStatsTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get profileStatsTransactions;

  /// No description provided for @profileStatsBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get profileStatsBudgets;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPrimaryCurrency.
  ///
  /// In en, this message translates to:
  /// **'Primary Currency'**
  String get settingsPrimaryCurrency;

  /// No description provided for @settingsCurrencyKhr.
  ///
  /// In en, this message translates to:
  /// **'KHR — Cambodian Riel'**
  String get settingsCurrencyKhr;

  /// No description provided for @settingsCurrencyUsd.
  ///
  /// In en, this message translates to:
  /// **'USD — US Dollar'**
  String get settingsCurrencyUsd;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsTransactionAlerts.
  ///
  /// In en, this message translates to:
  /// **'Transaction Alerts'**
  String get settingsTransactionAlerts;

  /// No description provided for @settingsBudgetWarnings.
  ///
  /// In en, this message translates to:
  /// **'Budget Warnings'**
  String get settingsBudgetWarnings;

  /// No description provided for @settingsPromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions & Offers'**
  String get settingsPromotions;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get settingsBiometricLogin;

  /// No description provided for @settingsBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Face ID / fingerprint'**
  String get settingsBiometricSubtitle;

  /// No description provided for @settingsChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Apsara Wallet'**
  String get settingsRateApp;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @walletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get walletsTitle;

  /// No description provided for @walletsCountTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String walletsCountTotal(int count);

  /// No description provided for @walletsWalletCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 wallet} other{{count} wallets}}'**
  String walletsWalletCount(int count);

  /// No description provided for @walletsAddWallet.
  ///
  /// In en, this message translates to:
  /// **'Add Wallet'**
  String get walletsAddWallet;

  /// No description provided for @walletCardPrimaryBadge.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get walletCardPrimaryBadge;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get analyticsTabOverview;

  /// No description provided for @analyticsTabCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get analyticsTabCategories;

  /// No description provided for @analyticsTabTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get analyticsTabTrends;

  /// No description provided for @analyticsMonthlyTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Trend'**
  String get analyticsMonthlyTrend;

  /// No description provided for @analyticsSpendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get analyticsSpendingByCategory;

  /// No description provided for @analyticsDailyExpenseTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily Expense Trend'**
  String get analyticsDailyExpenseTrend;

  /// No description provided for @analyticsExpenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get analyticsExpenseBreakdown;

  /// No description provided for @analyticsTotalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get analyticsTotalExpense;

  /// No description provided for @analyticsAvgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg / Day'**
  String get analyticsAvgPerDay;

  /// No description provided for @analyticsPeakDay.
  ///
  /// In en, this message translates to:
  /// **'Peak Day'**
  String get analyticsPeakDay;

  /// No description provided for @analyticsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get analyticsTotal;

  /// No description provided for @scanReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceiptTitle;

  /// No description provided for @scanAlignReceipt.
  ///
  /// In en, this message translates to:
  /// **'Align the receipt within the frame'**
  String get scanAlignReceipt;

  /// No description provided for @scanReadingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Reading your receipt…'**
  String get scanReadingReceipt;

  /// No description provided for @scanGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get scanGallery;

  /// No description provided for @scanManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get scanManual;

  /// No description provided for @scanErrorCapture.
  ///
  /// In en, this message translates to:
  /// **'Could not capture the photo. Please try again.'**
  String get scanErrorCapture;

  /// No description provided for @scanErrorGallery.
  ///
  /// In en, this message translates to:
  /// **'Could not open that image. Please try another.'**
  String get scanErrorGallery;

  /// No description provided for @scanErrorOcr.
  ///
  /// In en, this message translates to:
  /// **'Could not read the receipt. Try again or enter it manually.'**
  String get scanErrorOcr;

  /// No description provided for @scanExpenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get scanExpenseSaved;

  /// No description provided for @scanCameraAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get scanCameraAccessNeeded;

  /// No description provided for @scanCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get scanCameraUnavailable;

  /// No description provided for @scanCameraDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Enable camera access in Settings, or import a receipt from your gallery.'**
  String get scanCameraDeniedBody;

  /// No description provided for @scanCameraUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Import a receipt from your gallery or enter it manually.'**
  String get scanCameraUnavailableBody;

  /// No description provided for @scanOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get scanOpenSettings;

  /// No description provided for @scanReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review receipt'**
  String get scanReviewTitle;

  /// No description provided for @scanReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check the details, edit anything, then save'**
  String get scanReviewSubtitle;

  /// No description provided for @scanFieldMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get scanFieldMerchant;

  /// No description provided for @scanFieldMerchantHint.
  ///
  /// In en, this message translates to:
  /// **'Merchant name'**
  String get scanFieldMerchantHint;

  /// No description provided for @scanFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get scanFieldDate;

  /// No description provided for @scanFieldDateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 19 Jul 2026'**
  String get scanFieldDateHint;

  /// No description provided for @scanFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get scanFieldCategory;

  /// No description provided for @scanSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get scanSaveExpense;

  /// No description provided for @scanRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get scanRetake;

  /// No description provided for @scanItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get scanItemsTitle;

  /// No description provided for @scanSumToTotal.
  ///
  /// In en, this message translates to:
  /// **'Sum → Total'**
  String get scanSumToTotal;

  /// No description provided for @scanNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items detected — add them manually if needed.'**
  String get scanNoItems;

  /// No description provided for @scanItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get scanItemNameHint;

  /// No description provided for @scanAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get scanAddItem;

  /// No description provided for @scanTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get scanTotalLabel;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
