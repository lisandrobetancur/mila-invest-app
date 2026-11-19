import 'package:authentication/core/data/authentication_remote_data_source.dart';
import 'package:authentication/core/data/dto/registration_dto.dart';
import 'package:authentication/core/data/dto/tokens_dto.dart';
import 'package:authentication/core/data/dto/user_dto.dart';
import 'package:authentication/core/service/service.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:fake_backend/fake_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

class _MockApiClient extends Mock implements ApiClient {}

final class _Setup {
  _Setup({ApiClient? client}) {
    this.client =
        client ??
        FakeApiClient(
          tokenStore: store,
          sessionEvents: SessionEvents(),
          clock: FixedClock(DateTime.utc(2026, 11, 18, 14, 42)),
        );
    service = AuthenticationService(
      dataSource: AuthenticationRemoteDataSource(this.client),
      tokenStore: store,
    );
  }

  final InMemoryTokenStore store = InMemoryTokenStore();
  late final ApiClient client;
  late final AuthenticationService service;
}

Matcher _authError(AuthErrorCode code) => throwsA(
  isA<AuthException>().having((AuthException e) => e.code, 'code', code),
);

const RegistrationData _registration = RegistrationData(
  email: 'nueva@correo.pe',
  password: 'Segura123',
  fullName: 'Libia',
  country: Country.pe,
  documentType: DocumentType.dni,
  documentNumber: '45678912',
);

