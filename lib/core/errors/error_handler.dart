import 'dart:io';
import 'package:hive/hive.dart';
import 'app_error.dart';

class ErrorHandler {
  static AppError handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    if (error is SocketException || error is HttpException) {
      return NetworkError(originalError: error);
    }

    if (error is HiveError) {
      return StorageError(
        message: 'Error en la base de datos local: ${error.message}',
        originalError: error,
      );
    }

    // Default error
    return UnknownError(
      message: 'Ocurrió un error inesperado. Intenta de nuevo más tarde.',
      originalError: error,
    );
  }
}
