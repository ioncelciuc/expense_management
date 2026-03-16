import 'package:expense_management/models/response.dart';

sealed class ReceiptCaptureState {}

final class ReceiptCaptureInitial extends ReceiptCaptureState {}

final class ReceiptCaptureLoading extends ReceiptCaptureState {}

final class ReceiptCaptureSuccess extends ReceiptCaptureState {
  final List<Map<String, dynamic>> items;

  ReceiptCaptureSuccess(this.items);
}

final class ReceiptCaptureFailure extends ReceiptCaptureState {
  final Response response;

  ReceiptCaptureFailure(this.response);
}
