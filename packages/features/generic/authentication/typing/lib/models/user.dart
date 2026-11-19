import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

/// Usuario con sesión.
class User extends Equatable {
  /// Crea un usuario.
  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.country,
    required this.baseCurrency,
    required this.documentType,
    required this.documentLast4,
  });

  /// Id del usuario.
  final String id;

  /// Email.
  final String email;

  /// Nombre completo.
  final String fullName;

  /// País de registro: define la zona horaria y la moneda base.
  final Country country;

  /// Moneda en la que el dashboard totaliza.
  final Currency baseCurrency;

  /// Tipo de documento.
  final DocumentType documentType;

  /// Últimos 4 caracteres del documento. El número completo nunca llega al
  /// cliente después del registro.
  final String documentLast4;

  /// Primer nombre, para el saludo.
  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;

  /// Copia el usuario cambiando algunos campos.
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    Country? country,
    Currency? baseCurrency,
    DocumentType? documentType,
    String? documentLast4,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    country: country ?? this.country,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    documentType: documentType ?? this.documentType,
    documentLast4: documentLast4 ?? this.documentLast4,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    email,
    fullName,
    country,
    baseCurrency,
    documentType,
    documentLast4,
  ];
}
