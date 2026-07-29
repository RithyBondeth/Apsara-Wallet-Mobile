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

/// Static Terms of Service / Privacy Policy content, localised to the app's
/// two languages.
///
/// The wording lives here rather than in the ARB files: these are long-form
/// contractual documents (not short UI labels), so keeping each language's
/// full text as one block is far more readable and reviewable than dozens of
/// ARB keys. Pass the active language code (`en` / `km`) — resolve it with
/// `Localizations.localeOf(context).languageCode`. Update the `_lastUpdated*`
/// stamps whenever the text changes.
class LegalContent {
  LegalContent._();

  static const String _app = AppConstants.appName; // brand name, not localised

  static LegalDocument terms(String languageCode) =>
      languageCode == 'km' ? _termsKm : _termsEn;

  static LegalDocument privacy(String languageCode) =>
      languageCode == 'km' ? _privacyKm : _privacyEn;

  // ===========================================================================
  // ENGLISH
  // ===========================================================================
  static const String _lastUpdatedEn = '29 July 2026';

  static final LegalDocument _termsEn = LegalDocument(
    lastUpdated: _lastUpdatedEn,
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

  static final LegalDocument _privacyEn = LegalDocument(
    lastUpdated: _lastUpdatedEn,
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

  // ===========================================================================
  // ខ្មែរ (KHMER)
  // ===========================================================================
  static const String _lastUpdatedKm = '២៩ កក្កដា ២០២៦';

  static final LegalDocument _termsKm = LegalDocument(
    lastUpdated: _lastUpdatedKm,
    intro:
        'សូមស្វាគមន៍មកកាន់ $_app។ លក្ខខណ្ឌនៃការប្រើប្រាស់ ("លក្ខខណ្ឌ") ទាំងនេះ '
        'គ្រប់គ្រងការប្រើប្រាស់កម្មវិធីទូរស័ព្ទ $_app និងសេវាកម្មពាក់ព័ន្ធ '
        '("សេវាកម្ម") របស់អ្នក។ ដោយបង្កើតគណនី ឬប្រើប្រាស់សេវាកម្មនេះ '
        'អ្នកយល់ព្រមគោរពតាមលក្ខខណ្ឌទាំងនេះ។',
    sections: [
      LegalSection(
        heading: '១. ការទទួលយកលក្ខខណ្ឌ',
        paragraphs: [
          'ដោយចូលប្រើ ឬប្រើប្រាស់ $_app អ្នកបញ្ជាក់ថាអ្នកមានអាយុយ៉ាងតិច ១៨ ឆ្នាំ '
              'និងមានសមត្ថភាពក្នុងការចូលធ្វើកិច្ចព្រមព្រៀងដែលមានកាតព្វកិច្ច។ '
              'ប្រសិនបើអ្នកមិនយល់ព្រមនឹងផ្នែកណាមួយនៃលក្ខខណ្ឌទាំងនេះ '
              'សូមកុំប្រើប្រាស់សេវាកម្មនេះឡើយ។',
        ],
      ),
      const LegalSection(
        heading: '២. គណនីរបស់អ្នក',
        paragraphs: [
          'អ្នកមានទំនួលខុសត្រូវក្នុងការរក្សាការសម្ងាត់នៃព័ត៌មានចូលគណនី '
              'លេខសម្ងាត់ (PIN) និងការដោះសោជីវមាត្រណាមួយដែលអ្នកបានបើក '
              'ព្រមទាំងសកម្មភាពទាំងអស់ដែលកើតឡើងក្រោមគណនីរបស់អ្នក។',
          'សូមជូនដំណឹងមកយើងភ្លាមៗ ប្រសិនបើអ្នកសង្ស័យថាមានការចូលប្រើ '
              'ដោយគ្មានការអនុញ្ញាត។ យើងមិនទទួលខុសត្រូវចំពោះការបាត់បង់ណាមួយ '
              'ដែលបណ្ដាលមកពីការខកខានរបស់អ្នកក្នុងការរក្សាព័ត៌មានសម្ងាត់ '
              'ឱ្យមានសុវត្ថិភាពឡើយ។',
        ],
      ),
      LegalSection(
        heading: '៣. ការប្រើប្រាស់សេវាកម្ម',
        paragraphs: [
          '$_app គឺជាឧបករណ៍គ្រប់គ្រងហិរញ្ញវត្ថុផ្ទាល់ខ្លួន និងតាមដានចំណាយ។ '
              'វាជួយអ្នកកត់ត្រាប្រតិបត្តិការ រៀបចំកាបូប និងថវិកា '
              'ព្រមទាំងមើលការវិភាគអំពីការចំណាយផ្ទាល់ខ្លួនរបស់អ្នក។',
          'អ្នកយល់ព្រមមិនប្រើប្រាស់សេវាកម្មនេះខុសវិធី មិនប៉ុនប៉ងបង្អាក់វា '
              'ឬប្រើវាសម្រាប់គោលបំណងខុសច្បាប់ណាមួយ រួមទាំងការលាងលុយ '
              'ឬការផ្ដល់ហិរញ្ញប្បទានដល់សកម្មភាពហាមឃាត់។',
        ],
      ),
      const LegalSection(
        heading: '៤. ទិន្នន័យហិរញ្ញវត្ថុរបស់អ្នក',
        paragraphs: [
          'តួលេខ សមតុល្យ និងរបាយការណ៍ដែលបង្ហាញក្នុងកម្មវិធី '
              'ត្រូវបានកត់ត្រា និងចាត់ថ្នាក់ដោយអ្នក '
              'ហើយផ្ដល់ជូនសម្រាប់គោលបំណងផ្ដល់ព័ត៌មានតែប៉ុណ្ណោះ។ '
              'វាមិនមែនជាការណែនាំផ្នែកហិរញ្ញវត្ថុ ការវិនិយោគ ឬពន្ធដារឡើយ។',
          'អ្នកមានទំនួលខុសត្រូវចំពោះភាពត្រឹមត្រូវនៃទិន្នន័យដែលអ្នកបញ្ចូល។ '
              'សូមផ្ទៀងផ្ទាត់តួលេខសំខាន់ៗជាមួយធនាគារ '
              'ឬរបាយការណ៍ផ្លូវការរបស់អ្នកជានិច្ច។',
        ],
      ),
      const LegalSection(
        heading: '៥. ភាពអាចប្រើបាន និងការផ្លាស់ប្ដូរ',
        paragraphs: [
          'យើងខិតខំរក្សាសេវាកម្មឱ្យអាចប្រើប្រាស់បាន និងអាចទុកចិត្តបាន '
              'ប៉ុន្តែយើងមិនធានាការចូលប្រើដោយគ្មានការរអាក់រអួលឡើយ។ '
              'មុខងារនានាអាចត្រូវបានបន្ថែម ផ្លាស់ប្ដូរ ឬដកចេញតាមពេលវេលា។',
          'យើងអាចធ្វើបច្ចុប្បន្នភាពលក្ខខណ្ឌទាំងនេះ ពីពេលមួយទៅពេលមួយ។ '
              'ការបន្តប្រើប្រាស់សេវាកម្មបន្ទាប់ពីការធ្វើបច្ចុប្បន្នភាព '
              'មានន័យថាអ្នកទទួលយកលក្ខខណ្ឌដែលបានកែប្រែ។',
        ],
      ),
      const LegalSection(
        heading: '៦. ការកំណត់ការទទួលខុសត្រូវ',
        paragraphs: [
          'ក្នុងវិសាលភាពអតិបរមាដែលច្បាប់អនុញ្ញាត សេវាកម្មនេះត្រូវបានផ្ដល់ជូន '
              '"ដូចដែលមាន" ដោយគ្មានការធានាណាមួយឡើយ '
              'ហើយយើងមិនទទួលខុសត្រូវចំពោះការបាត់បង់ដោយប្រយោល ដោយចៃដន្យ '
              'ឬជាលទ្ធផលបន្ទាប់បន្សំ '
              'ដែលបណ្ដាលមកពីការប្រើប្រាស់សេវាកម្មរបស់អ្នកឡើយ។',
        ],
      ),
      const LegalSection(
        heading: '៧. ការបញ្ចប់',
        paragraphs: [
          'អ្នកអាចឈប់ប្រើប្រាស់សេវាកម្ម និងលុបគណនីរបស់អ្នកនៅពេលណាក៏បាន។ '
              'យើងអាចផ្អាក ឬបញ្ចប់ការចូលប្រើ '
              'ប្រសិនបើលក្ខខណ្ឌទាំងនេះត្រូវបានបំពាន។',
        ],
      ),
    ],
  );

  static final LegalDocument _privacyKm = LegalDocument(
    lastUpdated: _lastUpdatedKm,
    intro:
        'ឯកជនភាពរបស់អ្នកមានសារៈសំខាន់សម្រាប់យើង។ គោលការណ៍ឯកជនភាពនេះពន្យល់អំពី '
        'ព័ត៌មានអ្វីខ្លះដែល $_app ប្រមូល របៀបប្រើប្រាស់វា '
        'និងជម្រើសដែលអ្នកមាន។ យើងប្រមូលតែអ្វីដែលចាំបាច់សម្រាប់ដំណើរការ'
        'សេវាកម្មប៉ុណ្ណោះ។',
    sections: [
      const LegalSection(
        heading: '១. ព័ត៌មានដែលយើងប្រមូល',
        paragraphs: [
          'ព័ត៌មានគណនី៖ ឈ្មោះ អាសយដ្ឋានអ៊ីមែល និងលេខទូរស័ព្ទរបស់អ្នក '
              'ដែលបានផ្ដល់ពេលអ្នកចុះឈ្មោះ។',
          'កំណត់ត្រាហិរញ្ញវត្ថុដែលអ្នកបង្កើត៖ ប្រតិបត្តិការ កាបូប ថវិកា '
              'គោលដៅសន្សំ និងប្រភេទដែលអ្នកបញ្ចូលក្នុងកម្មវិធី។',
          'ព័ត៌មានឧបករណ៍៖ ទិន្នន័យបច្ចេកទេសមូលដ្ឋាន '
              '(ដូចជាកំណែកម្មវិធី និងប្រភេទឧបករណ៍) '
              'ដែលប្រើដើម្បីរក្សាកម្មវិធីឱ្យមានសុវត្ថិភាព និងដំណើរការត្រឹមត្រូវ។',
        ],
      ),
      const LegalSection(
        heading: '២. របៀបដែលយើងប្រើប្រាស់ព័ត៌មានរបស់អ្នក',
        paragraphs: [
          'យើងប្រើប្រាស់ព័ត៌មានរបស់អ្នកដើម្បីផ្ដល់មុខងារស្នូល — '
              'កត់ត្រា និងបង្ហាញហិរញ្ញវត្ថុរបស់អ្នក '
              'បង្កើតការវិភាគ និងការយល់ដឹង '
              'ព្រមទាំងផ្ញើការជូនដំណឹងដែលអ្នកបានបើក។',
          'យើងមិនលក់ទិន្នន័យផ្ទាល់ខ្លួន ឬហិរញ្ញវត្ថុរបស់អ្នកទៅឱ្យភាគីទីបីឡើយ។',
        ],
      ),
      const LegalSection(
        heading: '៣. សុវត្ថិភាពទិន្នន័យ',
        paragraphs: [
          'ព័ត៌មានសម្ងាត់របស់អ្នកត្រូវបានរក្សាទុកដោយប្រើ hashing '
              'តាមស្តង់ដារឧស្សាហកម្ម '
              'ហើយទិន្នន័យរសើបនៅលើឧបករណ៍របស់អ្នកអាចត្រូវបានការពារ '
              'ដោយលេខសម្ងាត់ (PIN) ឬការចាក់សោជីវមាត្រ ដែលអ្នកគ្រប់គ្រង។',
          'ខណៈពេលដែលយើងចាត់វិធានការសមហេតុផលដើម្បីការពារទិន្នន័យរបស់អ្នក '
              'គ្មានវិធីសាស្ត្របញ្ជូន ឬរក្សាទុកណាមួយ '
              'មានសុវត្ថិភាពពេញលេញនោះឡើយ។',
        ],
      ),
      const LegalSection(
        heading: '៤. ការដំណើរការនៅលើឧបករណ៍',
        paragraphs: [
          'មុខងារដូចជាការស្កេនវិក្កយបត្រ និងការយល់ដឹងអំពីការចំណាយ '
              'ដំណើរការនៅលើឧបករណ៍របស់អ្នកតាមដែលអាចធ្វើទៅបាន '
              'ដូច្នេះទិន្នន័យដើមរបស់អ្នកនៅជាមួយអ្នក។',
        ],
      ),
      const LegalSection(
        heading: '៥. ជម្រើស និងសិទ្ធិរបស់អ្នក',
        paragraphs: [
          'អ្នកអាចមើល និងកែសម្រួលប្រវត្តិរូបរបស់អ្នក '
              'នាំចេញប្រតិបត្តិការរបស់អ្នក '
              'និងស្នើសុំលុបគណនី និងទិន្នន័យពាក់ព័ន្ធរបស់អ្នកនៅពេលណាក៏បាន '
              'ពីក្នុងកម្មវិធី។',
          'អ្នកអាចគ្រប់គ្រងការអនុញ្ញាតការជូនដំណឹង '
              'និងការកំណត់ចាក់សោកម្មវិធីនៅលើឧបករណ៍របស់អ្នក។',
        ],
      ),
      const LegalSection(
        heading: '៦. ការរក្សាទុកទិន្នន័យ',
        paragraphs: [
          'យើងរក្សាទុកព័ត៌មានរបស់អ្នករយៈពេលដរាបណាគណនីរបស់អ្នកនៅសកម្ម។ '
              'ពេលអ្នកលុបគណនីរបស់អ្នក '
              'យើងនឹងលុបទិន្នន័យផ្ទាល់ខ្លួនរបស់អ្នកចេញ '
              'លើកលែងតែករណីដែលច្បាប់តម្រូវឱ្យរក្សាទុក។',
        ],
      ),
      const LegalSection(
        heading: '៧. ការផ្លាស់ប្ដូរគោលការណ៍នេះ',
        paragraphs: [
          'យើងអាចធ្វើបច្ចុប្បន្នភាពគោលការណ៍នេះ នៅពេលសេវាកម្មវិវឌ្ឍ។ '
              'ការផ្លាស់ប្ដូរសំខាន់ៗនឹងត្រូវបានបញ្ជាក់ក្នុងកម្មវិធី។',
        ],
      ),
    ],
  );
}
