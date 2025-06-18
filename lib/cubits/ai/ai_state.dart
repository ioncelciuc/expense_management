import 'package:expense_management/models/response.dart';

sealed class AiState {}

final class AiInitial extends AiState {}

final class AiLoading extends AiState {}

final class AiFinancialAdviceCompleted extends AiState {
  String advice;

  AiFinancialAdviceCompleted(this.advice);
}

final class AiFailed extends AiState {
  final Response response;

  AiFailed(this.response);
}
