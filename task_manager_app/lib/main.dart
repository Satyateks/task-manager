import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/bloc/task_cubit.dart';
import 'features/team/data/user_repository.dart';
import 'features/team/presentation/bloc/team_cubit.dart';
import 'router/app_router.dart';


void main() {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);

  final authRepository = AuthRepository(apiClient: apiClient,tokenStorage: tokenStorage);
  final taskRepository = TaskRepository(apiClient: apiClient);
  final userRepository = UserRepository(apiClient: apiClient);



  runApp(
    MultiBlocProvider(
      providers: [
       BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepository: authRepository,tokenStorage: tokenStorage)),
       BlocProvider<TaskCubit>(create: (_) => TaskCubit(taskRepository: taskRepository)),
       BlocProvider(create: (_) => TeamCubit(userRepository: userRepository)..loadUsers()),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AppRoot(),
    );
  }
}
