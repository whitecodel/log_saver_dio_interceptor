# LogSaverDioInterceptor Flutter Package

The `LogSaverDioInterceptor` is a Flutter package designed to integrate seamlessly with the `Dio` HTTP client. It enables developers to log API requests, responses, and errors to a database, with additional support for exporting logs as CSV files and clearing log history.

## Features

- Log API requests, responses, and errors with detailed information.
- Export logged data as a CSV file for analysis.
- Filter logs by date, message, URL, and HTTP method during export.
- Clear all logs with a single function.
- Easy integration with any Flutter application using the Dio client.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  log_saver_dio_interceptor:
```

Then run:

```bash
flutter pub get
```

## Usage

### Adding the Interceptor

Integrate the `LogSaverDioInterceptor` with your Dio instance:

```dart
import 'package:dio/dio.dart';
import 'log_saver_dio_interceptor.dart';

final dio = Dio();
dio.interceptors.add(LogSaverDioInterceptor());
```

### Export Logs to CSV

To export logs as a CSV file:

```dart
import 'dart:typed_data';

final Uint8List csvBytes = await LogSaverDioInterceptor.exportLogsToCSVAsBytes(
  startDate: DateTime(2023, 1, 1),
  endDate: DateTime(2023, 12, 31),
  message: "Error",
  method: "GET",
);

// Save `csvBytes` to a file or share it
```

### Clear Logs

To clear all logged data:

```dart
await LogSaverDioInterceptor.clearLogs();
```

### Log Structure

The package logs the following information for each API request:

- **URL**: The endpoint of the API request.
- **Method**: HTTP method (GET, POST, PUT, DELETE, etc.).
- **Headers**: Request headers.
- **Body**: Request body.
- **Status Code**: Response status code.
- **Message**: Custom messages indicating the type of log (e.g., "Request initiated", "Response received", "Error: message").

## Example

Below is a complete example integrating `LogSaverDioInterceptor`:

```dart
import 'package:dio/dio.dart';
import 'log_saver_dio_interceptor.dart';

void main() async {
  final dio = Dio();
  dio.interceptors.add(LogSaverDioInterceptor());

  try {
    final response = await dio.get('https://jsonplaceholder.typicode.com/posts/1');
    print(response.data);
  } catch (e) {
    print(e);
  }

  // Export logs to CSV
  final csvBytes = await LogSaverDioInterceptor.exportLogsToCSVAsBytes();
  // Handle `csvBytes` as needed

  // Clear logs
  await LogSaverDioInterceptor.clearLogs();
}
```

## Dependencies

This package depends on:

- [Dio](https://pub.dev/packages/dio): For making HTTP requests.

## Contributing

Contributions are welcome! Please create a pull request or open an issue on the GitHub repository if you encounter any problems or have feature suggestions.

## License

This package is licensed under the MIT License. See the LICENSE file for details.

---

For questions or support, feel free to reach out to the package maintainer.
