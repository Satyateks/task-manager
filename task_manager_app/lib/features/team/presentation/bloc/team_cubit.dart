import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/user_repository.dart';
import 'team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final UserRepository userRepository;

  TeamCubit({
    required this.userRepository,
  }) : super(const TeamState());

  Future<void> loadUsers() async {
    emit(state.copyWith(status: TeamStatus.loading,),);

    try {
      final users = await userRepository.getUsers();

      emit(
        state.copyWith(
          status: TeamStatus.success,
          users: users,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TeamStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
