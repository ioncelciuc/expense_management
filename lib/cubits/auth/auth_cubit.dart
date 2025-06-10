import 'package:expense_management/cubits/auth/auth_state.dart';
import 'package:expense_management/helpers/firebase_helper.dart';
import 'package:expense_management/models/response.dart';
import 'package:expense_management/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    checkIfUserIsSignedIn();
  }

  checkIfUserIsSignedIn() {
    if (FirebaseAuth.instance.currentUser == null) {
      emit(AuthShowSignInScreen());
    } else {
      emit(AuthShowHomeScreen());
    }
  }

  showSignUpScreen() {
    emit(AuthShowSignUpScreen());
  }

  showSignInScreen() {
    emit(AuthShowSignInScreen());
  }

  signUp(String email, String password) async {
    try {
      emit(AuthLoading());
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        UserModel userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
        );
        await FirebaseHelper.addUser(userModel);
        emit(AuthShowHomeScreen());
        return;
      }
      emit(AuthShowSignUpScreenError(Response(success: false, message: 'Unknown error occured')));
    } on FirebaseAuthException catch (e) {
      emit(AuthShowSignUpScreenError(Response(success: false, message: e.message)));
    } catch (e) {
      emit(AuthShowSignUpScreenError(Response(success: false, message: e.toString())));
    }
  }

  signIn(String email, String password) async {
    try {
      emit(AuthLoading());
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      emit(AuthShowHomeScreen());
    } on FirebaseAuthException catch (e) {
      print('CAUGHT A FIREBASE LOGIN ERROR!');
      emit(AuthShowSignInScreenError(Response(success: false, message: e.message)));
    } catch (e) {
      print('CAUGHT A GENERAL LOGIN ERROR!');
      emit(AuthShowSignInScreenError(Response(success: false, message: e.toString())));
      print(e);
    }
  }

  signOut() async {
    try {
      emit(AuthLoading());
      await FirebaseAuth.instance.signOut();
      if (FirebaseAuth.instance.currentUser == null) {
        emit(AuthShowSignInScreen());
        return;
      }
    } catch (e) {
      //
    }
  }
}
