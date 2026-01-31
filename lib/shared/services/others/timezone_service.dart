/// Service to handle Mauritania timezone (GMT+0)
/// Mauritania uses GMT+0 year-round (no daylight saving time)
class TimezoneService {
  // Mauritania timezone offset: GMT+0 (0 hours from UTC)
  static const int mauritaniaOffsetHours = 0;

  /// Get current time in Mauritania timezone
  static DateTime getCurrentMauritaniaTime() {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(const Duration(hours: mauritaniaOffsetHours));
  }

  /// Convert any DateTime to Mauritania timezone
  static DateTime toMauritaniaTime(DateTime dateTime) {
    final utcTime = dateTime.toUtc();
    return utcTime.add(const Duration(hours: mauritaniaOffsetHours));
  }

  /// Format date in Arabic style for Mauritania
  /// Example: "الجمعة، 24 يناير 2026"
  static String formatDateArabic(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);

    final dayNames = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];

    final monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    final dayName = dayNames[mauritaniaTime.weekday - 1];
    final monthName = monthNames[mauritaniaTime.month - 1];

    return '$dayName، ${mauritaniaTime.day} $monthName ${mauritaniaTime.year}';
  }

  /// Format time in 12-hour format with AM/PM in Arabic
  /// Example: "3:30 مساءً" or "9:15 صباحاً"
  static String formatTimeArabic(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);

    final hour = mauritaniaTime.hour;
    final minute = mauritaniaTime.minute;

    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'مساءً' : 'صباحاً';

    return '${hour12}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Format time in 24-hour format
  /// Example: "15:30"
  static String formatTime24(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    return '${mauritaniaTime.hour.toString().padLeft(2, '0')}:${mauritaniaTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date and time together
  /// Example: "الجمعة، 24 يناير 2026 - 3:30 مساءً"
  static String formatDateTimeArabic(DateTime dateTime) {
    return '${formatDateArabic(dateTime)} - ${formatTimeArabic(dateTime)}';
  }

  /// Format date in short format (DD/MM/YYYY)
  /// Example: "24/01/2026"
  static String formatDateShort(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    return '${mauritaniaTime.day.toString().padLeft(2, '0')}/${mauritaniaTime.month.toString().padLeft(2, '0')}/${mauritaniaTime.year}';
  }

  /// Get date string in ISO format (YYYY-MM-DD) for database storage
  static String toIsoDateString(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    return '${mauritaniaTime.year}-${mauritaniaTime.month.toString().padLeft(2, '0')}-${mauritaniaTime.day.toString().padLeft(2, '0')}';
  }

  /// Get time string in ISO format (HH:MM:SS) for database storage
  static String toIsoTimeString(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    return '${mauritaniaTime.hour.toString().padLeft(2, '0')}:${mauritaniaTime.minute.toString().padLeft(2, '0')}:${mauritaniaTime.second.toString().padLeft(2, '0')}';
  }

  /// Parse date string from database and convert to Mauritania time
  static DateTime parseIsoDate(String isoDateString) {
    final parsed = DateTime.parse(isoDateString);
    return toMauritaniaTime(parsed);
  }

  /// Check if a given date is today in Mauritania timezone
  static bool isToday(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    final today = getCurrentMauritaniaTime();

    return mauritaniaTime.year == today.year &&
           mauritaniaTime.month == today.month &&
           mauritaniaTime.day == today.day;
  }

  /// Check if a given date is tomorrow in Mauritania timezone
  static bool isTomorrow(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    final tomorrow = getCurrentMauritaniaTime().add(const Duration(days: 1));

    return mauritaniaTime.year == tomorrow.year &&
           mauritaniaTime.month == tomorrow.month &&
           mauritaniaTime.day == tomorrow.day;
  }

  /// Get relative date string (Today, Tomorrow, or date)
  static String getRelativeDateString(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'اليوم';
    } else if (isTomorrow(dateTime)) {
      return 'غداً';
    } else {
      return formatDateArabic(dateTime);
    }
  }

  /// Get time difference from now in minutes
  static int getMinutesFromNow(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    final now = getCurrentMauritaniaTime();
    return mauritaniaTime.difference(now).inMinutes;
  }

  /// Check if appointment time is within next hour
  static bool isWithinNextHour(DateTime dateTime) {
    final minutes = getMinutesFromNow(dateTime);
    return minutes > 0 && minutes <= 60;
  }

  /// Format duration in Arabic
  /// Example: "45 دقيقة" or "1 ساعة و 30 دقيقة"
  static String formatDurationArabic(int minutes) {
    if (minutes < 60) {
      return '$minutes دقيقة';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (remainingMinutes == 0) {
        return hours == 1 ? 'ساعة واحدة' : '$hours ساعات';
      } else {
        final hoursText = hours == 1 ? 'ساعة' : '$hours ساعات';
        return '$hoursText و $remainingMinutes دقيقة';
      }
    }
  }

  /// Create DateTime from date and time strings
  static DateTime createDateTime(String dateStr, String timeStr) {
    // dateStr format: "YYYY-MM-DD"
    // timeStr format: "HH:MM" or "HH:MM:SS"

    final dateParts = dateStr.split('-');
    final timeParts = timeStr.split(':');

    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

    // Create as UTC since Mauritania is GMT+0
    return DateTime.utc(year, month, day, hour, minute, second);
  }

  /// Get start of day in Mauritania timezone
  static DateTime getStartOfDay(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    return DateTime.utc(
      mauritaniaTime.year,
      mauritaniaTime.month,
      mauritaniaTime.day,
      0,
      0,
      0,
    );
  }

  /// Get end of day in Mauritania timezone
  static DateTime getEndOfDay(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    return DateTime.utc(
      mauritaniaTime.year,
      mauritaniaTime.month,
      mauritaniaTime.day,
      23,
      59,
      59,
    );
  }
}
