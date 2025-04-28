import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutterinventory/data/models/cart.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/repositories/client_repository.dart';
import 'package:flutterinventory/data/services/sale_service.dart';
import 'package:flutterinventory/presentation/screens/clients/client_form_screen.dart';
import 'package:flutterinventory/presentation/screens/payment/payment_status.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Cart cart = Cart();
  Client? _selectedClient;
  List<Client> _clients = [];
  bool _isProcessing = false;
  String _paymentMethod = 'Efectivo';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await ClientRepository.getAllClients(isActive: 1);
    if (mounted) {
      setState(() {
        _clients = clients;
      });
    }
  }

  Future<void> _navigateToAddClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ClientFormScreen(
              onSave: () async {
                await _loadClients();
              },
            ),
      ),
    );

    if (result == true) {
      final refreshedClients = await ClientRepository.getAllClients(
        isActive: 1,
      );
      if (mounted) {
        setState(() {
          _clients = refreshedClients;
          _selectedClient =
              refreshedClients.isNotEmpty ? refreshedClients.last : null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = cart.items.entries.toList();

    return BaseScaffold(
      title: "Proceder a Pagar",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cliente",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownSearch<Client>(
              items: _clients,
              itemAsString: (client) => client.name,
              selectedItem: _selectedClient,
              onChanged: (client) {
                if (client != _selectedClient) {
                  setState(() {
                    _selectedClient = client;
                  });
                }
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Seleccionar Cliente",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue.shade600,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              filterFn:
                  (client, filter) =>
                      client.name.toLowerCase().contains(filter.toLowerCase()),
              popupProps: const PopupProps.menu(showSearchBox: true),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _navigateToAddClient,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Agregar nuevo cliente"),
            ),
            const SizedBox(height: 30),

            const Text(
              "Resumen de la Compra",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...items.map((entry) {
              final Product product = entry.key;
              final int quantity = entry.value;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                subtitle: Text(
                  "$quantity x \$${product.price.toStringAsFixed(2)}",
                ),
                trailing: Text(
                  "\$${(product.price * quantity).toStringAsFixed(2)}",
                ),
              );
            }).toList(),
            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${cart.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Método de Pago",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: StatefulBuilder(
                      builder: (context, setLocalState) {
                        return SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'Efectivo',
                              label: Text('Efectivo'),
                            ),
                            ButtonSegment(
                              value: 'Tarjeta',
                              label: Text('Tarjeta'),
                            ),
                          ],
                          selected: {_paymentMethod},
                          onSelectionChanged: (selection) {
                            setLocalState(() {
                              _paymentMethod = selection.first;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, "/sales"),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Regresar"),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _handleConfirmPressed,
                    icon:
                        _isProcessing
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.check),
                    label: Text(_isProcessing ? "Procesando..." : "Confirmar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3491B3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleConfirmPressed() {
    if (_selectedClient == null) {
      _showError("⚠️ Debes seleccionar un cliente para continuar.");
      return;
    }

    if (_paymentMethod == 'Efectivo') {
      _confirmEfectivo();
    } else {
      _showCardPaymentSheet();
    }
  }

  Future<void> _confirmEfectivo() async {
    setState(() => _isProcessing = true);

    try {
      await SaleService.createSaleTransaction(
        cart: cart,
        paymentMethodName: _paymentMethod,
        clientId: _selectedClient!.id,
      );

      cart.clear();

      if (mounted) {
        setState(() => _isProcessing = false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PaymentStatusScreen(success: true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showError("Hubo un error al registrar la venta. Intenta nuevamente.");
      }
    }
  }

  void _showCardPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: IntrinsicHeight(
            child: _CardPaymentForm(
              totalAmount: cart.total,
              onPaymentSuccess: _confirmCardPaymentSuccess,
            ),
          ),
        );
      },
    );
  }

  void _confirmCardPaymentSuccess() async {
    await _confirmEfectivo();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _CardPaymentForm extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onPaymentSuccess;

  const _CardPaymentForm({
    required this.totalAmount,
    required this.onPaymentSuccess,
  });

  @override
  State<_CardPaymentForm> createState() => _CardPaymentFormState();
}

class _CardPaymentFormState extends State<_CardPaymentForm> {
  final _cardNumberController = TextEditingController();
  final _expDateController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isPaying = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pagar con Tarjeta",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [CreditCardNumberInputFormatter()],
          decoration: const InputDecoration(
            labelText: "Número de Tarjeta",
            prefixIcon: Icon(Icons.credit_card),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expDateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  _ExpiryDateTextInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: "Vencimiento (MM/AA)",
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: "CVV",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isPaying ? null : _handlePayment,
            child: Text(
              _isPaying
                  ? "Procesando..."
                  : "Pagar \$${widget.totalAmount.toStringAsFixed(2)} MXN",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3491B3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePayment() async {
    if (_cardNumberController.text.isEmpty ||
        _expDateController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isPaying = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isPaying = false);

    Navigator.pop(context);
    widget.onPaymentSuccess();
  }
}

class _ExpiryDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');

    if (text.length >= 3) {
      text = text.substring(0, 2) + '/' + text.substring(2);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
