import 'package:intl/intl.dart';

/// Time-of-day for the given locale tag.
///
/// `DateFormat.jm('km')` renders the day-period marker as a bare "p" / "a"
/// (the CLDR abbreviated form intl ships), so "8:47 p". Cambodia reads the
/// 24-hour clock everywhere, so Khmer gets `Hm`; other locales keep their
/// own `jm` conventions.
DateFormat timeOfDayFormat(String localeTag) => localeTag.startsWith('km')
    ? DateFormat.Hm(localeTag)
    : DateFormat.jm(localeTag);

/// Date + time, e.g. "21 កញ្ញា 2026 20:47" / "September 21, 2026 8:47 PM".
DateFormat dateTimeFormat(String localeTag) => localeTag.startsWith('km')
    ? DateFormat.yMMMMd(localeTag).add_Hm()
    : DateFormat.yMMMMd(localeTag).add_jm();
