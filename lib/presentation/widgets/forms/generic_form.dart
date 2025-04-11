import 'package:flutter/material.dart';

typedef FormFieldBuilder = List<Widget> Function(
    Map<String, dynamic> formData,
    void Function(String key, dynamic value) onChanged,
    );

class GenericForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final FormFieldBuilder buildFields;
  final void Function(Map<String, dynamic>) onSubmit;

  const GenericForm({
    super.key,
    required this.initialData,
    required this.buildFields,
    required this.onSubmit,
  });

  @override
  State<GenericForm> createState() => _GenericFormState();
}

class _GenericFormState extends State<GenericForm> {
  late Map<String, dynamic> formData;

  @override
  void initState() {
    super.initState();
    formData = Map.from(widget.initialData);
  }

  void _onChanged(String key, dynamic value) {
    setState(() {
      formData[key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Construir los campos dinámicamente
          ...widget.buildFields(formData, _onChanged),

          // Botón para enviar el formulario
          ElevatedButton(
            onPressed: () => widget.onSubmit(formData),
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
