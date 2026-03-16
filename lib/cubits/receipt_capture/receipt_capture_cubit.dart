import 'dart:convert';
import 'package:expense_management/cubits/receipt_capture/receipt_capture_state.dart';
import 'package:expense_management/helpers/network_helper.dart';
import 'package:expense_management/models/response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReceiptCaptureCubit extends Cubit<ReceiptCaptureState> {
  ReceiptCaptureCubit() : super(ReceiptCaptureInitial());

  Future<void> processReceipt(String prompt, String base64Image) async {
    emit(ReceiptCaptureLoading());
    try {
      Response response = await NetworkHelper.geminiImageApiCall(prompt, base64Image);
      if (response.success) {
        final Map<String, dynamic> decoded = jsonDecode(response.obj as String);

        // Grab the first candidate's text part
        final parts = (decoded['candidates'][0]['content']['parts'] as List);
        final textPart = parts.firstWhere((p) => p.containsKey('text'), orElse: () => {'text': ''})['text'] as String;

        List<Map<String, dynamic>> jsonList = _parseReceiptJson(textPart.trim());
        emit(ReceiptCaptureSuccess(jsonList));
      } else {
        emit(ReceiptCaptureFailure(response));
      }
    } catch (e) {
      emit(ReceiptCaptureFailure(Response(success: false, message: e.toString())));
    }
  }

  List<Map<String, dynamic>> _parseReceiptJson(String raw) {
    //Remove the markdown fences if present
    final cleaned = raw
        .replaceAll(RegExp(r'```json\s*'), '') // remove leading ```json
        .replaceAll(RegExp(r'\s*```$'), '') // remove trailing ```
        .trim();

    //Decode
    final decoded = jsonDecode(cleaned);

    //Cast and return
    return (decoded as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
