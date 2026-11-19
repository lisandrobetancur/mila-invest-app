import 'package:authentication/authentication.dart';
import 'package:authentication_constants/authentication_constants.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typing/typing.dart';

import 'support/harness.dart';

void main() {
  final Set<String> es = translationKeys(authenticationLanguages['es']!);
  final Set<String> en = translationKeys(authenticationLanguages['en']!);

  group('AuthIds', () {
    test('cumplen la convención y no se repiten', () {
      for (final String id in AuthIds.all) {
        expect(identifierPattern.hasMatch(id), isTrue, reason: id);
      }
      expect(AuthIds.all.toSet().length, AuthIds.all.length);
    });
  });

  group('traducciones', () {
    test('es y en tienen las mismas claves, de tres niveles o más', () {
      expect(es.difference(en), isEmpty);
      expect(en.difference(es), isEmpty);
      for (final String key in es) {
        expect(key.split('.').length, greaterThanOrEqualTo(3), reason: key);
      }
    });

    test('cada código de error tiene su mensaje en los dos idiomas', () {
      for (final AuthErrorCode code in AuthErrorCode.values) {
        expect(es, contains(code.messageKey), reason: code.name);
        expect(en, contains(code.messageKey), reason: code.name);
      }
    });

    test('cada tipo de documento tiene etiqueta y mensaje de error', () {
      for (final DocumentType type in DocumentType.values) {
        final String code = type.code.toLowerCase();
        expect(es, contains('auth.field_error.document_${code}_invalid'));
        if (type != DocumentType.ce) {
          expect(es, contains('auth.register.document_$code'));
        }
      }
      expect(es, contains('auth.register.document_ce_co'));
      expect(es, contains('auth.register.document_ce_pe'));
    });
  });

  group('AuthErrorCode', () {
    test('mapea los códigos del contrato y cae en unknown', () {
      expect(
        AuthErrorCode.fromApiCode('AUTH_INVALID_CREDENTIALS'),
        AuthErrorCode.invalidCredentials,
      );
      expect(
        AuthErrorCode.fromApiCode('AUTH_EMAIL_TAKEN'),
        AuthErrorCode.emailTaken,
      );
      expect(
        AuthErrorCode.fromApiCode('NETWORK_TIMEOUT'),
        AuthErrorCode.network,
      );
      expect(AuthErrorCode.fromApiCode('OTRO'), AuthErrorCode.unknown);
      expect(AuthErrorCode.network.isNetwork, isTrue);
      expect(AuthErrorCode.documentTaken.isFieldError, isTrue);
      expect(AuthErrorCode.invalidCredentials.isFieldError, isFalse);
    });
  });
}