void main() {
  group('DTOs', () {
    test('UserDto parsea el /me del contrato', () {
      final User user = UserDto.fromJson(const <String, Object?>{
        'id': 'usr_1',
        'email': 'demo@milainvest.app',
        'full_name': 'Licho Demo',
        'country': 'CO',
        'base_currency': 'COP',
        'document_type': 'CC',
        'document_last4': '5678',
      }).toDomain();

      expect(user.country, Country.co);
      expect(user.baseCurrency, Currency.cop);
      expect(user.documentType, DocumentType.cc);
      expect(user.firstName, 'Licho');
    });

    test('UserDto rechaza un campo ausente o un país desconocido', () {
      expect(
        () => UserDto.fromJson(const <String, Object?>{'id': 'usr_1'}),
        throwsFormatException,
      );
      expect(
        () => UserDto.fromJson(const <String, Object?>{
          'id': 'usr_1',
          'email': 'a@b.co',
          'full_name': 'Ana',
          'country': 'AR',
          'base_currency': 'COP',
          'document_type': 'CC',
          'document_last4': '1234',
        }),
        throwsFormatException,
      );
    });

    test('TokensDto exige los dos tokens y no los expone en toString', () {
      final TokensDto dto = TokensDto.fromJson(const <String, Object?>{
        'access_token': 'secreto-a',
        'refresh_token': 'secreto-r',
        'token_type': 'bearer',
        'expires_in': 900,
      });

      expect(dto.toDomain().refreshToken, 'secreto-r');
      expect(dto.toString(), isNot(contains('secreto')));
      expect(
        () => TokensDto.fromJson(const <String, Object?>{'access_token': 'a'}),
        throwsFormatException,
      );
    });

    test(
      'el registro viaja en snake_case y su respuesta exige user y tokens',
      () {
        expect(
          RegistrationRequestDto.fromDomain(_registration).toJson(),
          <String, Object?>{
            'email': 'nueva@correo.pe',
            'password': 'Segura123',
            'full_name': 'Libia',
            'country': 'PE',
            'document_type': 'DNI',
            'document_number': '45678912',
          },
        );
        expect(
          () => RegistrationResponseDto.fromJson(const <String, Object?>{}),
          throwsFormatException,
        );
      },
    );
  });

  group('AuthenticationService contra el backend falso', () {
    test('login guarda los tokens y devuelve el usuario', () async {
      final _Setup setup = _Setup();

      final User user = await setup.service.login(
        email: FakeDemoAccount.email,
        password: FakeDemoAccount.password,
      );

      expect(user.email, FakeDemoAccount.email);
      expect(user.documentLast4, '5678');
      expect(await setup.store.read(), isNotNull);
    });

    test('credenciales incorrectas dan invalidCredentials', () async {
      final _Setup setup = _Setup();

      await expectLater(
        setup.service.login(email: FakeDemoAccount.email, password: 'mal'),
        _authError(AuthErrorCode.invalidCredentials),
      );
      expect(await setup.store.read(), isNull);
    });

    test('registro guarda la sesión del usuario nuevo', () async {
      final _Setup setup = _Setup();

      final User user = await setup.service.register(_registration);

      expect(user.baseCurrency, Currency.pen);
      expect(user.documentLast4, '8912');
      expect(await setup.store.read(), isNotNull);
    });

    test('un email repetido llega como error del campo email', () async {
      final _Setup setup = _Setup();

      try {
        await setup.service.register(
          const RegistrationData(
            email: FakeDemoAccount.email,
            password: 'Segura123',
            fullName: 'Otra Persona',
            country: Country.co,
            documentType: DocumentType.cc,
            documentNumber: '52345678',
          ),
        );
        fail('Se esperaba AuthException');
      } on AuthException catch (error) {
        expect(error.code, AuthErrorCode.emailTaken);
        expect(error.fieldMessageKeys, <AuthField, String>{
          AuthField.email: AuthErrorCode.emailTaken.messageKey,
        });
      }
    });

    test('VALIDATION_ERROR traduce cada campo a su clave', () async {
      final _Setup setup = _Setup();

      try {
        await setup.service.register(
          const RegistrationData(
            email: 'x@y.co',
            password: 'corta',
            fullName: 'Daniela',
            country: Country.co,
            documentType: DocumentType.cc,
            documentNumber: '12',
          ),
        );
        fail('Se esperaba AuthException');
      } on AuthException catch (error) {
        expect(error.code, AuthErrorCode.validation);
        expect(error.fieldMessageKeys, <AuthField, String>{
          AuthField.password: 'auth.field_error.too_weak',
          AuthField.documentNumber: 'auth.field_error.invalid_format',
        });
      }
    });

    test('restoreSession: sin tokens no consulta y devuelve null', () async {
      final _MockApiClient client = _MockApiClient();
      final _Setup setup = _Setup(client: client);

      expect(await setup.service.restoreSession(), isNull);
      verifyZeroInteractions(client);
    });

    test('restoreSession: con sesión válida devuelve el usuario', () async {
      final _Setup setup = _Setup();
      await setup.service.login(
        email: FakeDemoAccount.email,
        password: FakeDemoAccount.password,
      );

      final User? user = await setup.service.restoreSession();

      expect(user?.email, FakeDemoAccount.email);
    });

    test('restoreSession: un token inválido limpia la sesión', () async {
      final _Setup setup = _Setup();
      await setup.store.save(
        const AuthTokens(accessToken: 'vencido', refreshToken: 'vencido'),
      );

      expect(await setup.service.restoreSession(), isNull);
      expect(await setup.store.read(), isNull);
    });

    test('restoreSession: un error de red no descarta la sesión', () async {
      final _MockApiClient client = _MockApiClient();
      when(
        () => client.get('/me'),
      ).thenThrow(const ApiException.networkUnavailable());
      final _Setup setup = _Setup(client: client);
      await setup.store.save(
        const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      );

      await expectLater(
        setup.service.restoreSession(),
        _authError(AuthErrorCode.network),
      );
      expect(await setup.store.read(), isNotNull);
    });

    test('una respuesta con otra forma es unexpectedResponse', () async {
      final _MockApiClient client = _MockApiClient();
      when(
        () => client.post('/auth/login', body: any(named: 'body')),
      ).thenAnswer(
        (_) async => const ApiResponse(statusCode: 200, body: <Object?>[]),
      );
      final _Setup setup = _Setup(client: client);

      await expectLater(
        setup.service.login(email: 'a@b.co', password: 'x'),
        _authError(AuthErrorCode.unexpectedResponse),
      );
    });

    test('logout limpia los tokens aunque el servidor falle', () async {
      final _MockApiClient client = _MockApiClient();
      when(
        () => client.post('/auth/logout', body: any(named: 'body')),
      ).thenThrow(const ApiException.networkTimeout());
      final _Setup setup = _Setup(client: client);
      await setup.store.save(
        const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      );

      await setup.service.logout();

      expect(await setup.store.read(), isNull);
      verify(
        () => client.post(
          '/auth/logout',
          body: <String, Object?>{'refresh_token': 'r'},
        ),
      ).called(1);
    });
  });
}
