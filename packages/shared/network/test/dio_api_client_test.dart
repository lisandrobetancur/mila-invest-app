import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import 'fake_http_adapter.dart';

const AuthTokens _oldTokens = AuthTokens(
  accessToken: 'access-old',
  refreshToken: 'refresh-old',
);

final class _Harness {
  _Harness(FakeHandler handler, {AuthTokens? tokens = _oldTokens})
    : adapter = FakeHttpAdapter(handler),
      store = InMemoryTokenStore(tokens),
      events = SessionEvents() {
    events.stream.listen(received.add);
    client = DioApiClient(
      baseUrl: 'https://api.test/api/v1',
      tokenStore: store,
      sessionEvents: events,
      logger: const SilentAppLogger(),
      clock: FixedClock(DateTime.utc(2026, 11, 18)),
      httpClientAdapter: adapter,
      delay: (Duration duration) async => delays.add(duration),
    );
  }

  final FakeHttpAdapter adapter;
  final InMemoryTokenStore store;
  final SessionEvents events;
  final List<SessionEvent> received = <SessionEvent>[];
  final List<Duration> delays = <Duration>[];
  late final DioApiClient client;
}

Future<ApiException> _failure(Future<ApiResponse> call) async {
  try {
    await call;
  } on ApiException catch (error) {
    return error;
  }
  fail('Se esperaba una ApiException');
}

