import 'package:expense_management/models/response.dart';

sealed class CreateListState {}

final class CreateListInitial extends CreateListState {}

final class CreateListLoading extends CreateListState {}

final class CreateListCompleted extends CreateListState {}

final class CreateListFailed extends CreateListState {
  final Response response;

  CreateListFailed(this.response);
}
