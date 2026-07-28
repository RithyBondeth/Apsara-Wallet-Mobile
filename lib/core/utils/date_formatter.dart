import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String short(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String full(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}
