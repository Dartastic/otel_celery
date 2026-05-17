# otel_celery

Dartastic OpenTelemetry bridge for Celery (Python distributed task queue).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_celery/otel_celery.dart';

await tracedCelery<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return CeleryCallResult(value: r, result: CeleryResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutCeleryInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
