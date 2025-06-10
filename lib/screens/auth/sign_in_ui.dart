import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/auth/auth_cubit.dart';
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
              'Welcome to\nExpense Management!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 64),
            CustomTextField(
              textEditingController: userController,
              hintText: 'Email',
              prefixIcon: const Icon(Icons.mail),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              textEditingController: passwordController,
              hintText: 'Password',
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
                    //
                  },
                  child: Text(
                    'Forgot password?',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Text('Sign In'),
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
              child: Text('Don\'t have an account? Create one here!'),
            ),
          ],
        ),
      ),
    );
  }
}
