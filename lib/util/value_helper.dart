import 'package:FinTrack/models/recurrence_model.dart';
import 'package:flutter/material.dart';

class ValueHelper {
  String getFormattedTimeIn12Hr(TimeOfDay time) {
    int hour = time.hourOfPeriod;
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    if (hour > 12) {
      hour -= 12;
    }
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  TimeOfDay getTimeOfDayFromString(String timeString) {
    List<String> parts = timeString.split(' ');
    List<String> timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    if (parts[1].toLowerCase() == 'pm' && hour != 12) {
      hour += 12;
    } else if (parts[1].toLowerCase() == 'am' && hour == 12) {
      hour = 0;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  DateTime getDateFromISOString(String iso8601String) {
    return DateTime.parse(iso8601String);
  }

  String getNextRecurringDate(RecurrenceModel recurrence) {
    DateTime currentRecurrenceDate =
        DateTime.parse(recurrence.recurOn ?? DateTime.now().toIso8601String());
    DateTime nextRecurrenceDate = currentRecurrenceDate;

    if (recurrence.recurType == 0) {
      nextRecurrenceDate = DateTime(currentRecurrenceDate.year,
          currentRecurrenceDate.month, currentRecurrenceDate.day + 1);
    } else if (recurrence.recurType == 1) {
      nextRecurrenceDate = currentRecurrenceDate.add(Duration(days: 7));
    } else if (recurrence.recurType == 2) {
      //monthly type
      nextRecurrenceDate = DateTime(currentRecurrenceDate.year,
          currentRecurrenceDate.month + 1, currentRecurrenceDate.day);
    } else if (recurrence.recurType == 3) {
      //yearly type
      nextRecurrenceDate = DateTime(currentRecurrenceDate.year + 1,
          currentRecurrenceDate.month, currentRecurrenceDate.day);
    }
    if (recurrence.recurType != 1) {
      nextRecurrenceDate =
          nextRecurrenceDate.add(Duration(hours: 7)); //morning 7 AM
    }
    return nextRecurrenceDate.toIso8601String();
  }
}
