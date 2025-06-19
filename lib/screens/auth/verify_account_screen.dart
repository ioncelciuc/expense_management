import 'dart:async';

import 'package:expense_management/core/constants.dart';
import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  late AuthCubit authCubit;
  bool isEmailVerified = false;
  Timer? timer;

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) {
      authCubit.checkIfUserIsSignedIn();
    }
  }

  @override
  void initState() {
    authCubit = BlocProvider.of<AuthCubit>(context);
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
              AppLocalizations.of(context)!.verify_your_account,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 64),
            Text(
              '${AppLocalizations.of(context)!.we_sent_an_email_for_verification_at} ${FirebaseAuth.instance.currentUser?.email}.\n${AppLocalizations.of(context)!.verify_it_and_come_back_into_the_app}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<AuthCubit>(context).signOut();
              },
              child: Text(AppLocalizations.of(context)!.sign_out),
            ),
          ],
        ),
      ),
    );
  }
}
