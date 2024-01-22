
String helloAccordingToTime() {
  int hour =  DateTime.now().hour;
  if (hour >= 3 && hour <= 10) {
    return "お早う, ";
  } else if (hour >= 11 && hour <= 17) {
    return "こんにちは, ";
  } else if (hour >= 18 && hour <= 23) {
    return "今晩は, ";
  } else if (hour >= 0 && hour <= 2) {
    return "今晩は, ";
  } else {
    return "こんにちは, "; // Default case
  }
}
