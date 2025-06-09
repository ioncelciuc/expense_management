import 'package:expense_management/cubits/auth/auth_cubit.dart';
import 'package:expense_management/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Hello, ${FirebaseAuth.instance.currentUser!.email}'),
          CustomButton(
            title: 'Sign Out',
            onPressed: () {
              BlocProvider.of<AuthCubit>(context).signOut();
            },
          ),
        ],
      ),
    );
  }
}
