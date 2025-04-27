import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterinventory/presentation/widgets/right_cart_side_bar.dart';
import 'package:flutterinventory/data/models/cart.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/branch_repository.dart';
import 'package:flutterinventory/data/repositories/login_repository.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> {
  String userBranchName = '';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userBranchName = prefs.getString('user_branch_name') ?? 'Sin sucursal';
      userRole = prefs.getString('user_role') ?? 'guest';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final itemCount = cart.totalItems;

    return AppBar(
      backgroundColor: const Color(0xFF3491B3),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            userBranchName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[200],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        if (userRole == 'admin')
          IconButton(
            icon: const Icon(Icons.storefront_sharp),
            onPressed: () {
              showBranchSelector(context);
            },
          ),
        const SizedBox(width: 10),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Future.delayed(Duration.zero, () {
                  showCartDetails(context);
                });
              },
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$itemCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            showMenuOptions(context);
          },
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/default_user.png'),
            radius: 20,
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  void showMenuOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opciones'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Ver Perfil'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuraciones'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar Sesión'),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('logged_user_id');

                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showCartDetails(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Cart",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const RightCartSidebar();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  void showBranchSelector(BuildContext context) async {
    List<Branch> activeBranches = await BranchRepository.getAllBranches(
      isActive: 1,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Sucursal'),
          content: SingleChildScrollView(
            child: Column(
              children:
                  activeBranches.map((branch) {
                    return ListTile(
                      title: Text(branch.name),
                      onTap: () async {
                        await LoginRepository.updateUserBranchId(branch.id);
                        setState(() {
                          userBranchName = branch.name;
                        });
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}
