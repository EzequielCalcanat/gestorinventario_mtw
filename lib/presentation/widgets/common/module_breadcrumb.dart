import 'package:flutter/material.dart';

class ModuleBreadcrumb extends StatelessWidget {
  final String text;

  const ModuleBreadcrumb({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
      ),
    );
  }
}
