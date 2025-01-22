import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'api_log_saver.dart';

class LogSaverDioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log request details
    _logToDatabase(
      options.uri.toString(),
      options.method,
      options.headers,
      options.data,
      null,
      "Request initiated",
    );
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response details
    _logToDatabase(
      response.requestOptions.uri.toString(),
      response.requestOptions.method,
      response.requestOptions.headers,
      response.requestOptions.data,
      response.statusCode,
      "Response received",
    );
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error details
    _logToDatabase(
      err.requestOptions.uri.toString(),
      err.requestOptions.method,
      err.requestOptions.headers,
      err.requestOptions.data,
      err.response?.statusCode,
      "Error: ${err.message}",
    );
    return handler.next(err);
  }

  Future<void> _logToDatabase(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
    int? statusCode,
    String message,
  ) async {
    try {
      await ApiLogSaver.instance.logRequest(
        url,
        method,
        headers,
        body,
        statusCode,
        message,
      );
    } catch (e) {
      // Handle any logging errors (optional)
    }
  }

  static Future<Uint8List> exportLogsToCSVAsBytes(
      {DateTime? startDate,
      DateTime? endDate,
      String? message,
      String? url,
      String? method}) async {
    return await ApiLogSaver.instance.exportLogsToCSVAsBytes(
      startDate: startDate,
      endDate: endDate,
      message: message,
      url: url,
      method: method,
    );
  }

  static Future<void> clearLogs() async {
    return await ApiLogSaver.instance.clearLogs();
  }
}
