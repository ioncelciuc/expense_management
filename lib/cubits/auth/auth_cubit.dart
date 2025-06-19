import 'package:expense_management/cubits/auth/auth_state.dart';
import 'package:expense_management/helpers/firebase_helper.dart';
import 'package:expense_management/models/response.dart';
import 'package:expense_management/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class AuthCubit extends Cubit<AuthState> {
  final logger = Logger('AuthCubit');

  AuthCubit() : super(AuthInitial()) {
    checkIfUserIsSignedIn();
  }

  checkIfUserIsSignedIn() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      emit(AuthShowSignInScreen());
    } else if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      emit(AuthShowVerifyAccountScreen());
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

  showVerifyAccountScreen() {
    emit(AuthShowVerifyAccountScreen());
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
        checkIfUserIsSignedIn();
        // emit(AuthShowHomeScreen());
        return;
      }
      emit(AuthShowSignUpScreenError(Response(success: false, message: 'Unknown error occured')));
    } on FirebaseAuthException catch (e) {
      logger.severe(e.message);
      emit(AuthShowSignUpScreenError(Response(success: false, message: e.message)));
    } catch (e) {
      logger.severe(e.toString());
      emit(AuthShowSignUpScreenError(Response(success: false, message: e.toString())));
    }
  }

  signIn(String email, String password) async {
    try {
      emit(AuthLoading());
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      checkIfUserIsSignedIn();
      // emit(AuthShowHomeScreen());
    } on FirebaseAuthException catch (e) {
      logger.severe(e.message);
      emit(AuthShowSignInScreenError(Response(success: false, message: e.message)));
    } catch (e) {
      logger.severe(e);
      emit(AuthShowSignInScreenError(Response(success: false, message: e.toString())));
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
      logger.severe(e.toString());
    }
  }

  sendResetPasswordEmail(String email) {
    try {
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      logger.severe(e.message);
    } catch (e) {
      logger.severe(e.toString());
    }
  }

  sendVerifyAccountEmail() {
    try {
      FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (e) {
      logger.severe(e.toString());
    }
  }
}
