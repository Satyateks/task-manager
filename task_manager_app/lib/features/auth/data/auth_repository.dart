import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRepository({required this.apiClient, required this.tokenStorage});

  Future<UserModel> login({
      required String email,
      required String password,
    }) async {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid email or password');
      }
      print('..............................21$data');
      await tokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      // Poora response map pass karein kyunki tokens root par hain aur user andar hai
      return UserModel.fromJson(data);
    }

  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.signup,
      data: {'name': name, 'email': email, 'password': password},
    );

    return UserModel.fromJson(response.data['user']);
  }

  Future<void> logout() async {
    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken != null) {
      await apiClient.dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    }

    await tokenStorage.clearTokens();
  }

  Future<UserModel?> checkSession() async {
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    try {
      // return UserModel(id: 0, // Default ya stored IDname: 'User',email: '',accessToken: accessToken,refreshToken: await tokenStorage.getRefreshToken() ?? '');
      return null;
    } catch (error) {
      return null;
    }
  }
}