void main() {
  group('interceptor de errores', () {
    const Map<String, int> statusByCode = <String, int>{
      ApiErrorCodes.validationError: 422,
      ApiErrorCodes.authInvalidCredentials: 401,
      ApiErrorCodes.authEmailTaken: 409,
      ApiErrorCodes.authDocumentTaken: 409,
      ApiErrorCodes.insufficientFunds: 422,
      ApiErrorCodes.insufficientPosition: 422,
      ApiErrorCodes.marketClosed: 422,
      ApiErrorCodes.instrumentNotFound: 404,
      ApiErrorCodes.orderNotFound: 404,
      ApiErrorCodes.idempotencyConflict: 409,
      ApiErrorCodes.rateLimited: 429,
      ApiErrorCodes.internalError: 500,
    };

    for (final MapEntry<String, int> entry in statusByCode.entries) {
      test('${entry.key} llega como ApiException con su status', () async {
        final _Harness harness = _Harness(
          (RequestOptions options) =>
              problem(entry.value, entry.key, detail: 'detalle'),
        );

        final ApiException error = await _failure(
          harness.client.post('/orders'),
        );

        expect(error.code, entry.key);
        expect(error.status, entry.value);
        expect(error.detail, 'detalle');
      });
    }

    test('un code desconocido se trata como INTERNAL_ERROR', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) => problem(418, 'I_AM_A_TEAPOT'),
      );

      final ApiException error = await _failure(harness.client.post('/x'));

      expect(error.code, ApiErrorCodes.internalError);
      expect(error.status, 418);
    });

    test('un cuerpo que no es problem+json no rompe', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) => ResponseBody.fromString('<html>', 502),
      );

      final ApiException error = await _failure(harness.client.post('/x'));

      expect(error.code, ApiErrorCodes.internalError);
      expect(error.status, 502);
    });

    test('VALIDATION_ERROR trae los errores por campo', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) => problem(
          422,
          ApiErrorCodes.validationError,
          errors: <Map<String, Object?>>[
            <String, Object?>{'field': 'quantity', 'code': 'TOO_LARGE'},
            <String, Object?>{'field': 'email', 'code': 'INVALID_FORMAT'},
          ],
        ),
      );

      final ApiException error = await _failure(harness.client.post('/x'));

      expect(error.fieldErrors, const <ApiFieldError>[
        ApiFieldError(field: 'quantity', code: 'TOO_LARGE'),
        ApiFieldError(field: 'email', code: 'INVALID_FORMAT'),
      ]);
      expect(error.fieldCode('quantity'), 'TOO_LARGE');
      expect(error.fieldCode('password'), isNull);
    });

    test('un 429 trae Retry-After en segundos', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) => problem(
          429,
          ApiErrorCodes.rateLimited,
          headers: <String, List<String>>{
            'retry-after': <String>['30'],
          },
        ),
      );

      final ApiException error = await _failure(harness.client.post('/x'));

      expect(error.retryAfter, const Duration(seconds: 30));
    });

    test('timeout y sin red usan los códigos del cliente', () async {
      final _Harness timeout = _Harness(
        (RequestOptions options) =>
            throw transportError(options, DioExceptionType.receiveTimeout),
      );
      final _Harness offline = _Harness(
        (RequestOptions options) =>
            throw transportError(options, DioExceptionType.connectionError),
      );

      final ApiException timeoutError = await _failure(
        timeout.client.post('/x'),
      );
      final ApiException offlineError = await _failure(
        offline.client.post('/x'),
      );

      expect(timeoutError.code, ApiErrorCodes.networkTimeout);
      expect(timeoutError.isNetwork, isTrue);
      expect(offlineError.code, ApiErrorCodes.networkUnavailable);
      expect(offlineError.status, 0);
    });
  });

  group('interceptor de auth', () {
    test('agrega el Bearer salvo en /auth/*', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) => jsonBody(200, <String, Object?>{}),
      );

      await harness.client.get('/me');
      await harness.client.post('/auth/login');

      expect(
        harness.adapter.calls('GET', '/me').single.headers['Authorization'],
        'Bearer access-old',
      );
      expect(
        harness.adapter
            .calls('POST', '/auth/login')
            .single
            .headers
            .containsKey('Authorization'),
        isFalse,
      );
    });

    test('envía query sin nulos, headers extra y cuerpo', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) => jsonBody(201, <String, Object?>{'ok': 1}),
      );

      final ApiResponse response = await harness.client.post(
        '/orders',
        body: <String, Object?>{'quantity': 10},
        query: <String, Object?>{'a': 1, 'b': null},
        headers: <String, String>{ApiHeaders.idempotencyKey: 'key-1'},
      );

      final RequestOptions sent = harness.adapter.requests.single;
      expect(sent.queryParameters, <String, Object?>{'a': 1});
      expect(sent.headers[ApiHeaders.idempotencyKey], 'key-1');
      expect(sent.data, <String, Object?>{'quantity': 10});
      expect(response.statusCode, 201);
      expect(response.json, <String, Object?>{'ok': 1});
    });
  });

  group('interceptor de refresh', () {
    FakeHandler expiringBackend({required FakeHandler onRefresh}) =>
        (RequestOptions options) {
          if (options.path == '/auth/refresh') {
            return onRefresh(options);
          }
          return options.headers['Authorization'] == 'Bearer access-new'
              ? jsonBody(200, <String, Object?>{'path': options.path})
              : problem(401, ApiErrorCodes.authTokenExpired);
        };

    test('3 peticiones con 401 simultáneas hacen un solo refresh y 3 '
        'reintentos', () async {
      final Completer<void> gate = Completer<void>();
      final _Harness harness = _Harness(
        expiringBackend(
          onRefresh: (RequestOptions options) async {
            await gate.future;
            return jsonBody(200, <String, Object?>{
              'access_token': 'access-new',
              'refresh_token': 'refresh-new',
              'token_type': 'bearer',
              'expires_in': 900,
            });
          },
        ),
      );

      final Future<List<ApiResponse>> all = Future.wait(<Future<ApiResponse>>[
        harness.client.get('/accounts'),
        harness.client.get('/portfolio'),
        harness.client.post('/orders/preview'),
      ]);
      await Future<void>.delayed(Duration.zero);
      gate.complete();
      final List<ApiResponse> responses = await all;

      expect(harness.adapter.calls('POST', '/auth/refresh'), hasLength(1));
      expect(
        harness.adapter.calls('POST', '/auth/refresh').single.data,
        <String, Object?>{'refresh_token': 'refresh-old'},
      );
      expect(harness.adapter.calls('GET', '/accounts'), hasLength(2));
      expect(harness.adapter.calls('GET', '/portfolio'), hasLength(2));
      expect(harness.adapter.calls('POST', '/orders/preview'), hasLength(2));
      expect(responses.map((ApiResponse r) => r.statusCode), <int>[
        200,
        200,
        200,
      ]);
      expect(
        await harness.store.read(),
        const AuthTokens(
          accessToken: 'access-new',
          refreshToken: 'refresh-new',
        ),
      );
      expect(harness.received, isEmpty);
    });

    test(
      'un refresh rechazado limpia el TokenStore y avisa una sola vez',
      () async {
        final _Harness harness = _Harness(
          expiringBackend(
            onRefresh: (RequestOptions options) =>
                problem(401, ApiErrorCodes.authRefreshInvalid),
          ),
        );

        final List<ApiException> errors =
            await Future.wait(<Future<ApiException>>[
              _failure(harness.client.get('/accounts')),
              _failure(harness.client.get('/portfolio')),
            ]);
        await Future<void>.delayed(Duration.zero);

        expect(await harness.store.read(), isNull);
        expect(harness.received, <SessionEvent>[SessionEvent.expired]);
        expect(harness.adapter.calls('POST', '/auth/refresh'), hasLength(1));
        expect(
          errors.map((ApiException e) => e.code),
          everyElement(ApiErrorCodes.authTokenExpired),
        );
      },
    );

    test('un fallo de red durante el refresh no cierra la sesión', () async {
      final _Harness harness = _Harness(
        expiringBackend(
          onRefresh: (RequestOptions options) =>
              throw transportError(options, DioExceptionType.connectionError),
        ),
      );

      final ApiException error = await _failure(harness.client.post('/x'));
      await Future<void>.delayed(Duration.zero);

      expect(error.code, ApiErrorCodes.networkUnavailable);
      expect(await harness.store.read(), _oldTokens);
      expect(harness.received, isEmpty);
    });

    test('AUTH_TOKEN_INVALID cierra la sesión sin intentar refresh', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) =>
            problem(401, ApiErrorCodes.authTokenInvalid),
      );

      final ApiException error = await _failure(harness.client.get('/me'));
      await Future<void>.delayed(Duration.zero);

      expect(error.code, ApiErrorCodes.authTokenInvalid);
      expect(await harness.store.read(), isNull);
      expect(harness.received, <SessionEvent>[SessionEvent.expired]);
      expect(harness.adapter.calls('POST', '/auth/refresh'), isEmpty);
    });

    test('un 401 de login no dispara refresh', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) =>
            problem(401, ApiErrorCodes.authInvalidCredentials),
      );

      final ApiException error = await _failure(
        harness.client.post('/auth/login'),
      );

      expect(error.code, ApiErrorCodes.authInvalidCredentials);
      expect(harness.adapter.requests, hasLength(1));
      expect(await harness.store.read(), _oldTokens);
    });

    test('si el reintento vuelve a dar 401 no entra en bucle', () async {
      final _Harness harness = _Harness((RequestOptions options) {
        if (options.path == '/auth/refresh') {
          return jsonBody(200, <String, Object?>{
            'access_token': 'access-new',
            'refresh_token': 'refresh-new',
          });
        }
        return problem(401, ApiErrorCodes.authTokenExpired);
      });

      final ApiException error = await _failure(harness.client.post('/x'));

      expect(error.code, ApiErrorCodes.authTokenExpired);
      expect(harness.adapter.calls('POST', '/auth/refresh'), hasLength(1));
      expect(harness.adapter.calls('POST', '/x'), hasLength(2));
    });
  });

  group('reintentos', () {
    test('un POST no se reintenta solo', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) =>
            throw transportError(options, DioExceptionType.receiveTimeout),
      );

      await _failure(harness.client.post('/orders'));

      expect(harness.adapter.requests, hasLength(1));
      expect(harness.delays, isEmpty);
    });

    test('un GET se reintenta 2 veces ante timeout, con backoff', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) =>
            throw transportError(options, DioExceptionType.receiveTimeout),
      );

      final ApiException error = await _failure(
        harness.client.get('/instruments'),
      );

      expect(error.code, ApiErrorCodes.networkTimeout);
      expect(harness.adapter.requests, hasLength(3));
      expect(harness.delays, const <Duration>[
        Duration(milliseconds: 500),
        Duration(milliseconds: 1500),
      ]);
    });

    test('un GET se recupera si el 503 era pasajero', () async {
      int calls = 0;
      final _Harness harness = _Harness((RequestOptions options) {
        calls++;
        return calls == 1
            ? problem(503, ApiErrorCodes.internalError)
            : jsonBody(200, <String, Object?>{'ok': true});
      });

      final ApiResponse response = await harness.client.get('/instruments');

      expect(response.statusCode, 200);
      expect(harness.adapter.requests, hasLength(2));
    });

    test('un GET no se reintenta ante un error de negocio', () async {
      final _Harness harness = _Harness(
        (RequestOptions options) =>
            problem(404, ApiErrorCodes.instrumentNotFound),
      );

      await _failure(harness.client.get('/instruments/NOPE-CO'));

      expect(harness.adapter.requests, hasLength(1));
    });
  });
}
