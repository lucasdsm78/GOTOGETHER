import 'package:flutter/material.dart';
import 'package:go_together/widgets/app.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://26904f548a1149a6b66d2c475b7755bb@o1315229.ingest.sentry.io/6566897';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(GotogetherApp()),
  );

  // or define SENTRY_DSN via Dart environment variable (--dart-define)
}