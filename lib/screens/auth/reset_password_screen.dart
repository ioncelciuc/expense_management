import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/widgets/custom_text_field.dart';
import 'package:expense_management/widgets/snackbar_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController userController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.reset_password)),
      body: SafeArea(
        child: ListView(
          padding: kPagePadding,
          children: [
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.reset_password_explanation,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 64),
            CustomTextField(
              textEditingController: userController,
              hintText: AppLocalizations.of(context)!.email,
              prefixIcon: const Icon(Icons.mail),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.send_email),
              onPressed: () async {
                String emailValidationError = isDataValid();
                if (emailValidationError.isNotEmpty) {
                  SnackbarHandler(context: context, message: emailValidationError);
                  return;
                }

                BlocProvider.of<AuthCubit>(context).sendResetPasswordEmail(userController.text);

                Navigator.of(context).pop();
                SnackbarHandler(
                  message: '${AppLocalizations.of(context)!.email_sent_at} ${userController.text.trim()}',
                  context: context,
                  isError: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
    return '';
  }
}
