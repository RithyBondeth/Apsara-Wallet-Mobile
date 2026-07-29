import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:apsara_wallet_mobile/core/networks/api_client.dart';
import 'package:apsara_wallet_mobile/core/themes/app_theme.dart';
import 'package:apsara_wallet_mobile/features/profile/data/feedback_api.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/screens/legal_document_screen.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/rate_app_sheet.dart';
import 'package:apsara_wallet_mobile/l10n/generated/app_localizations.dart';

/// Captures what the sheet would POST to `/feedback` without any network.
class _FakeFeedbackApi extends FeedbackApi {
  _FakeFeedbackApi() : super(ApiClient(Dio()));

  int calls = 0;
  int? lastRating;
  String? lastComment;
  String? lastPlatform;

  @override
  Future<bool> submit({
    required int rating,
    String? comment,
    String? appVersion,
    String? platform,
  }) async {
    calls++;
    lastRating = rating;
    lastComment = comment;
    lastPlatform = platform;
    return true;
  }
}

Widget _wrap(
  Widget child, {
  List<Override> overrides = const [],
  Locale? locale,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

Widget _rateHost({required List<Override> overrides}) {
  return _wrap(
    Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showRateAppSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    overrides: overrides,
  );
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    final oldOnError = FlutterError.onError!;
    FlutterError.onError = (details) {
      final msg = details.exception.toString();
      if (msg.contains('google_fonts') ||
          msg.contains('was not found in the application assets')) {
        return;
      }
      oldOnError(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
  }

  testWidgets('Terms of Service renders real content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    await tester.pumpWidget(_wrap(const TermsOfServiceScreen()));
    await settle(tester);

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.textContaining('Last updated'), findsOneWidget);
    expect(find.text('1. Acceptance of Terms'), findsOneWidget);
    // The "coming soon" stub must be gone.
    expect(find.text('Coming soon'), findsNothing);
  });

  testWidgets('Privacy Policy renders real content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    await tester.pumpWidget(_wrap(const PrivacyPolicyScreen()));
    await settle(tester);

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('1. Information We Collect'), findsOneWidget);

    // Contact card is the last item in the scrolling list.
    await tester.scrollUntilVisible(
      find.text('Contact Us'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Contact Us'), findsOneWidget);
  });

  testWidgets('Terms of Service renders in Khmer when locale is km', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    await tester.pumpWidget(
      _wrap(const TermsOfServiceScreen(), locale: const Locale('km')),
    );
    await settle(tester);

    // Localised title + first section heading (Khmer numeral "១").
    expect(find.text('លក្ខខណ្ឌនៃការប្រើប្រាស់'), findsOneWidget);
    expect(find.text('១. ការទទួលយកលក្ខខណ្ឌ'), findsOneWidget);
    // English body must not leak through.
    expect(find.text('1. Acceptance of Terms'), findsNothing);
  });

  testWidgets('Privacy Policy renders in Khmer when locale is km', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    await tester.pumpWidget(
      _wrap(const PrivacyPolicyScreen(), locale: const Locale('km')),
    );
    await settle(tester);

    expect(find.text('គោលការណ៍ឯកជនភាព'), findsOneWidget);
    expect(find.text('១. ព័ត៌មានដែលយើងប្រមូល'), findsOneWidget);
    expect(find.text('1. Information We Collect'), findsNothing);
  });

  testWidgets('Rate sheet: submit disabled until a star is picked', (
    tester,
  ) async {
    final fake = _FakeFeedbackApi();
    await tester.pumpWidget(
      _rateHost(overrides: [feedbackApiProvider.overrideWithValue(fake)]),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Enjoying Apsara Wallet?'), findsOneWidget);

    // With no star selected, tapping submit is a no-op — sheet stays open.
    await tester.tap(find.text('Submit Rating'));
    await tester.pumpAndSettle();
    expect(find.text('Enjoying Apsara Wallet?'), findsOneWidget);
    expect(fake.calls, 0);
  });

  testWidgets('Rate sheet: high rating records and thanks the user', (
    tester,
  ) async {
    final fake = _FakeFeedbackApi();
    await tester.pumpWidget(
      _rateHost(overrides: [feedbackApiProvider.overrideWithValue(fake)]),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // 5 stars → records immediately, no comment step.
    await tester.tap(find.byIcon(Icons.star_outline_rounded).at(4));
    await tester.pump();
    await tester.tap(find.text('Submit Rating'));
    await tester.pumpAndSettle();

    expect(fake.calls, 1);
    expect(fake.lastRating, 5);
    expect(fake.lastComment, isNull);
    expect(find.text('Enjoying Apsara Wallet?'), findsNothing); // closed
    expect(find.text('Thanks for your feedback!'), findsOneWidget);
  });

  testWidgets('Rate sheet: low rating opens comment step and sends comment', (
    tester,
  ) async {
    final fake = _FakeFeedbackApi();
    await tester.pumpWidget(
      _rateHost(overrides: [feedbackApiProvider.overrideWithValue(fake)]),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // 2 stars → advances to the in-app comment step (no send yet).
    await tester.tap(find.byIcon(Icons.star_outline_rounded).at(1));
    await tester.pump();
    await tester.tap(find.text('Submit Rating'));
    await tester.pumpAndSettle();

    expect(find.text('Sorry to hear that'), findsOneWidget);
    expect(fake.calls, 0);

    await tester.enterText(find.byType(TextField), 'Search was hard to find');
    await tester.tap(find.text('Send Feedback'));
    await tester.pumpAndSettle();

    expect(fake.calls, 1);
    expect(fake.lastRating, 2);
    expect(fake.lastComment, 'Search was hard to find');
    expect(find.text('Thanks for your feedback!'), findsOneWidget);
  });
}
