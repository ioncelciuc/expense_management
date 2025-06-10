import 'package:flutter/material.dart';

class SnackbarHandler {
  final String message;
  final BuildContext context;
  final int durationSeconds;
  final bool isError;

  SnackbarHandler({
    required this.message,
    required this.context,
    this.isError = true,
    this.durationSeconds = 4,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: durationSeconds),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
