import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the bundled fonts' licences to the licence page (About → Open-Source
/// Licenses, which calls [showLicensePage]).
///
/// Flutter collects the licences of packages on its own, but not of font files
/// the app bundles as assets — and both of ours require their licence to ship
/// with them: Kantumruy Pro under the SIL Open Font License 1.1, Ubuntu under
/// the Ubuntu Font Licence 1.0. The copyright lines are taken from the fonts'
/// own name tables.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      const <String>['Kantumruy Pro'],
      await rootBundle.loadString('assets/fonts/licenses/OFL-KantumruyPro.txt'),
    );
    yield LicenseEntryWithLineBreaks(const <String>[
      'Ubuntu',
    ], await rootBundle.loadString('assets/fonts/licenses/UFL-Ubuntu.txt'));
  });
}
