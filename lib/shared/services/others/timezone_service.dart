import 'package:get/get.dart';

/// Service to handle timezone conversions between users
/// Supports showing appointment times in user's local timezone with offset information
class TimezoneService {
  // Mauritania timezone offset: GMT+0 (0 hours from UTC)
  static const int mauritaniaOffsetHours = 0;

  /// Get current time in user's local timezone (device timezone)
  static DateTime getCurrentLocalTime() {
    return DateTime.now();
  }

  /// Get current time in Mauritania timezone (for doctors)
  static DateTime getCurrentMauritaniaTime() {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(const Duration(hours: mauritaniaOffsetHours));
  }

  /// Convert any DateTime to Mauritania timezone
  static DateTime toMauritaniaTime(DateTime dateTime) {
    final utcTime = dateTime.toUtc();
    return utcTime.add(const Duration(hours: mauritaniaOffsetHours));
  }

  /// Convert Mauritania time to user's local timezone
  static DateTime mauritaniaToLocalTime(DateTime mauritaniaDateTime) {
    // Mauritania time is stored as UTC+0
    // Convert to local timezone
    final utcTime = mauritaniaDateTime.toUtc();
    return utcTime.toLocal();
  }

  /// Get timezone offset difference in hours between user's device and Mauritania
  /// Returns positive number if user is ahead, negative if behind
  /// Example: Egypt (GMT+2) returns +2, USA EST (GMT-5) returns -5
  static int getTimezoneOffsetFromMauritania() {
    final now = DateTime.now();
    final localOffset = now.timeZoneOffset.inHours;
    return localOffset - mauritaniaOffsetHours;
  }

  /// Get timezone offset in minutes for more accurate calculations
  static int getTimezoneOffsetInMinutes() {
    final now = DateTime.now();
    return now.timeZoneOffset.inMinutes;
  }

  /// Format timezone offset as string (e.g., "+2", "-5", "+0")
  static String getTimezoneOffsetString() {
    final offset = getTimezoneOffsetFromMauritania();
    if (offset == 0) return "GMT+0";
    if (offset > 0) return "GMT+$offset";
    return "GMT$offset";
  }

  /// Check if user can join video session (5 mins before appointment).
  /// Stored booking_date + booking_time are in UTC; parse as UTC and compare with nowUtc.
  /// [doctorTimezoneOffsetHours] kept for API compatibility, not used when stored is UTC.
  static bool canJoinVideoSession({
    required String bookingDate,
    required String bookingTime,
    required int doctorTimezoneOffsetHours,
  }) {
    try {
      final appointmentUtc = parseUtcBookingToDateTime(bookingDate, bookingTime);
      if (appointmentUtc == null) return true;
      final canJoinUtc = appointmentUtc.subtract(const Duration(minutes: 5));
      final nowUtc = DateTime.now().toUtc();
      return nowUtc.isAfter(canJoinUtc) || nowUtc.isAtSameMomentAs(canJoinUtc);
    } catch (_) {
      return true; // Fail open
    }
  }

  /// Check if the session has started (current time >= appointment start time).
  /// Stored booking_date + booking_time are in UTC.
  static bool hasSessionStarted({
    required String bookingDate,
    required String bookingTime,
    required int doctorTimezoneOffsetHours,
  }) {
    try {
      final appointmentUtc = parseUtcBookingToDateTime(bookingDate, bookingTime);
      if (appointmentUtc == null) return false;
      final nowUtc = DateTime.now().toUtc();
      return nowUtc.isAfter(appointmentUtc) ||
          nowUtc.isAtSameMomentAs(appointmentUtc);
    } catch (_) {
      return false;
    }
  }

