import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../data/app_shared_pref.dart';

Dio dioClient(String baseUrl) {
  final dio = Dio();

  dio.options = BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10000), receiveTimeout: const Duration(seconds: 10000));

  dio.interceptors.addAll([
    InterceptorsWrapper(
      onRequest: requestInterceptor,
      onResponse: responseInterceptor,
      onError: (DioException error, ErrorInterceptorHandler handler) {
        return errorInterceptor(error, handler, dio);
      },
    ),
  ]);

  return dio;
}

dynamic requestInterceptor(RequestOptions request, RequestInterceptorHandler handler) async {
  // Check if we should skip auth (for GCS upload URLs)
  bool skipAuth = request.extra['skipAuth'] == true;

  if (!skipAuth) {
    //add token to header
    request.headers.addAll({'Content-Type': 'application/json'});

    await FirebaseAuth.instance.currentUser?.uid;

    final token = AppSharedPref.getToken();
    if (token != '') {
      request.headers.addAll({'Authorization': 'Bearer $token'});
    }
  }

  Logger().i({request.method: request.uri, 'headers': request.headers, 'body': request.data});
  return handler.next(request);
}

dynamic responseInterceptor(Response response, ResponseInterceptorHandler handler) async {
  Logger().i('API ${response.requestOptions.uri}:');
  Logger().i('STATUS: ${response.statusCode}');
  Logger().i('HEADERS: ${response.headers}');
  Logger().i('DATA: ${response.data}');

  if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
    dynamic data = response.data;
    return handler.next(Response(requestOptions: response.requestOptions, data: data));
  }
  return DioException(requestOptions: response.requestOptions, error: response.data);
}

dynamic errorInterceptor(DioException error, ErrorInterceptorHandler handler, Dio dio) async {
  Logger().e('API ${error.requestOptions.uri}:');
  Logger().e('TYPE: ${error.type}');
  Logger().e('MESSAGE: ${error.message}');
  Logger().e('RESPONSE: ${error.response?.data}');
  Logger().e('ERROR STATUS CODE: ${error.response?.statusCode}');

  try {
    if (error.response?.statusCode == 401) {
      // Get a new token from Firebase
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          // Force token refresh (not using the cached token)
          final newIdToken = await currentUser.getIdToken(true);

          if (newIdToken != null && newIdToken.isNotEmpty) {
            // Update token in storage
            print('========newIdToken==========$newIdToken');
            await AppSharedPref.setToken(newIdToken);
            print('Token refreshed successfully');
            // Retry the original request with the new token
            RequestOptions requestOptions = error.requestOptions.copyWith();
            requestOptions.headers['Authorization'] = 'Bearer $newIdToken';

            final opts = Options(method: requestOptions.method, headers: requestOptions.headers);

            try {
              final result = await dio.request(requestOptions.path, options: opts, data: requestOptions.data, queryParameters: requestOptions.queryParameters);

              // Return successful response through handler.resolve
              return handler.resolve(result);
            } catch (retryError) {
              print('Retry request failed: $retryError');
              return handler.next(DioException(requestOptions: requestOptions, error: retryError));
            }
          }
        } catch (refreshError) {
          print('Failed to refresh token: $refreshError');
          // Continue to error handling below
        }
      }
    }
  } catch (e) {
    print('Error in error interceptor: $e');
    // AppSharedPref.removeToken();
    // AppSharedPref.removeRefreshToken();
    //navigatorKey.currentState?.pushReplacementNamed(AppRoutes.login, arguments: {'expiredToken': true});
  }

  // Pass through the original error if token refresh failed or not a 401 error
  return handler.next(error);
}

Future<Map<String, dynamic>> apiCallToRefreshToken(Dio dio) async {
  try {
    final oldRefreshToken = AppSharedPref.getRefreshToken();
    final Response response = await dio.post('/auth/token/refresh', data: {'refreshToken': oldRefreshToken});
    if (response.statusCode == 200) {
      String newToken = response.data['accessToken'];
      String newRefreshToken = response.data['refreshToken'];
      return {'token': newToken, 'refreshToken': newRefreshToken};
    } else {
      throw Exception('Failed to refresh token');
    }
  } catch (error) {
    throw Exception('Error refreshing token: $error');
  }
}
