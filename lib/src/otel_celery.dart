// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_celery_suppression.dart';

class CeleryResult {
  /// Creates a result.
  const CeleryResult({
    this.broker,
    this.backend,
    this.queue,
    this.taskName,
    this.taskId,
    this.parentTaskId,
    this.retries,
    this.eta,
    this.priority,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? broker;
  final String? backend;
  final String? queue;
  final String? taskName;
  final String? taskId;
  final String? parentTaskId;
  final int? retries;
  final String? eta;
  final int? priority;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class CeleryCallResult<T> {
  /// Creates a call result.
  const CeleryCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final CeleryResult? result;
}

Future<T> tracedCelery<T>({
  required String operation,
  required Future<CeleryCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (celeryInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_celery');
  final span = t.startSpan('celery $operation', kind: SpanKind.producer);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('messaging.system', 'celery')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.broker != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('server.address', res.broker!)]));
      }
      if (res.backend != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('celery.backend', res.backend!)]));
      }
      if (res.queue != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('messaging.destination.name', res.queue!)
        ]));
      }
      if (res.taskName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('celery.task.name', res.taskName!)]));
      }
      if (res.taskId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('messaging.message.id', res.taskId!)]));
      }
      if (res.parentTaskId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('celery.parent_task_id', res.parentTaskId!)
        ]));
      }
      if (res.retries != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('celery.retries', res.retries!)]));
      }
      if (res.eta != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('celery.eta', res.eta!)]));
      }
      if (res.priority != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('messaging.message.priority', res.priority!)
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('celery.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              ErrorAttributes.errorType.key, res.errorCode ?? 'celery.error')
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
