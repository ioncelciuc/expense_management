import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/widgets/custom_button.dart';
import 'package:expense_management/widgets/custom_text_field.dart';
import 'package:expense_management/widgets/snackbar_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpUi extends StatefulWidget {
  const SignUpUi({super.key});

  @override
  State<SignUpUi> createState() => _SignUpUiState();
}

class _SignUpUiState extends State<SignUpUi> {
  bool obscureText = true;
  bool obscureTextRepeatPass = true;
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRepeatController = TextEditingController();

  String isDataValid() {
    final String email = userController.text.trim();
    if (email.isEmpty) {
      return 'Email can\'t be empty';
    }
    // Simple email pattern: something@something.something
    final RegExp emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    final String password = passwordController.text;
    final String repeatPassword = passwordRepeatController.text;
    if (password.isEmpty) {
      return 'You must choose a password';
    }
    final RegExp passwordRegex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$',
    );
    if (!passwordRegex.hasMatch(password)) {
      return 'Password must be at least 8 characters long and contain:\n'
          'An uppercase character\n'
          'A lowercase character\n'
          'A number';
    }
    if (password != repeatPassword) {
      return 'Passwords don\'t match';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 32),
          Text(
            'Create an account',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          CustomTextField(
            textEditingController: userController,
            hintText: 'email',
            prefixIcon: const Icon(Icons.mail),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            textEditingController: passwordController,
            hintText: 'password',
            prefixIcon: const Icon(Icons.password),
            obscureText: obscureText,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            textEditingController: passwordRepeatController,
            hintText: 'repeat password',
            prefixIcon: const Icon(Icons.password),
            obscureText: obscureTextRepeatPass,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureTextRepeatPass = !obscureTextRepeatPass;
                });
              },
              icon: Icon(
                obscureTextRepeatPass ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            title: 'Sign Up',
            onPressed: () {
              String isDataValidMessage = isDataValid();
              if (isDataValidMessage.isNotEmpty) {
                SnackbarHandler(
                  context: context,
                  message: isDataValidMessage,
                  durationSeconds: 8,
                );
              } else {
                BlocProvider.of<AuthCubit>(context).signUp(
                  userController.text,
                  passwordController.text,
                );
              }
            },
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              BlocProvider.of<AuthCubit>(context).showSignInScreen();
            },
            child: Text('Alreadt have an account? Sign In!'),
          ),
        ],
      ),
    );
  }
}
