import 'package:equatable/equatable.dart';

/// Respuesta exitosa (2xx) de la API: status y cuerpo ya decodificado.
class ApiResponse extends Equatable {
  /// Crea una respuesta.
  const ApiResponse({required this.statusCode, this.body});

  /// Código HTTP.
  final int statusCode;

  /// Cuerpo decodificado: `Map`, `List` o `null` (204).
  final Object? body;

  /// Cuerpo como objeto JSON.
  ///
  /// Lanza [FormatException] si el cuerpo no es un objeto: es un contrato
  /// roto, no algo que se acepte en silencio.
  Map<String, Object?> get json {
    final Object? value = body;
    if (value is Map<String, Object?>) {
      return value;
    }
    throw FormatException(
      'Se esperaba un objeto JSON y llegó ${value.runtimeType}',
    );
  }

  /// Cuerpo como lista JSON.
  ///
  /// Lanza [FormatException] si el cuerpo no es una lista.
  List<Object?> get jsonList {
    final Object? value = body;
    if (value is List<Object?>) {
      return value;
    }
    throw FormatException(
      'Se esperaba una lista JSON y llegó ${value.runtimeType}',
    );
  }

  @override
  List<Object?> get props => <Object?>[statusCode, body];
}
