import 'package:flutter_test/flutter_test.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

void main() {
  group('Validators.email', () {
    test('acepta emails con formato válido', () {
      expect(Validators.isEmail('demo@milainvest.app'), isTrue);
      expect(Validators.isEmail('ana.maria+test@sub.dominio.co'), isTrue);
    });

    test('rechaza emails con espacios o sin dominio', () {
      expect(Validators.isEmail('demo @milainvest.app'), isFalse);
      expect(Validators.isEmail('demo@milainvest'), isFalse);
      expect(Validators.isEmail('demo'), isFalse);
      expect(Validators.isEmail(''), isFalse);
    });

    test('normaliza a minúsculas y sin espacios alrededor', () {
      expect(
        Validators.normalizeEmail('  Demo@MilaInvest.App '),
        'demo@milainvest.app',
      );
    });
  });

  group('Validators.password', () {
    test('pide 8 caracteres, una letra y un número', () {
      expect(Validators.isPassword('Demo1234!'), isTrue);
      expect(Validators.isPassword('Demo123'), isFalse);
      expect(Validators.isPassword('solamenteletras'), isFalse);
      expect(Validators.isPassword('12345678'), isFalse);
    });

    test('expone cada requisito por separado para el indicador', () {
      expect(Validators.passwordHasMinLength('12345678'), isTrue);
      expect(Validators.passwordHasLetter('12345678'), isFalse);
      expect(Validators.passwordHasNumber('abcdefgh'), isFalse);
    });
  });

  group('Validators.fullName', () {
    test('pide entre 3 y 80 caracteres', () {
      expect(Validators.isFullName('Ana'), isTrue);
      expect(Validators.isFullName('An'), isFalse);
      expect(Validators.isFullName('a' * 80), isTrue);
      expect(Validators.isFullName('a' * 81), isFalse);
    });
  });

  group('Validators.documento', () {
    test('CC colombiana: 6 a 10 dígitos', () {
      expect(_doc(Country.co, DocumentType.cc, '1012345678'), isTrue);
      expect(_doc(Country.co, DocumentType.cc, '123456'), isTrue);
      expect(_doc(Country.co, DocumentType.cc, '12345'), isFalse);
      expect(_doc(Country.co, DocumentType.cc, '12345678901'), isFalse);
      expect(_doc(Country.co, DocumentType.cc, '10123A5678'), isFalse);
    });

    test('CE colombiana: 6 a 12 alfanuméricos', () {
      expect(_doc(Country.co, DocumentType.ce, 'A1234567'), isTrue);
      expect(_doc(Country.co, DocumentType.ce, 'A1234'), isFalse);
      expect(_doc(Country.co, DocumentType.ce, 'A' * 13), isFalse);
      expect(_doc(Country.co, DocumentType.ce, 'A123-567'), isFalse);
    });

    test('CURP mexicana: 18 caracteres con su estructura', () {
      expect(_doc(Country.mx, DocumentType.curp, 'MAGL850315HDFRRS09'), isTrue);
      expect(_doc(Country.mx, DocumentType.curp, 'magl850315hdfrrs09'), isTrue);
      expect(
        _doc(Country.mx, DocumentType.curp, 'MAGL850315XDFRRS09'),
        isFalse,
      );
      expect(_doc(Country.mx, DocumentType.curp, 'MAGL850315HDFRRS0'), isFalse);
    });

    test('DNI peruano: exactamente 8 dígitos', () {
      expect(_doc(Country.pe, DocumentType.dni, '12345678'), isTrue);
      expect(_doc(Country.pe, DocumentType.dni, '1234567'), isFalse);
      expect(_doc(Country.pe, DocumentType.dni, '123456789'), isFalse);
    });

    test('CE peruana: 9 a 12 alfanuméricos', () {
      expect(_doc(Country.pe, DocumentType.ce, '001234567'), isTrue);
      expect(_doc(Country.pe, DocumentType.ce, '00123456'), isFalse);
      expect(_doc(Country.pe, DocumentType.ce, 'A' * 12), isTrue);
    });

    test('rechaza un tipo que el país no acepta', () {
      expect(_doc(Country.co, DocumentType.dni, '12345678'), isFalse);
      expect(_doc(Country.mx, DocumentType.cc, '1012345678'), isFalse);
    });

    test('normaliza el documento antes de validar', () {
      expect(_doc(Country.co, DocumentType.cc, ' 1012345678 '), isTrue);
      expect(
        Validators.normalizeDocument(DocumentType.curp, 'magl 850315hdfrrs09'),
        'MAGL850315HDFRRS09',
      );
    });
  });
}

bool _doc(Country country, DocumentType type, String raw) =>
    Validators.isDocumentNumber(country: country, type: type, raw: raw);
