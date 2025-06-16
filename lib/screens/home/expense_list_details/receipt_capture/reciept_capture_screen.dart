import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/cubits/expense_lists/expense_lists_cubit.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/models/purchase_type.dart';
import 'package:expense_management/models/receipt.dart';
import 'package:expense_management/widgets/reciept_input_editor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ReceiptCaptureScreen extends StatefulWidget {
  final ImageSource imageSource;
  final String expenseListId;
  final String currency;
  final List<PurchaseType> purchaseTypes;

  const ReceiptCaptureScreen({
    super.key,
    required this.imageSource,
    required this.expenseListId,
    required this.currency,
    required this.purchaseTypes,
  });

  @override
  State<ReceiptCaptureScreen> createState() => _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends State<ReceiptCaptureScreen> {
  bool loadingApiCall = false;
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> amountControllers = [];
  List<TextEditingController> quantityControllers = [];
  List<PurchaseType> selectedPurchaseTypes = [];
  List<DateTime> selectedDates = [];

  @override
  void initState() {
    pickImage(widget.imageSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.receipt_scanning),
        actions: [
          IconButton(
            onPressed: () {
              if (!loadingApiCall) {
                pickImage(ImageSource.gallery);
              }
            },
            icon: const Icon(Icons.photo),
          ),
          IconButton(
            onPressed: () {
              if (!loadingApiCall) {
                pickImage(ImageSource.camera);
              }
            },
            icon: const Icon(Icons.camera_alt),
          ),
          IconButton(
            onPressed: () {
              if (!loadingApiCall) {
                String dataValidationError = isDataValid();
                if (dataValidationError.isNotEmpty) {
                  Fluttertoast.showToast(
                    msg: dataValidationError,
                    backgroundColor: Theme.of(context).colorScheme.error,
                  );
                  return;
                }
                List<Receipt> reciepts = [];
                for (int i = 0; i < nameControllers.length; i++) {
                  reciepts.add(
                    Receipt(
                      id: FirebaseFirestore.instance.collection('reciepts').doc().id,
                      name: nameControllers[i].text,
                      price: double.parse(amountControllers[i].text),
                      quantity: int.parse(quantityControllers[i].text),
                      purchaseTypeId: selectedPurchaseTypes[i].id,
                      dateTime: selectedDates[i],
                      addedByUserId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  );
                }
                BlocProvider.of<ExpenseListsCubit>(context).addMultipleReciepts(widget.expenseListId, reciepts);
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: loadingApiCall
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: nameControllers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Dismissible(
                  key: ValueKey('$index${nameControllers[index].text}${amountControllers[index].text}${quantityControllers[index].text}${selectedPurchaseTypes[index].id}'),
                  onDismissed: (direction) {
                    nameControllers.removeAt(index);
                    amountControllers.removeAt(index);
                    quantityControllers.removeAt(index);
                    selectedPurchaseTypes.removeAt(index);
                    selectedDates.removeAt(index);
                    setState(() {});
                  },
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RecieptInputEditor(
                          nameController: nameControllers[index],
                          amountController: amountControllers[index],
                          currency: widget.currency,
                          quantityController: quantityControllers[index],
                          selectedPurchaseType: selectedPurchaseTypes[index],
                          onChangedPurchaseType: (newType) {
                            if (newType != null) {
                              selectedPurchaseTypes[index] = newType;
                              setState(() {});
                            }
                          },
                          purchaseTypes: widget.purchaseTypes,
                          selectedDate: selectedDates[index],
                          onSelectDate: () async {
                            DateTime? newDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                            );
                            if (newDate != null) {
                              selectedDates[index] = newDate;
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String isDataValid() {
    for (int i = 0; i < nameControllers.length; i++) {
      if (nameControllers[i].text.trim().isEmpty || amountControllers[i].text.trim().isEmpty || quantityControllers[i].text.trim().isEmpty) {
        return AppLocalizations.of(context)!.error_all_fields_must_be_completed;
      }
      double? price = double.tryParse(amountControllers[i].text.trim());
      if (price == null || price < 0) {
        return AppLocalizations.of(context)!.error_price_not_correct;
      }
      int? quantity = int.tryParse(quantityControllers[i].text.trim());
      if (quantity == null || quantity < 0) {
        return AppLocalizations.of(context)!.error_quanity_whole_number;
      }
    }
    return '';
  }

  Future<void> pickImage(ImageSource source) async {
    String? extractedJson;
    final file = await ImagePicker().pickImage(source: source);
    if (file == null) return;
    setState(() {
      loadingApiCall = true;
    });

    final imageBytes = await File(file.path).readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final prompt = '''
Extract all receipt items in the image and return a JSON array.
Each item from the array should include:
- name (String, the name of the product)
- price (String, price of the product)
- quantity (int, how many items)
- date (String, format should be dd/MM/yyyy)
- purchaseType

The purchase type should be the most suitable one for that specific product from the following: ${widget.purchaseTypes.map((e) => e.toMap()['name']).toList()}.

Return only a valid JSON array, no explanation. Consider the list of products can be in Romanian or English. If the image is not containing a receipt, return an empty array.
''';

    print('PROMT READY. PurchaseTypes: ${widget.purchaseTypes.map((e) => e.toMap()).toList()}');
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${dotenv.env['GEMINI_KEY']!}');

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

    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (resp.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(resp.body);

        // Grab the first candidate's text part
        final parts = (decoded['candidates'][0]['content']['parts'] as List);
        final textPart = parts.firstWhere((p) => p.containsKey('text'), orElse: () => {'text': ''})['text'] as String;

        setState(() => extractedJson = textPart.trim());
        List<Map<String, dynamic>> jsonList = parseReceiptJson(extractedJson!);
        print(jsonList.length);
        for (Map<String, dynamic> map in jsonList) {
          print('$map');
          nameControllers.add(TextEditingController(text: map.containsKey('name') ? map['name'].toString() : ''));
          amountControllers.add(TextEditingController(text: map.containsKey('price') ? map['price'].toString().replaceAll(',', '.') : ''));
          quantityControllers.add(TextEditingController(text: map.containsKey('quantity') ? map['quantity'].toString() : ''));
          try {
            String date = map.containsKey('date') ? map['date'] : DateFormat('dd/MM/yyyy').format(DateTime.now());
            selectedDates.add(DateFormat('dd/MM/yyyy').parse(date));
          } catch (e) {
            print('Error on gen api call on date format: $e');
            selectedDates.add(DateTime.now());
          }
          try {
            String purchaseTypeName = map['purchaseType'];
            PurchaseType selectedPt = widget.purchaseTypes.firstWhere((p) => p.name == purchaseTypeName);
            selectedPurchaseTypes.add(selectedPt);
          } catch (e) {
            print('Error on gen api call on purchase type: $e');
            selectedPurchaseTypes.add(widget.purchaseTypes.first);
          }
        }
        setState(() {});
      } else {
        extractedJson = 'Error ${resp.statusCode}: ${resp.body}';
      }
    } catch (e) {
      extractedJson = 'Error: $e';
    }
    setState(() {
      loadingApiCall = false;
    });
    if (extractedJson != null && extractedJson!.startsWith('Error')) {
      Fluttertoast.showToast(
        msg: extractedJson!,
        backgroundColor: Colors.red,
      );
    }
  }

  List<Map<String, dynamic>> parseReceiptJson(String raw) {
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
