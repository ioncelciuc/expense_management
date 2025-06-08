import 'package:flutter/material.dart';

class RecieptItem extends StatelessWidget {
  const RecieptItem({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Row(
      children: [
        Container(
          height: 40,
          color: Colors.grey,
          child: Text('100'),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Product Name',
            ),
          ),
        ),
        Container(
          width: 70,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Price',
            ),
          ),
        ),
        ElevatedButton(onPressed: () {}, child: Text('2024-10-11')),
      ],
    );
  }
}
