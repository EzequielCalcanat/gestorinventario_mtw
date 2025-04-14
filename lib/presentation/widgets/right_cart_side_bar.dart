import 'package:flutter/material.dart';

class RightCartSidebar extends StatelessWidget {
  const RightCartSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Carrito",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                  "Tu carrito está vacío.",
                  textAlign: TextAlign.right,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cerrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
