// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

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
