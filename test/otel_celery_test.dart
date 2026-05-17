// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_celery/otel_celery.dart';
import 'package:test/test.dart';

void main() {
  group('otel_celery', () {
    test('suppression toggles in zone', () async {
      expect(celeryInstrumentationSuppressed(), isFalse);
      await runWithoutCeleryInstrumentationAsync(() async {
        expect(celeryInstrumentationSuppressed(), isTrue);
      });
      expect(celeryInstrumentationSuppressed(), isFalse);
    });

    test('CeleryResult fields default null', () {
      const r = CeleryResult();
      expect(r.statusCode, isNull);
    });
  });
}
