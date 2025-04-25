import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/models/cart.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:provider/provider.dart';

class ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductRow({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar producto?"),
        content: const Text("¿Estás seguro de que deseas eliminar este producto?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  Color _stockColor(int stock) {
    if (stock <= 5) return const Color(0xFFFFCDD2); // rojo pastel claro
    if (stock <= 15) return const Color(0xFFFFF9C4); // amarillo pastel claro
    return const Color(0xFFC8E6C9); // verde pastel claro
  }

  String _stockText(int stock) {
    if (stock == 1) return '1 disponible';
    return '$stock disponibles';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: const Icon(Icons.inventory_2, color: Colors.grey),
          title: Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Precio por unidad: \$${product.price.toStringAsFixed(2)} MXN',
                style: const TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _stockColor(product.stock),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _stockText(product.stock),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
            ],
          ),
          trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
        ),
      ),
    );
  }
}

class BranchRow extends StatelessWidget {
  final Branch branch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BranchRow({
    Key? key,
    required this.branch,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar sucursal?"),
        content: const Text("¿Estás seguro de que deseas eliminar esta sucursal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(branch.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.transparent,
            width: 2,
          ),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: const Icon(Icons.store, color: Colors.grey),
          title: Text(
            branch.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: Text(
            branch.location ?? 'Ubicación no disponible',
            style: const TextStyle(color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}

class UserRow extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserRow({
    Key? key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color _badgeColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFE8D5F7); // Morado claro pastel
      case 'employee':
        return const Color(0xFFD6EAF8); // Azul claro pastel
      case 'sales':
        return const Color(0xFFFFF9C4); // Amarillo suave pastel
      default:
        return Colors.grey.shade200;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'employee':
        return 'Empleado';
      case 'sales':
        return 'Ventas';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(user.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: const Icon(Icons.person, color: Colors.grey),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.email,
                style: const TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _badgeColor(user.role),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _roleLabel(user.role),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
            ],
          ),
          trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar usuario?"),
        content: const Text("¿Estás seguro de que deseas eliminar este usuario?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}

class SalesRow extends StatelessWidget {
  final Product product;

  const SalesRow({
    Key? key,
    required this.product,
  }) : super(key: key);

  Color _stockColor(int stock) {
    if (stock <= 5) {
      return Colors.redAccent.shade100;
    } else if (stock <= 15) {
      return Colors.amber.shade100;
    } else {
      return Colors.green.shade100;
    }
  }

  String _stockLabel(int stock) {
    return '$stock ${stock == 1 ? "disponible" : "disponibles"}';
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final quantity = cart.items[product] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)} por unidad',
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _stockColor(product.stock),
                borderRadius: BorderRadius.circular(12),
              ),
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
    );
  }
}

class ClientRow extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClientRow({
    Key? key,
    required this.client,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(client.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: const Icon(Icons.person, color: Colors.grey),
          title: Text(
            client.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.email,
                style: const TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              if (client.phone != null && client.phone!.isNotEmpty)
                Text(
                  client.phone!,
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar cliente?"),
        content: const Text("¿Estás seguro de que deseas eliminar este cliente?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}
