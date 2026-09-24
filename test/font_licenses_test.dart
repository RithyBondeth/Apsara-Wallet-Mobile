import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/core/themes/font_licenses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled fonts appear on the licence page with their licence text',
    () async {
      registerFontLicenses();

      final entries = await LicenseRegistry.licenses.toList();
      String textFor(String package) => entries
          .where((entry) => entry.packages.contains(package))
          .expand((entry) => entry.paragraphs)
          .map((paragraph) => paragraph.text)
          .join('\n');

      expect(
        textFor('Kantumruy Pro'),
        contains('SIL Open Font License, Version 1.1'),
      );
      expect(
        textFor('Kantumruy Pro'),
        contains('The Kantumruy Project Authors'),
      );
      expect(textFor('Ubuntu'), contains('UBUNTU FONT LICENCE Version 1.0'));
      expect(textFor('Ubuntu'), contains('Canonical Ltd.'));
    },
  );
}
