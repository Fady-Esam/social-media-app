import 'package:flutter/material.dart';

class CheckAuthenticationCusomRow extends StatelessWidget {
  const CheckAuthenticationCusomRow({
    super.key,
    required this.questionText,
    required this.text,
    required this.onTap,
  });

  final String questionText;
  final String text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          questionText,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            text,
            style: const TextStyle(
              decoration: TextDecoration.underline,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
