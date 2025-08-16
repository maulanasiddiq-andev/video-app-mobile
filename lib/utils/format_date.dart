import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as  timeago;

String formatDate(DateTime date) {
  String formattedDate = '';

  Duration diff = DateTime.now().difference(date);
  if (diff.inDays < 7) {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    formattedDate = timeago.format(date, locale: 'id');
  } else {
    formattedDate = DateFormat('dd/MM/yyyy').format(date);
  }

  return formattedDate;
}