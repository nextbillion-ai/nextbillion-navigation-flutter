part of nb_navigation_flutter;

class TimeFormatter {
  static String formatSeconds(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours hr $minutes min';
    } else if (minutes < 1) {
      return '<1 min';
    } else {
      return '$minutes min';
    }
  }
}
