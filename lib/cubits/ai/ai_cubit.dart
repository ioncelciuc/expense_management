import 'dart:convert';

import 'package:expense_management/cubits/ai/ai_state.dart';
import 'package:expense_management/helpers/network_helper.dart';
import 'package:expense_management/models/response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiCubit extends Cubit<AiState> {
  AiCubit() : super(AiInitial());

  emitInitial() {
    emit(AiInitial());
  }

  getFinancialSuggestion(String prompt) async {
    emit(AiLoading());
    try {
      Response response = await NetworkHelper.geminiApiCall(prompt);
      if (response.success) {
        final Map<String, dynamic> decoded = jsonDecode(response.obj as String);
        final parts = (decoded['candidates'][0]['content']['parts'] as List);
        String advice = parts.firstWhere((p) => p.containsKey('text'), orElse: () => {'text': ''})['text'] as String;
        emit(AiFinancialAdviceCompleted(advice));
      } else {
        emit(AiFailed(response));
      }
    } catch (e) {
      emit(AiFailed(Response(success: false, message: e.toString())));
    }
  }
}
