import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final TokenStorage tokenStorage;

  late final Dio dio;

  bool _isRefreshing = false;

  ApiClient(this.tokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token =
              await tokenStorage.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] =
                'Bearer $token';
          }

          handler.next(options);
        },

        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            handler.next(error);
            return;
          }

          final request = error.requestOptions;

          // Refresh API ko dobara refresh nahi karna
          if (request.path == ApiConstants.refresh) {
            await tokenStorage.clearTokens();
            handler.next(error);
            return;
          }

          if (_isRefreshing) {
            handler.next(error);
            return;
          }

          _isRefreshing = true;

          try {
            final refreshToken =
                await tokenStorage.getRefreshToken();

            if (refreshToken == null || refreshToken.isEmpty) {
              await tokenStorage.clearTokens();
              handler.next(error);
              return;
            }

            final refreshResponse = await dio.post(
              ApiConstants.refresh,
              data: {
                'refreshToken': refreshToken,
              },
            );

            final newAccessToken =
                refreshResponse.data['accessToken'];

            final newRefreshToken =
                refreshResponse.data['refreshToken'];

            await tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            request.headers['Authorization'] =
                'Bearer $newAccessToken';

            final response = await dio.fetch(
              request,
            );

            handler.resolve(response);
          } catch (refreshError) {
            await tokenStorage.clearTokens();

            handler.next(error);
          } finally {
            _isRefreshing = false;
          }
        },
      ),
    );
  }
}
