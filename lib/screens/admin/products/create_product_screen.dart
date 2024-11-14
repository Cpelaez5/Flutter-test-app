import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/product.dart';
import '../../../services/payments/upload_image.dart';
import '../../../widgets/admin/products/product_form.dart';
import '../../../widgets/payments/image_viewer.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({Key? key}) : super(key: key);

  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String? _status = 'Activo'; // Estado predeterminado
  String? _category; // Agregar categoría
  String? _imageUrl; // Para manejar la URL de la imagen
  String? placeHolderImage = dotenv.env['PLACE_HOLDER_URL'];
  bool _isEditingName = false;
  bool _isEditingDescription = false;
  bool _isEditingPrice = false;
  bool _isEditingStock = false;

  Future<int> _getNextProductId() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('products')
        .orderBy('createdAt', descending: true) // Ordenar por createdAt
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      // Obtener el ID del último producto creado
      String lastDocumentId = result.docs.first.id;

      // Convertir el ID a un entero
      int lastProductId = int.tryParse(lastDocumentId) ?? 0; // Si no se puede convertir, usar 0

      return lastProductId + 1; // Aumentar el ID en 1
    }

    return 1; // Si no hay productos, empezar desde 1
  }

  Future<void> _createProduct() async {
  // Validar datos
  if (_nameController.text.isEmpty) {
    _showErrorDialog('El nombre del producto no puede estar vacío.');
    return;
  }
  if (_descriptionController.text.isEmpty) {
    _showErrorDialog('La descripción no puede estar vacía.');
    return;
  }
  if (double.tryParse(_priceController.text.replaceAll(',', '.')) == null || 
      double.tryParse(_priceController.text.replaceAll(',', '.')) == 0) {
    _showErrorDialog('El precio no puede ser igual a 0.');
    return;
  }
  if (int.tryParse(_stockController.text) == 0) {
    final confirm = await _showStockWarningDialog();
    if (!confirm) {
      return; // Si el usuario no confirma, no actualizamos
    }
  }
  if (_category == null || _category!.isEmpty) {
    _showErrorDialog('La categoría no puede estar vacía.');
    return;
  }

  try {
    int newProductId = await _getNextProductId();

    Product newProduct = Product(
      id: newProductId.toString(),
      category: _category!,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      stock: int.tryParse(_stockController.text) ?? 0,
      imageUrl: _imageUrl ?? placeHolderImage!,
      status: _status == 'Activo' ? 'active' : 'inactive',
      createdAt: Timestamp.fromDate(DateTime.now()),
    );

    // Guardar el producto en Firestore
    await FirebaseFirestore.instance.collection('products').doc(newProductId.toString()).set({
      'name': newProduct.name,
      'description': newProduct.description,
      'price': newProduct.price,
      'stock': newProduct.stock,
      'imageUrl': newProduct.imageUrl,
      'status': newProduct.status,
      'category': newProduct.category,
      'createdAt': newProduct.createdAt,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto creado exitosamente')),
    );
    Navigator.of(context).pop();
    // Limpiar los controladores
    // _nameController.clear();
    // _descriptionController.clear();
    // _priceController.clear();
    // _stockController.clear();
    // setState(() {
    //   _status = 'Activo';
    //   _category = null;
    //   _imageUrl = null;
    // });
  } catch (e) {
    print('Error al crear el producto: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al crear el producto')),
    );
  }
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Aquí puedes subir la imagen a Firebase Storage y obtener la URL
      String folderName = 'products'; // Nombre de la carpeta
      String newImageUrl = await uploadImage(image, folderName); // Asegúrate de implementar esta función
      setState(() {
        _imageUrl = newImageUrl; // Actualiza la URL de la imagen
      });
    }
  }

  void _showImage() {
    if (_imageUrl != null) {
      showDialog(
        context: context,
        builder: (context) => ImageViewer(imageUrl: _imageUrl!), // Asegúrate de que ImageViewer esté implementado
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
              onPressed: () {
                setState(() {
                  _imageUrl = null; // Reiniciar la URL de la imagen
                });
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await _showUnsavedChangesDialog();
        return shouldLeave; // Regresa true si el usuario quiere salir, false si no
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Producto'),
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
                    onCategoryChanged: (newValue) {
                      setState(() {
                        _category = newValue;
                      });
                    },
                    onPickImage: _pickImage, // Función para seleccionar una imagen
                    onShowImage: _showImage, // Función para mostrar la imagen seleccionada
                    onRemoveImage: _removeImage, // Función para eliminar la imagen
                    imageUrl: _imageUrl,
                    placeHolderImage: placeHolderImage, // Puedes definir un marcador de posición si es necesario
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    backgroundColor: Colors.black87,
                  ),
                  onPressed: _createProduct, // Crear el producto
                  child: const Text(
                    'Crear Producto',
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
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    // Aquí puedes implementar la función para importar productos
                  },
                  child: const Text(
                    'Importar',
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
} 