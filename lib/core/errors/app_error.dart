import 'package:equatable/equatable.dart';

abstract class AppError extends Equatable implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code, originalError];

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkError extends AppError {
  const NetworkError({
    super.message = 'Sin conexión a internet. Revisa tu red.',
    super.code,
    super.originalError,
  });
}

class PlayerError extends AppError {
  const PlayerError({
    super.message = 'Error al reproducir el audio. Intenta de nuevo.',
    super.code,
    super.originalError,
  });
}

class DownloadError extends AppError {
  const DownloadError({
    super.message = 'Error al descargar el archivo.',
    super.code,
    super.originalError,
  });
}

class StorageError extends AppError {
  const StorageError({
    super.message = 'Error al leer o guardar datos locales.',
    super.code,
    super.originalError,
  });
}

class PermissionError extends AppError {
  const PermissionError({
    super.message = 'No se tienen los permisos necesarios para esta acción.',
    super.code,
    super.originalError,
  });
}

class UnknownError extends AppError {
  const UnknownError({
    super.message = 'Ocurrió un error inesperado. Intenta de nuevo más tarde.',
    super.code,
    super.originalError,
  });
}