  /// Get human-readable time until user can join (5 mins before appointment).
  /// Stored booking_date + booking_time are in UTC.
  static String getTimeUntilCanJoinVideoSession({
    required String bookingDate,
    required String bookingTime,
    required int doctorTimezoneOffsetHours,
  }) {
    try {
      final appointmentUtc = parseUtcBookingToDateTime(bookingDate, bookingTime);
      if (appointmentUtc == null) return 'now'.tr;
      final canJoinUtc = appointmentUtc.subtract(const Duration(minutes: 5));
      final nowUtc = DateTime.now().toUtc();
      final diff = canJoinUtc.difference(nowUtc);

      if (diff.isNegative) return 'now'.tr;
      if (diff.inDays > 0) {
        return '${diff.inDays} ${diff.inDays == 1 ? 'day'.tr : 'days'.tr}';
      }
      if (diff.inMinutes >= 90) {
        final h = diff.inHours % 24;
        final m = diff.inMinutes % 60;
        return '$h ${h == 1 ? 'hour'.tr : 'hours'.tr} ${'and'.tr} $m ${m == 1 ? 'minute'.tr : 'minutes'.tr}';
      }
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute'.tr : 'minutes'.tr}';
    } catch (_) {
      return 'now'.tr;
    }
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
      'الأحد',
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
      'ديسمبر',
    ];

    final dayName = dayNames[mauritaniaTime.weekday - 1];
    final monthName = monthNames[mauritaniaTime.month - 1];

