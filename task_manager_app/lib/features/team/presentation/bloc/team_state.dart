import '../../../auth/models/user_model.dart';

enum TeamStatus {
  initial,
  loading,
  success,
  error,
}

class TeamState {
  final TeamStatus status;
  final List<UserModel> users;
  final String? errorMessage;

  const TeamState({
    this.status = TeamStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  TeamState copyWith({
    TeamStatus? status,
    List<UserModel>? users,
    String? errorMessage,
  }) {
    return TeamState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }
}
