import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:expense_management/models/reciept.dart';
import 'package:expense_management/widgets/expandable_fab.dart';
import 'package:expense_management/widgets/reciept_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  List<Reciept> recieptItems = [];

  InputImage? inputImage;

  Future<InputImage?> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    inputImage = InputImage.fromFilePath(pickedFile!.path);
    return inputImage;
  }

  Future<String> processImage(InputImage inputImage) async {
    String extractedText = "";
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          extractedText += "${element.text} ";
        }
      }
    }
    // extractedText += "\n\n";
    return extractedText;
  }

  promtGptForAnswer(String processedText) async {
    const String gpt35Turbo = "https://api.openai.com/v1/chat/completions";
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${dotenv.env['OPEN_AI_KEY']}",
    };
    var body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": """You will be provided with data representing a reciept. 
The data was gathered by scanning a reciept, using OCR. 
The data needs to be structured like this:
{
	"date": "the date of the reciept, or null if none was found",
	"items": [
		{
			"name": <name of the product>,
			"quantity": <number representing the number of items aquired>,
			"price": <price of the product>
		}
	]
}
The data needs to be structured in JSON format, containing the complete list of items bought. 
Answer just with the requested JSON."""
          // "content": "You will be provided with data representing a reciept. The data was gathered by scanning a reciept, using OCR. The data needs to be structured in JSON format, containing the complete list of items bought. The data structure should be a list, containing one or more JSON objects with 3 proprieties (name, price and quantity). Answer just with the requested JSON.",
        },
        {
          "role": "user",
          "content": processedText,
        }
      ]
    };

    http.Response response = await http.post(
      Uri.parse(gpt35Turbo),
      headers: headers,
      body: jsonEncode(body),
    );

    log('RESPONSE STATUS CODE: ${response.statusCode}');
    log('RESPONSE STATUS CODE: ${response.body}');
    // print('RESPONSE BODY: ${response.body}');
    String content = jsonDecode(response.body)['choices'][0]['message']['content'];
    // String jsonString = content.substring(content.indexOf('['), content.indexOf(']') + 1);
    String jsonString = content.substring(content.indexOf('{'), content.lastIndexOf('}'));
    log('content: $jsonString');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => RecieptItem(),
        ),
      ),
      floatingActionButton: ExpandableFab(
        children: [
          ActionButton(
            onPressed: () async {
              InputImage? inputImage = await pickImage(ImageSource.gallery);
              if (inputImage == null) {
                return;
              }
              String processedText = await processImage(inputImage);
              log(processedText);
              await promtGptForAnswer(processedText);
            },
            icon: const Icon(Icons.photo),
          ),
          ActionButton(
            onPressed: () async {
              InputImage? inputImage = await pickImage(ImageSource.camera);
              if (inputImage == null) {
                return;
              }
              String processedText = await processImage(inputImage);
              log(processedText);
              await promtGptForAnswer(processedText);
            },
            icon: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
