import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String helloAccordingToTime() {
  int hour = DateTime.now().hour;
  if (hour >= 3 && hour <= 10) {
    return "お早う, ";
  } else if (hour >= 11 && hour <= 17) {
    return "こんにちは, ";
  } else if (hour >= 18 && hour <= 23) {
    return "今晩は, ";
  } else if (hour >= 0 && hour <= 2) {
    return "お早う, ";
  } else {
    return "こんにちは, "; // Default case
  }
}

Future<void> openWebsite(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {}
}

futureWidget(Future<Widget> scheduleTask, bool showError, bool showLoading) {
  return FutureBuilder<Widget>(
    future: scheduleTask, // a previously-obtained Future
    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
      List<Widget> children;
      if (snapshot.hasData) {
        children = <Widget>[
          snapshot.data!,
        ];
      } else if (snapshot.hasError) {
        children = showError
            ? <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                      'Error: Cannot load new items list "${snapshot.error}"'),
                ),
              ]
            : [const SizedBox.shrink()];
      } else {
        children = showError
            ? const <Widget>[
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text('Fetching data...'),
                ),
              ]
            : [const SizedBox.shrink()];
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      );
    },
  );
}
