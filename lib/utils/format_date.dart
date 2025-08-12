import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('dd MMMM yyyy').format(date);
}