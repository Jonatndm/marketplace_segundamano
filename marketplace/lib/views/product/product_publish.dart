import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:marketplace/repository/product_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marketplace/models/product.dart'; // Asegúrate de importar el modelo Product

class PublishProductScreen extends StatefulWidget {
  final Product? product;
  const PublishProductScreen({super.key, this.product});

  @override
  PublishProductScreenState createState() => PublishProductScreenState();
}

class PublishProductScreenState extends State<PublishProductScreen> {
  final _formKey = GlobalKey<FormState>();
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  String _title = '';
  String _description = '';
  double _price = 0.0;
  double? _latitude;
  double? _longitude;
  List<String> _categories = ['Electrónica'];
  final ProductRepository _productRepository = ProductRepository();

  @override
  void initState() {
    super.initState();
    _getLocation();

    // Si se proporciona un producto, cargar sus datos
    if (widget.product != null) {
      _title = widget.product!.name;
      _description = widget.product!.description;
      _price = widget.product!.price;
      _categories = widget.product!.categories;
      _images = widget.product!.images.map((image) => File(image)).toList();
    }
  }

  // Método para obtener la ubicación
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('El servicio de ubicación está desactivado');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener la ubicación: $error')),
        );
      }
    }
  }

  // Método para seleccionar imágenes
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
    });
  }

  // Método para eliminar una imagen
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // Método para enviar el formulario
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No se pudo obtener la ubicación')),
        );
        return;
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final userId = prefs.getString('userId');

        if (token == null || userId == null) {
          throw Exception('Usuario no autenticado');
        }

        List<String> imagePaths = _images.map((file) => file.path).toList();

        if (imagePaths.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Has ingresado más de 5 imágenes')),
          );
          return;
        }

        if (widget.product == null) {
          // Crear un nuevo producto
          await _productRepository.createProduct(
            name: _title,
            description: _description,
            price: _price,
            latitude: _latitude!,
            longitude: _longitude!,
            categories: _categories,
            imagePaths: imagePaths,
            token: token,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Producto creado correctamente')),
            );
          }
        } else {
          // Editar un producto existente
          await _productRepository.updateProduct(
            productId: widget.product!.id,
            name: _title,
            description: _description,
            price: _price,
            categories: _categories,
            imagePaths: imagePaths,
            token: token,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Producto actualizado correctamente')),
            );
          }
        }

        _formKey.currentState!.reset();
        setState(() {
          _images.clear();
        });
        if(widget.product != null){
          Navigator.pop(context);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear/actualizar el producto: $error')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Publicar Producto' : 'Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Subir imágenes (máximo 5)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _images.length < 5
                  ? ElevatedButton(
                      onPressed: _pickImages,
                      child: Text('Seleccionar imágenes'),
                    )
                  : Text('Has alcanzado el límite de 5 imágenes'),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.file(_images[index], fit: BoxFit.cover),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _removeImage(index),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                initialValue: _title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                initialValue: _description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                initialValue: _price.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                value: _categories.isNotEmpty ? _categories.first : null,
                items: ['Electrónica', 'Ropa', 'Hogar', 'Deportes', 'Otros']
                    .map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categories = [value!];
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: Text(
                  widget.product == null ? 'Publicar Producto' : 'Guardar Cambios',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}