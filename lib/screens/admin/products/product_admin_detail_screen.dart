import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/product.dart';
import '../../../services/payments/upload_image.dart';
import '../../../widgets/admin/products/product_form.dart';
import '../../../widgets/payments/image_viewer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../my_home_page.dart'; // Asegúrate de importar la clase

class AdminProductDetailScreen extends StatefulWidget {
  final Product product;

  const AdminProductDetailScreen({required this.product, Key? key}) : super(key: key);

  @override
  _AdminProductDetailScreenState createState() => _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String? _status; // Para manejar el estado del producto
  String? _category; // Agregamos la variable para la categoría
  String? _imageUrl; // Para manejar la URL de la imagen

  String? placeHolderImage = dotenv.env['PLACE_HOLDER_URL'];

  bool _isEditingName = false;
  bool _isEditingDescription = false;
  bool _isEditingPrice = false;
  bool _isEditingStock = false;

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores con los datos del producto
    _nameController.text = widget.product.name;
    _descriptionController.text = widget.product.description;

    // Mostrar el precio en el formato correcto
    _priceController.text = (widget.product.price).toStringAsFixed(2).replaceAll('.', ','); // Mostrar como "55,00"
    _stockController.text = widget.product.stock.toString();
    _imageUrl = widget.product.imageUrl;
    _category = widget.product.category; // Inicializar la categoría
    // Asignar el estado en español
    _status = widget.product.status == 'active' ? 'Activo' : 'Inactivo';
  }


  Future<void> _updateProduct() async {
    // Validar datos
    if (_nameController.text.isEmpty) {
      _showErrorDialog('El nombre del producto no puede estar vacío.');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      _showErrorDialog('La descripción no puede estar vacía.');
      return;
    }
    if (double.tryParse(_priceController.text.replaceAll(',', '.')) == 0) {
      _showErrorDialog('El precio no puede ser igual a 0.');
      return;
    }
    if (int.tryParse(_stockController.text) == 0) {
      final confirm = await _showStockWarningDialog();
      if (!confirm) {
        return; // Si el usuario no confirma, no actualizamos
      }
    }

    try {
      // Actualizar el producto en Firestore
      await FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0, // Convertir de texto a double
        'stock': int.tryParse(_stockController.text) ?? 0,
        'imageUrl': _imageUrl ?? widget.product.imageUrl, // Usa la nueva URL o la anterior
        'status': _status == 'Activo' ? 'active' : 'inactive', // Guardar como 'active' o 'inactive'
        'category': _category, // Guardar la categoría
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado exitosamente')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyHomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error al actualizar el producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el producto')),
      );
    }
  }
  Future<void> _deleteProduct() async {
  // Mostrar un diálogo de confirmación antes de eliminar
  final confirm = await _showDeleteConfirmationDialog();
  if (!confirm) return; // Si el usuario cancela, no hacer nada

  try {
    // Eliminar el producto de Firestore
    await FirebaseFirestore.instance.collection('products').doc(widget.product.id).delete();
    
    // Si hay una imagen en Firebase Storage, eliminarla también
    if (_imageUrl != placeHolderImage && _imageUrl != null) {
      await FirebaseStorage.instance.refFromURL(_imageUrl!).delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado exitosamente')),
    );

    // Redirigir a la página principal o a donde sea necesario
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyHomePage()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    print('Error al eliminar el producto: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al eliminar el producto')),
    );
  }
}

Future<bool> _showDeleteConfirmationDialog() async {
  return (await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false); // No eliminar
            },
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmar eliminación
            },
          ),
        ],
      );
    },
  )) ?? false; // Retorna false si el diálogo se cierra sin seleccionar
}

  Future<void> _updateImage(String newImageUrl) async {
    // Eliminar la imagen anterior si no es un marcador de posición
    if (_imageUrl != placeHolderImage && _imageUrl != null) {
      await FirebaseStorage.instance.refFromURL(_imageUrl!).delete();
    }

    setState(() {
      _imageUrl = newImageUrl; // Actualiza la URL de la imagen
    });

    // Actualiza la imagen en Firestore
    await FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
      'imageUrl': _imageUrl,
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String folderName = 'products'; // Nombre de la carpeta
      String newImageUrl = await uploadImage(image, folderName);
      await _updateImage(newImageUrl); // Actualiza la imagen en Firestore
    }
  }

  void _showImage() {
    if (_imageUrl != null) {
      showDialog(
        context: context,
        builder: (context) => ImageViewer(imageUrl: _imageUrl!),
      );
    }
  }

  Future<void> _removeImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas quitar la imagen del producto?'),
          actions: [
            TextButton(
              onPressed: () async {
                // Eliminar la imagen de Firebase Storage
                if (_imageUrl != placeHolderImage && _imageUrl != null) {
                  await FirebaseStorage.instance.refFromURL(_imageUrl!).delete();
                }

                // Asigna el marcador de posición
                setState(() {
                  _imageUrl = placeHolderImage;
                });

                // Verifica si el documento existe antes de intentar actualizar
                DocumentSnapshot doc = await FirebaseFirestore.instance.collection('products').doc(widget.product.id).get();
                if (doc.exists) {
                  // Actualiza la imagen en Firestore
                  await FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
                    'imageUrl': _imageUrl,
                  });
                } else {
                  print('El documento no existe.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El producto no existe.')),
                  );
                }

                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showStockWarningDialog() async {
    return (await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Advertencia'),
          content: const Text('Si el stock del producto queda en 0, no lo verán los clientes. ¿Deseas continuar?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Continuar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Muestra un diálogo de confirmación
        final shouldLeave = await _showUnsavedChangesDialog();
        return shouldLeave; // Regresa true si el usuario quiere salir, false si no
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Producto'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ProductForm(
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    priceController: _priceController,
                    stockController: _stockController,
                    status: _status,
                    category: _category, // Usar la categoría
                    isEditingName: _isEditingName,
                    isEditingDescription: _isEditingDescription,
                    isEditingPrice: _isEditingPrice,
                    isEditingStock: _isEditingStock,
                    setEditingName: (value) {
                      setState(() {
                        _isEditingName = value;
                      });
                    },
                    setEditingDescription: (value) {
                      setState(() {
                        _isEditingDescription = value;
                      });
                    },
                    setEditingPrice: (value) {
                      setState(() {
                        _isEditingPrice = value;
                      });
                    },
                    setEditingStock: (value) {
                      setState(() {
                        _isEditingStock = value;
                      });
                    },
                    onStatusChanged: (newValue) {
                      setState(() {
                        _status = newValue;
                      });
                    },
                    onCategoryChanged: (newValue) { // Manejar el cambio de categoría
                      setState(() {
                        _category = newValue;
                      });
                    },
                    onPickImage: _pickImage,
                    onShowImage: _showImage,
                    onRemoveImage: _removeImage,
                    imageUrl: _imageUrl,
                    placeHolderImage: placeHolderImage,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    backgroundColor: Colors.red, // Color rojo para el botón de eliminar
                  ),
                  onPressed: _deleteProduct, // Llama a la función para eliminar el producto
                  child: const Text(
                    'Eliminar Producto',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    backgroundColor: Colors.black87,
                  ),
                  onPressed: _updateProduct,
                  child: const Text(
                    'Actualizar Producto',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return (await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Salir'),
          content: const Text('¿Estás seguro de que deseas salir?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false); // No salir
              },
            ),
            TextButton(
              child: const Text('Salir'),
              onPressed: () {
                Navigator.of(context).pop(true); // Salir
              },
            ),
          ],
        );
      },
    )) ?? false; // Retorna false si el diálogo se cierra sin seleccionar
  }
}