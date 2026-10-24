import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  static String formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy').format(dt);
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, h:mm a').format(dt);
  }

  static String timeAgo(DateTime dt) {
    final duration = DateTime.now().difference(dt);
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} sec ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hrs ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }

  static String formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
