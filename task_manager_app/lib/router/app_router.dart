 import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/presentation/main_screen.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/login_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.unauthenticated:
          case AuthStatus.error: 
          case AuthStatus.loading: return const LoginScreen();
          case AuthStatus.authenticated: // return const TaskListScreen();
            return const MainScreen();
        }
      },
    );
  }
}
