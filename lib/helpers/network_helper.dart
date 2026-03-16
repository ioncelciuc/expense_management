import 'dart:convert';

import 'package:expense_management/models/response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NetworkHelper {
  static Future<Response> geminiApiCall(String prompt) async {
    try {
      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${dotenv.env['GEMINI_KEY']!}');
      final body = jsonEncode({
        'contents': [
          {
            'role': 'USER',
            'parts': [
              {
                'text': prompt,
              }
            ]
          }
        ]
      });
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (resp.statusCode == 200) {
        return Response(success: true, obj: resp.body);
      }
      return Response(
        success: false,
        message: '${resp.statusCode}: ${resp.body}',
      );
    } catch (e) {
      return Response(
        success: false,
        message: e.toString(),
      );
    }
  }

  static Future<Response> geminiImageApiCall(String prompt, String base64Image) async {
    try {
      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${dotenv.env['GEMINI_KEY']!}');

      final body = jsonEncode({
        'contents': [
          {
            'role': 'USER',
            'parts': [
              {
                'inlineData': {
                  'mimeType': 'image/jpeg',
                  'data': base64Image,
                }
              },
              {
                'text': prompt,
              }
            ]
          }
        ]
      });

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (resp.statusCode == 200) {
        return Response(success: true, obj: resp.body);
      }
      return Response(
        success: false,
        message: '${resp.statusCode}: ${resp.body}',
      );
    } catch (e) {
      return Response(
        success: false,
        message: e.toString(),
      );
    }
  }
}
