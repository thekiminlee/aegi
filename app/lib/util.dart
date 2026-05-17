String greeting(DateTime datetime) {
  if (datetime.hour < 12) {
    return 'Good morning';
  } else if (datetime.hour < 18) {
    return 'Good afternoon';
  } else {
    return 'Good evening';
  }
}

String season(DateTime datetime) {
  final month = datetime.month;
  if (month >= 3 && month <= 5) {
    return 'Spring';
  } else if (month >= 6 && month <= 8) {
    return 'Summer';
  } else if (month >= 9 && month <= 10) {
    return 'Autumn';
  } else {
    return 'Winter';
  }
}