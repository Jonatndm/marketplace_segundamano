import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketplace/models/product.dart';
import 'package:marketplace/repository/product_repository.dart';
import 'package:marketplace/providers/auth_provider.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  late Future<List<Product>> _userProductsFuture;
  final ProductRepository _productRepository = ProductRepository();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProductsFuture = _productRepository.fetchUserProducts(
      authProvider.userId ?? '',
    );
  }

  void _refreshProducts() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _userProductsFuture = _productRepository.fetchUserProducts(
        authProvider.userId ?? '',
      );
    });
  }

  void _editProduct(Product product) {
    // Navegar a la pantalla de edición de producto
    Navigator.pushNamed(context, '/edit-product', arguments: product).then((_) {
      _refreshProducts(); // Refrescar la lista después de editar
    });
  }

  void _markAsSold(String productId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await _productRepository.markProductAsSold(
        productId,
        authProvider.token ?? '',
      );
      _refreshProducts(); // Refrescar la lista después de marcar como vendido
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Producto actualizado a vendido')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar como vendido: $error')),
      );
    }
  }

  void _deleteProduct(String productId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await _productRepository.deleteProduct(
        productId,
        authProvider.token ?? '',
      );
      _refreshProducts(); // Refrescar la lista después de eliminar
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el producto: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Productos')),
      body: FutureBuilder<List<Product>>(
        future: _userProductsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes productos publicados.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading:
                      product.images.isNotEmpty
                          ? Image.network(
                            product.images[0],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.image),
                  title: Text(product.name),
                  subtitle: Text(product.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editProduct(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _markAsSold(product.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
