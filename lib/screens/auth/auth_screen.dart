import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/cubits/auth/auth_state.dart';
import 'package:expense_management/screens/auth/sign_in_ui.dart';
import 'package:expense_management/screens/auth/sign_up_ui.dart';
import 'package:expense_management/screens/home/home_screen.dart';
import 'package:expense_management/widgets/snackbar_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthShowSignInScreenError) {
          print('SIGN IN ERROR');
          SnackbarHandler(
            message: state.response.message ?? 'An error was encountered',
            context: context,
            isError: true,
          );
        }
        if (state is AuthShowSignUpScreenError) {
          SnackbarHandler(
            message: state.response.message ?? 'An error was encountered',
            context: context,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is AuthShowSignInScreen || state is AuthShowSignInScreenError) {
          return const SignInUi();
        }
        if (state is AuthShowSignUpScreen || state is AuthShowSignUpScreenError) {
          return const SignUpUi();
        }
        return const HomeScreen();
      },
    );
  }
}
