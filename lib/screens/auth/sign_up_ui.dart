import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
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
      return AppLocalizations.of(context)!.email_validation_empty;
    }
    // Simple email pattern: something@something.something
    final RegExp emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );
    if (!emailRegex.hasMatch(email)) {
      return AppLocalizations.of(context)!.email_validation_invalid_email;
    }

    final String password = passwordController.text;
    final String repeatPassword = passwordRepeatController.text;
    if (password.isEmpty) {
      return AppLocalizations.of(context)!.password_validation_no_password;
    }
    // final RegExp passwordRegex = RegExp(
    //   r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$',
    // );
    final RegExp passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^\w\s]).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      return AppLocalizations.of(context)!.password_validation_password_pattern;
    }
    if (password != repeatPassword) {
      return AppLocalizations.of(context)!.password_validation_no_match;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: kPagePadding,
          children: [
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.create_an_account,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 64),
            CustomTextField(
              textEditingController: userController,
              hintText: AppLocalizations.of(context)!.email,
              prefixIcon: const Icon(Icons.mail),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              textEditingController: passwordController,
              hintText: AppLocalizations.of(context)!.password,
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
              hintText: AppLocalizations.of(context)!.repeat_password,
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
            const SizedBox(height: 48),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.sign_up),
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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                BlocProvider.of<AuthCubit>(context).showSignInScreen();
              },
              child: Text(AppLocalizations.of(context)!.already_have_an_account),
            ),
          ],
        ),
      ),
    );
  }
}
