import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/models/sale_item.dart';
import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/models/cart.dart';
import 'package:provider/provider.dart';

class ProductRow extends StatefulWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductRow({Key? key, required this.product, required this.onEdit, required this.onDelete}) : super(key: key);

  @override
  _ProductRowState createState() => _ProductRowState();
}

class _ProductRowState extends State<ProductRow> {
  bool _isExpanded = false;

  Color _stockColor(int stock) {
    if (stock <= 5) return const Color(0xFFFFCDD2);
    if (stock <= 15) return const Color(0xFFFFF9C4);
    return const Color(0xFFC8E6C9);
  }

  String _stockText(int stock) => stock == 1 ? '1 disponible' : '$stock disponibles';

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar producto?"),
        content: const Text("¿Estás seguro de eliminar este producto? no se borrará de las ventas ya realizadas."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DismissibleCard(
      key: ValueKey(widget.product.id),
      onConfirmDelete: () => _confirmDelete(context),
      onDelete: widget.onDelete,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2, color: Colors.grey),
                title: Text(
                  widget.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precio: \$${widget.product.price.toStringAsFixed(2)} MXN',
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _stockColor(widget.product.stock),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _stockText(widget.product.stock),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (_isExpanded) ...[
                      const SizedBox(height: 8),
                      if (widget.product.description != null)
                        Text(
                          'Descripción: ${widget.product.description!}',
                          style: const TextStyle(fontSize: 13),
                        ),
                    ]
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: widget.onEdit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BranchRow extends StatelessWidget {
  final Branch branch;
  final VoidCallback onEdit;

  const BranchRow({
    Key? key,
    required this.branch,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _NonDismissibleCard(
      key: ValueKey(branch.id),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: const Icon(Icons.store, color: Colors.grey),
        title: Text(
          branch.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          branch.location ?? 'Ubicación no disponible',
          style: const TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: onEdit,
        ),
      ),
    );
  }
}

class UserRow extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserRow({Key? key, required this.user, required this.onEdit, required this.onDelete}) : super(key: key);

  Color _badgeColor(String role) {
    switch (role) {
      case 'admin': return const Color(0xFFE8D5F7);
      case 'employee': return const Color(0xFFD6EAF8);
      case 'sales': return const Color(0xFFFFF9C4);
      default: return Colors.grey.shade200;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin': return 'Administrador';
      case 'employee': return 'Empleado';
      case 'sales': return 'Ventas';
      default: return 'Desconocido';
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar usuario?"),
        content: const Text("¿Seguro que deseas eliminar este usuario? "),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DismissibleCard(
      key: ValueKey(user.id),
      onConfirmDelete: () => _confirmDelete(context),
      onDelete: onDelete,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: const Icon(Icons.person, color: Colors.grey),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: const TextStyle(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _badgeColor(user.role), borderRadius: BorderRadius.circular(8)),
              child: Text(
                _roleLabel(user.role),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          ],
        ),
        trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
      ),
    );
  }
}

class ClientRow extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClientRow({Key? key, required this.client, required this.onEdit, required this.onDelete}) : super(key: key);

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar cliente?"),
        content: const Text("¿Seguro que deseas eliminar este cliente?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DismissibleCard(
      key: ValueKey(client.id),
      onConfirmDelete: () => _confirmDelete(context),
      onDelete: onDelete,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: const Icon(Icons.person, color: Colors.grey),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.email,
              style: const TextStyle(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (client.phone != null && client.phone!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    client.phone!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
      ),
    );
  }
}

class SalesRow extends StatelessWidget {
  final Product product;

  const SalesRow({Key? key, required this.product}) : super(key: key);

  Color _stockColor(int stock) {
    if (stock <= 5) return Colors.redAccent.shade100;
    if (stock <= 15) return Colors.amber.shade100;
    return Colors.green.shade100;
  }

  String _stockLabel(int stock) => '$stock ${stock == 1 ? "disponible" : "disponibles"}';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final quantity = cart.items[product] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          leading: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
          title: Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)} MXN por unidad',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _stockColor(product.stock), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  _stockLabel(product.stock),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.black54),
                onPressed: quantity > 0 ? () => cart.removeItem(product) : null,
              ),
              Text('$quantity', style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black54),
                onPressed: quantity < product.stock ? () => cart.addItem(product) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget base para todos los non dismissible (no se pueden eliminar)
class _NonDismissibleCard extends StatelessWidget {
  final Key key;
  final Widget child;

  const _NonDismissibleCard({
    required this.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pueden eliminar las sucursales."),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.lock_outline,
            color: Colors.white,
          ),
        ),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: child,
        ),
      ),
    );
  }
}

// Widget base para todos los Dismissible (se pueden eliminar)
class _DismissibleCard extends StatelessWidget {
  final Key key;
  final Widget child;
  final Future<bool?> Function() onConfirmDelete;
  final VoidCallback onDelete;

  const _DismissibleCard({
    required this.key,
    required this.child,
    required this.onConfirmDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // MÁS DELGADO
      child: Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => onConfirmDelete(),
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: child,
        ),
      ),
    );
  }
}

class SaleRow extends StatelessWidget {
  final SaleItem sale;

  const SaleRow({Key? key, required this.sale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: const Icon(Icons.receipt_long, color: Colors.grey),
        title: Text(
          sale.clientName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sale.totalProducts} productos',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            Text(
              'Método: ${sale.paymentMethodName}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // <-- Para empujar arriba y abajo
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${sale.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.green, // <-- Precio en verde
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(sale.date),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}