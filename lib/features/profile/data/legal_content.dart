import 'package:apsara_wallet_mobile/core/constants/app_constant.dart';

/// One heading + its body paragraphs inside a legal document.
class LegalSection {
  const LegalSection({required this.heading, required this.paragraphs});

  final String heading;
  final List<String> paragraphs;
}

/// A full legal document: a "last updated" stamp, a lead paragraph and an
/// ordered list of sections.
class LegalDocument {
  const LegalDocument({
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });

  final String lastUpdated;
  final String intro;
  final List<LegalSection> sections;
}

/// Static Terms of Service / Privacy Policy content.
///
/// English-only by design: these are contractual documents whose wording is
/// legally significant, so they are kept verbatim rather than run through the
/// UI localisation layer. Update [_lastUpdated] whenever the text changes.
class LegalContent {
  LegalContent._();

  static const String _lastUpdated = '29 July 2026';
  static final String _app = AppConstants.appName;

  static final LegalDocument terms = LegalDocument(
    lastUpdated: _lastUpdated,
    intro:
        'Welcome to $_app. These Terms of Service ("Terms") govern your use '
        'of the $_app mobile application and related services (the '
        '"Service"). By creating an account or using the Service, you agree '
        'to be bound by these Terms.',
    sections: [
      LegalSection(
        heading: '1. Acceptance of Terms',
        paragraphs: [
          'By accessing or using $_app you confirm that you are at least 18 '
              'years old and are capable of entering into a binding '
              'agreement. If you do not agree with any part of these Terms, '
              'please do not use the Service.',
        ],
      ),
      const LegalSection(
        heading: '2. Your Account',
        paragraphs: [
          'You are responsible for maintaining the confidentiality of your '
              'login credentials, PIN and any biometric unlock you enable, '
              'and for all activity that occurs under your account.',
          'Notify us immediately if you suspect unauthorised access. We are '
              'not liable for any loss arising from your failure to keep your '
              'credentials secure.',
        ],
      ),
      LegalSection(
        heading: '3. Use of the Service',
        paragraphs: [
          '$_app is a personal finance and expense-tracking tool. It helps '
              'you record transactions, organise wallets and budgets, and '
              'view analytics about your own spending.',
          'You agree not to misuse the Service, attempt to disrupt it, or '
              'use it for any unlawful purpose, including money laundering or '
              'financing prohibited activities.',
        ],
      ),
      const LegalSection(
        heading: '4. Your Financial Data',
        paragraphs: [
          'The figures, balances and reports shown in the app are recorded '
              'and categorised by you and are provided for informational '
              'purposes only. They do not constitute financial, investment '
              'or tax advice.',
          'You are responsible for the accuracy of the data you enter. '
              'Always verify important figures against your bank or official '
              'statements.',
        ],
      ),
      const LegalSection(
        heading: '5. Availability and Changes',
        paragraphs: [
          'We work to keep the Service available and reliable, but we do not '
              'guarantee uninterrupted access. Features may be added, '
              'changed or removed over time.',
          'We may update these Terms from time to time. Continued use of the '
              'Service after an update means you accept the revised Terms.',
        ],
      ),
      const LegalSection(
        heading: '6. Limitation of Liability',
        paragraphs: [
          'To the maximum extent permitted by law, the Service is provided '
              '"as is" without warranties of any kind, and we are not liable '
              'for indirect, incidental or consequential losses arising from '
              'your use of the Service.',
        ],
      ),
      const LegalSection(
        heading: '7. Termination',
        paragraphs: [
          'You may stop using the Service and delete your account at any '
              'time. We may suspend or terminate access if these Terms are '
              'breached.',
        ],
      ),
    ],
  );

  static final LegalDocument privacy = LegalDocument(
    lastUpdated: _lastUpdated,
    intro:
        'Your privacy matters to us. This Privacy Policy explains what '
        'information $_app collects, how it is used, and the choices you '
        'have. We only collect what is needed to run the Service.',
    sections: [
      const LegalSection(
        heading: '1. Information We Collect',
        paragraphs: [
          'Account information: your name, email address and phone number, '
              'provided when you register.',
          'Financial records you create: transactions, wallets, budgets, '
              'savings goals and categories that you enter into the app.',
          'Device information: basic technical data (such as app version and '
              'device type) used to keep the app secure and working '
              'correctly.',
        ],
      ),
      const LegalSection(
        heading: '2. How We Use Your Information',
        paragraphs: [
          'We use your information to provide core features — recording and '
              'displaying your finances, generating analytics and insights, '
              'and sending notifications you have enabled.',
          'We do not sell your personal or financial data to third parties.',
        ],
      ),
      const LegalSection(
        heading: '3. Data Security',
        paragraphs: [
          'Your credentials are stored using industry-standard hashing, and '
              'sensitive data on your device can be protected with a PIN or '
              'biometric lock that you control.',
          'While we take reasonable measures to protect your data, no method '
              'of transmission or storage is completely secure.',
        ],
      ),
      const LegalSection(
        heading: '4. On-Device Processing',
        paragraphs: [
          'Features such as receipt scanning and spending insights run on '
              'your device wherever possible, so your raw data stays with '
              'you.',
        ],
      ),
      const LegalSection(
        heading: '5. Your Choices and Rights',
        paragraphs: [
          'You can view and edit your profile, export your transactions, and '
              'request deletion of your account and associated data at any '
              'time from within the app.',
          'You can control notification permissions and app-lock settings on '
              'your device.',
        ],
      ),
      const LegalSection(
        heading: '6. Data Retention',
        paragraphs: [
          'We retain your information for as long as your account is active. '
              'When you delete your account, we remove your personal data '
              'except where retention is required by law.',
        ],
      ),
      const LegalSection(
        heading: '7. Changes to This Policy',
        paragraphs: [
          'We may update this Policy as the Service evolves. Material changes '
              'will be highlighted in the app.',
        ],
      ),
    ],
  );
}
