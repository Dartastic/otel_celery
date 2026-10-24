// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_celery/otel_celery.dart';

/// Traces Celery calls with OpenTelemetry.
///
/// `otel_celery` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Celery call in
/// [tracedCelery]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'celery-example');

  // Traces a Celery call.
  final celeryId = await tracedCelery<String>(
    operation: 'create',
    invoke: () async {
      // Make the Celery call here, then report what it returned.
      const id = 'celery_8f3a2c';
      return const CeleryCallResult(
          value: id,
          result: CeleryResult(
              broker: 'example',
              backend: 'example',
              queue: 'orders',
              taskName: 'example',
              taskId: 'task_8f3a2c',
              parentTaskId: 'parenttask_8f3a2c',
              retries: 1,
              eta: 'example',
              priority: 1,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedCelery create returned $celeryId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutCeleryInstrumentationAsync.
  await runWithoutCeleryInstrumentationAsync(
    () => tracedCelery<String>(
      operation: 'create',
      invoke: () async {
        const id = 'celery_8f3a2c';
        return const CeleryCallResult(
            value: id,
            result: CeleryResult(
                broker: 'example',
                backend: 'example',
                queue: 'orders',
                taskName: 'example',
                taskId: 'task_8f3a2c',
                parentTaskId: 'parenttask_8f3a2c',
                retries: 1,
                eta: 'example',
                priority: 1,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
