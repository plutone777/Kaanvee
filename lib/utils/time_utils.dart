import 'package:flutter/material.dart';

class TimeUtils {

  static Future<TimeOfDay?> selectTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ??
          const TimeOfDay(
            hour: 12,
            minute: 0,
          ),
    );
  }

  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute =
        time.minute.toString().padLeft(2, '0');

    final period =
        time.period == DayPeriod.am
            ? 'AM'
            : 'PM';

    return '$hour:$minute $period';
  }

  static TimeOfDay? parseTime(String value) {
    try {
      final parts = value.trim().split(' ');

      if (parts.length != 2) {
        return null;
      }

      final timeParts = parts[0].split(':');

      if (timeParts.length != 2) {
        return null;
      }

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      }

      if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return null;
    }
  }

  static (TimeOfDay, TimeOfDay)?
      parseOperatingHours(String hours) {
    if (hours.isEmpty ||
        !hours.contains(' - ')) {
      return null;
    }

    final parts = hours.split(' - ');

    if (parts.length != 2) {
      return null;
    }

    final opening = parseTime(parts[0]);
    final closing = parseTime(parts[1]);

    if (opening == null ||
        closing == null) {
      return null;
    }

    return (opening, closing);
  }

  static String formatOperatingHours(
    TimeOfDay opening,
    TimeOfDay closing,
  ) {
    return '${formatTime(opening)} - '
        '${formatTime(closing)}';
  }
}