    return '$dayName، ${mauritaniaTime.day} $monthName ${mauritaniaTime.year}';
  }

  /// Format time in 12-hour format with AM/PM in Arabic
  /// Example: "3:30 مساءً" or "9:15 صباحاً"
  static String formatTimeArabic(
    DateTime dateTime, {
    bool useLocalTime = true,
  }) {
    final timeToFormat = useLocalTime ? dateTime : toMauritaniaTime(dateTime);

    final hour = timeToFormat.hour;
    final minute = timeToFormat.minute;

    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'مساءً' : 'صباحاً';

    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Format appointment time showing doctor's time and patient's local time
  /// Example: "3:30 مساءً (5:30 مساءً بتوقيتك)" if patient is GMT+2
  /// or just "3:30 مساءً" if patient is in same timezone
  static String formatAppointmentTimeWithOffset(DateTime doctorDateTime) {
    final offset = getTimezoneOffsetFromMauritania();

    // Doctor's time in Mauritania timezone
    final doctorTime = formatTimeArabic(doctorDateTime, useLocalTime: false);

    // If same timezone, just show the time
    if (offset == 0) {
      return doctorTime;
    }

    // Convert to patient's local time
    final patientTime = mauritaniaToLocalTime(doctorDateTime);
    final patientTimeStr = formatTimeArabic(patientTime, useLocalTime: true);

    return '$doctorTime ($patientTimeStr بتوقيتك)';
  }

  /// Format appointment time with timezone difference message
  /// Example: "3:30 مساءً (بعد ساعتين من توقيتك)" or "3:30 مساءً (قبل ساعة من توقيتك)"
  static String formatAppointmentTimeWithDifference(DateTime doctorDateTime) {
    final offset = getTimezoneOffsetFromMauritania();

    // Doctor's time in Mauritania timezone
    final doctorTime = formatTimeArabic(doctorDateTime, useLocalTime: false);

    // If same timezone, just show the time
    if (offset == 0) {
      return doctorTime;
    }

    // Build difference message
    String differenceMsg;
    final absOffset = offset.abs();

    if (offset > 0) {
      // Patient is ahead
      if (absOffset == 1) {
        differenceMsg = 'قبل ساعة من توقيتك';
      } else {
        differenceMsg = 'قبل $absOffset ساعات من توقيتك';
      }
    } else {
      // Patient is behind
      if (absOffset == 1) {
        differenceMsg = 'بعد ساعة من توقيتك';
      } else {
        differenceMsg = 'بعد $absOffset ساعات من توقيتك';
      }
    }

    return '$doctorTime ($differenceMsg)';
  }

  /// Format time in 24-hour format
  /// Example: "15:30"
  static String formatTime24(DateTime dateTime) {
    final mauritaniaTime = toMauritaniaTime(dateTime);
    return '${mauritaniaTime.hour.toString().padLeft(2, '0')}:${mauritaniaTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date and time together
  /// Example: "الجمعة، 24 يناير 2026 - 3:30 مساءً"
  static String formatDateTimeArabic(
    DateTime dateTime, {
    bool useLocalTime = true,
  }) {
    return '${formatDateArabic(dateTime)} - ${formatTimeArabic(dateTime, useLocalTime: useLocalTime)}';
  }

  /// Format appointment date and time with timezone offset
  /// Example: "الجمعة، 24 يناير 2026 - 3:30 مساءً (5:30 مساءً بتوقيتك)"
  static String formatAppointmentDateTimeWithOffset(DateTime doctorDateTime) {
    return '${formatDateArabic(doctorDateTime)} - ${formatAppointmentTimeWithOffset(doctorDateTime)}';
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

  // ---------------------------------------------------------------------------
  // UTC booking storage: stored = UTC; display uses each user's offset
  // ---------------------------------------------------------------------------

  /// Parse stored UTC booking_date + booking_time to DateTime (UTC).
  /// [dateStr] YYYY-MM-DD, [timeStr] HH:mm or HH:mm:ss.
  static DateTime? parseUtcBookingToDateTime(String dateStr, String timeStr) {
    try {
      final dateParts = dateStr.split('-');
      final timeParts = timeStr.split(':');
      if (dateParts.length < 3 || timeParts.isEmpty) return null;
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      return DateTime.utc(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  /// Convert local (e.g. doctor) date+time to UTC for storage.
  /// [dateStr] YYYY-MM-DD, [timeStr] HH:mm or HH:mm:ss in local time.
  /// Returns (utcDateStr, utcTimeStr) for booking_date and booking_time.
  static ({String utcDateStr, String utcTimeStr}) localDateAndTimeToUtcStrings(
    String dateStr,
    String timeStr,
    int localOffsetHours,
  ) {
    final dateParts = dateStr.split('-');
    final timeParts = timeStr.split(':');
    if (dateParts.length < 3 || timeParts.isEmpty) {
      return (utcDateStr: dateStr, utcTimeStr: timeStr);
    }
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);
    final hour = int.parse(timeParts[0]);
    final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
    // Local moment as if it were UTC, then subtract offset to get real UTC
    final utcMoment = DateTime.utc(year, month, day, hour, minute)
        .subtract(Duration(hours: localOffsetHours));
    final utcDateStr =
        '${utcMoment.year}-${utcMoment.month.toString().padLeft(2, '0')}-${utcMoment.day.toString().padLeft(2, '0')}';
    final utcTimeStr =
        '${utcMoment.hour.toString().padLeft(2, '0')}:${utcMoment.minute.toString().padLeft(2, '0')}:00';
    return (utcDateStr: utcDateStr, utcTimeStr: utcTimeStr);
  }

  /// Convert stored UTC booking to local time string (HH:mm) for a given offset.
  /// Used when building "booked slots" in doctor local for a given day.
  static String utcBookingToLocalTimeString(
    String dateStr,
    String timeStr,
    int localOffsetHours,
  ) {
    final utc = parseUtcBookingToDateTime(dateStr, timeStr);
    if (utc == null) return '';
    final local = utc.add(Duration(hours: localOffsetHours));
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  /// Get UTC date range that overlaps a given local date (for querying bookings).
  /// [localDateStr] YYYY-MM-DD in local time; [localOffsetHours] that timezone's offset.
  /// Returns (utcDateStart, utcDateEnd) inclusive - the UTC dates that might contain bookings for that local day.
  static ({String start, String end}) utcDateRangeForLocalDay(
    String localDateStr,
    int localOffsetHours,
  ) {
    final parts = localDateStr.split('-');
    if (parts.length < 3) return (start: localDateStr, end: localDateStr);
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    // Local day start = 00:00 local = 00:00 - offset in UTC (might be previous UTC day)
    final localDayStartUtc = DateTime.utc(year, month, day, 0, 0)
        .subtract(Duration(hours: localOffsetHours));
    final localDayEndUtc = DateTime.utc(year, month, day, 23, 59)
        .subtract(Duration(hours: localOffsetHours));
    final startStr =
        '${localDayStartUtc.year}-${localDayStartUtc.month.toString().padLeft(2, '0')}-${localDayStartUtc.day.toString().padLeft(2, '0')}';
    final endStr =
        '${localDayEndUtc.year}-${localDayEndUtc.month.toString().padLeft(2, '0')}-${localDayEndUtc.day.toString().padLeft(2, '0')}';
    return (start: startStr, end: endStr);
  }

  /// Get user's timezone name/abbreviation
  /// Example: "EET" for Egypt, "EST" for US East, etc.
  static String getUserTimezoneName() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset.inHours;

    // Common timezone abbreviations based on offset
    final timezoneNames = {
      -12: 'BIT',
      -11: 'SST',
      -10: 'HST',
      -9: 'AKST',
      -8: 'PST',
      -7: 'MST',
      -6: 'CST',
      -5: 'EST',
      -4: 'AST',
      -3: 'ART',
      -2: 'FNT',
      -1: 'AZOT',
      0: 'GMT',
      1: 'CET',
      2: 'EET',
      3: 'AST',
      4: 'GST',
      5: 'PKT',
      6: 'BST',
      7: 'ICT',
      8: 'CST',
      9: 'JST',
      10: 'AEST',
      11: 'SBT',
      12: 'NZST',
    };

    return timezoneNames[offset] ?? getTimezoneOffsetString();
  }

  /// Get timezone offset difference in hours between user's device and doctor's timezone
  /// Returns positive if user is ahead, negative if behind
  static int getTimezoneOffsetFromDoctor(int doctorTimezoneOffsetHours) {
    final localOffset = DateTime.now().timeZoneOffset.inHours;
    return localOffset - doctorTimezoneOffsetHours;
  }

  /// Check if user needs timezone conversion
  /// [doctorTimezoneOffsetHours] - doctor's UTC offset; if null, compares to Mauritania (0)
  static bool needsTimezoneConversion({int? doctorTimezoneOffsetHours}) {
    final doctorOffset = doctorTimezoneOffsetHours ?? mauritaniaOffsetHours;
    return getTimezoneOffsetFromDoctor(doctorOffset) != 0;
  }

  /// Get a friendly timezone difference message in Arabic
  /// [doctorTimezoneOffsetHours] - doctor's UTC offset (e.g. 2 for Egypt, 0 for Mauritania)
  /// If null, falls back to Mauritania (0) for backward compatibility
  /// Example: "أنت متقدم ساعتين عن توقيت الطبيب"
  static String getTimezoneDifferenceMessage({int? doctorTimezoneOffsetHours}) {
    final doctorOffset = doctorTimezoneOffsetHours ?? mauritaniaOffsetHours;
    final offset = getTimezoneOffsetFromDoctor(doctorOffset);

    if (offset == 0) {
      return 'أنت في نفس توقيت الطبيب';
    }

    final absOffset = offset.abs();
    final hoursText = absOffset == 1 ? 'ساعة واحدة' : '$absOffset ساعات';

    if (offset > 0) {
      return 'أنت متقدم $hoursText عن توقيت الطبيب';
    } else {
      return 'أنت متأخر $hoursText عن توقيت الطبيب';
    }
  }

  /// Convert appointment time from doctor's timezone to patient's local time
  /// Used when displaying appointment cards, lists, etc.
  static DateTime convertDoctorTimeToPatientTime(DateTime doctorDateTime) {
    return mauritaniaToLocalTime(doctorDateTime);
  }

  /// Convert patient's selected time to doctor's timezone for saving
  /// Used when patient books an appointment
  static DateTime convertPatientTimeToDoctorTime(DateTime patientDateTime) {
    // Convert local time to UTC, then to Mauritania time
    final utcTime = patientDateTime.toUtc();
    return utcTime.add(const Duration(hours: mauritaniaOffsetHours));
  }

  /// Format slot time for patient: show only patient's local time (no doctor time)
  /// [dateStr] YYYY-MM-DD, [timeStr] HH:mm in doctor's timezone
  static String formatSlotForPatient({
    required String dateStr,
    required String timeStr,
    required int doctorTimezoneOffsetHours,
    bool isArabic = false,
  }) {
    try {
      final utcMoment = _parseDoctorDateTimeToUtc(
        dateStr,
        timeStr,
        doctorTimezoneOffsetHours,
      );
      if (utcMoment == null) return timeStr;

      final patientLocal = utcMoment.toLocal();
      return _formatTimeShort(patientLocal, isArabic);
    } catch (_) {
      return timeStr;
    }
  }

  static DateTime? _parseDoctorDateTimeToUtc(
    String dateStr,
    String timeStr,
    int doctorOffset,
  ) {
    try {
      final dateParts = dateStr.split('-');
      final timeParts = timeStr.split(':');
      if (dateParts.length < 3 || timeParts.isEmpty) return null;
      final dt = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
      );
      return DateTime.utc(
        dt.year,
        dt.month,
        dt.day,
        dt.hour - doctorOffset,
        dt.minute,
      );
    } catch (_) {
      return null;
    }
  }

  static String _formatTimeShort(DateTime dt, bool isArabic) {
    final hour = dt.hour;
    final minute = dt.minute;
    if (isArabic) {
      final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final period = hour >= 12 ? 'مساءً' : 'صباحاً';
      return '$h12:${minute.toString().padLeft(2, '0')} $period';
    }
    final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h12:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Format appointment date+time for display - patient view (only patient's local time).
  /// Stored time is UTC; convert to patient's local (device .toLocal() or patient offset).
  static String formatAppointmentForPatient({
    required String dateStr,
    required String timeStr,
    required int doctorTimezoneOffsetHours,
    bool isArabic = false,
    int? patientTimezoneOffsetHours,
  }) {
    if (dateStr.isEmpty || timeStr.isEmpty) return '';
    try {
      final utcMoment = parseUtcBookingToDateTime(dateStr, timeStr);
      if (utcMoment == null) return '$dateStr $timeStr';
      final patientLocal = patientTimezoneOffsetHours != null
          ? utcMoment.add(Duration(hours: patientTimezoneOffsetHours))
          : utcMoment.toLocal();

      final dateFmt = isArabic
          ? formatDateArabic(patientLocal)
          : '${patientLocal.day}/${patientLocal.month}/${patientLocal.year}';
      final timeFmt = _formatTimeShort(patientLocal, isArabic);
      return '$dateFmt - $timeFmt';
    } catch (_) {
      return '$dateStr $timeStr';
    }
  }

  /// Format appointment date+time for display - doctor view.
  /// Stored time is UTC; convert to doctor local (UTC + doctor_offset) for display.
  static String formatAppointmentForDoctor({
    required String dateStr,
    required String timeStr,
    bool isArabic = false,
    int? doctorTimezoneOffsetHours,
  }) {
    if (dateStr.isEmpty || timeStr.isEmpty) return '';
    try {
      final utcMoment = parseUtcBookingToDateTime(dateStr, timeStr);
      if (utcMoment == null) return '$dateStr $timeStr';
      final offset = doctorTimezoneOffsetHours ?? 0;
      final doctorLocal = utcMoment.add(Duration(hours: offset));

      final dateFmt = isArabic
          ? formatDateArabic(doctorLocal)
          : '${doctorLocal.day}/${doctorLocal.month}/${doctorLocal.year}';
      final timeFmt = _formatTimeShort(doctorLocal, isArabic);
      return '$dateFmt - $timeFmt';
    } catch (_) {
      return '$dateStr $timeStr';
    }
  }

  /// Get current time in doctor's timezone (for join window comparison)
  /// booking_date + booking_time are stored in doctor's timezone
  static DateTime getCurrentTimeInDoctorTimezone(
    int doctorTimezoneOffsetHours,
  ) {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(Duration(hours: doctorTimezoneOffsetHours));
  }

  /// Check if user can join session (within 5 minutes before appointment or after)
  /// [appointmentDateTime] - parsed from booking_date + booking_time (in doctor's timezone)
  /// [doctorTimezoneOffsetHours] - doctor's UTC offset from doctors table
  static bool isWithinJoinWindow(
    DateTime appointmentDateTime, {
    required int doctorTimezoneOffsetHours,
    int minutesBefore = 5,
  }) {
    final nowInDoctorTz = getCurrentTimeInDoctorTimezone(
      doctorTimezoneOffsetHours,
    );
    final canJoinTime = appointmentDateTime.subtract(
      Duration(minutes: minutesBefore),
    );
    return nowInDoctorTz.isAfter(canJoinTime) ||
        nowInDoctorTz.isAtSameMomentAs(canJoinTime);
  }

  /// Minutes from now until user can join (5 mins before appointment)
  /// Returns negative if already within join window or past appointment
  static int getMinutesUntilCanJoin(
    DateTime appointmentDateTime, {
    required int doctorTimezoneOffsetHours,
    int minutesBefore = 5,
  }) {
    final nowInDoctorTz = getCurrentTimeInDoctorTimezone(
      doctorTimezoneOffsetHours,
    );
    final canJoinTime = appointmentDateTime.subtract(
      Duration(minutes: minutesBefore),
    );
    return canJoinTime.difference(nowInDoctorTz).inMinutes;
  }
}
