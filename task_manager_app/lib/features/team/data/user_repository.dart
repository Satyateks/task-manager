import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/models/user_model.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  Future<List<UserModel>> getUsers() async {
    final response = await apiClient.dio.get(ApiConstants.users);
    final List<dynamic> users = response.data['users'];
    return users.map((json) => UserModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
