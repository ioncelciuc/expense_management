import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/screens/auth/reset_password_screen.dart';
import 'package:expense_management/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInUi extends StatefulWidget {
  const SignInUi({super.key});

  @override
  State<SignInUi> createState() => _SignInUiState();
}

class _SignInUiState extends State<SignInUi> {
  bool obscureText = true;
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: kPagePadding,
          children: [
            const SizedBox(height: 32),
            Text(
              '${AppLocalizations.of(context)!.welcome_to}\n${AppLocalizations.of(context)!.app_name}!',
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
            const SizedBox(height: 16),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.forgot_password,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.sign_in),
              onPressed: () {
                BlocProvider.of<AuthCubit>(context).signIn(
                  userController.text,
                  passwordController.text,
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                BlocProvider.of<AuthCubit>(context).showSignUpScreen();
              },
              child: Text(AppLocalizations.of(context)!.dont_have_an_account),
            ),
          ],
        ),
      ),
    );
  }
}
