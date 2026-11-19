import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Respuesta que decide un test para una petición.
typedef FakeHandler = FutureOr<ResponseBody> Function(RequestOptions options);

/// `HttpClientAdapter` de dio escrito a mano, sin dependencias extra.
///
/// Registra cada petición que llega al transporte y responde con [handler].
final class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  FakeHandler handler;
  final List<RequestOptions> requests = <RequestOptions>[];

  /// Peticiones a [path] con el método [method].
  List<RequestOptions> calls(String method, String path) => requests
      .where(
        (RequestOptions options) =>
            options.method == method && options.path == path,
      )
      .toList();

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }
}

/// Respuesta JSON con [status].
ResponseBody jsonBody(
  int status,
  Object? body, {
  Map<String, List<String>> headers = const <String, List<String>>{},
}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: <String, List<String>>{
    Headers.contentTypeHeader: <String>[
      status >= 400 ? 'application/problem+json' : 'application/json',
    ],
    ...headers,
  },
);

/// Respuesta `problem+json` con [code].
ResponseBody problem(
  int status,
  String code, {
  String? detail,
  List<Map<String, Object?>>? errors,
  Map<String, List<String>> headers = const <String, List<String>>{},
}) => jsonBody(status, <String, Object?>{
  'type': 'about:blank',
  'title': code,
  'status': status,
  'code': code,
  'detail': ?detail,
  'errors': ?errors,
}, headers: headers);

/// Error de transporte de tipo [type].
DioException transportError(RequestOptions options, DioExceptionType type) =>
    DioException(requestOptions: options, type: type);
