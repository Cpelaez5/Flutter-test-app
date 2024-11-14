import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/product.dart';
import '../../../services/payments/upload_image.dart';
import '../../../widgets/payments/image_viewer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../utils/currency_input_formatter.dart';
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
  return Scaffold(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDataCard(),
                  const SizedBox(height: 16),
                  // Aquí puedes agregar otros widgets si es necesario
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Ajusta el padding horizontal
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48), // Establecer un ancho mínimo
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
  );
}

  Widget _buildDataRow(String title, String value, String field, bool isEditing, Function(bool) setEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              isEditing
                  ? TextField(
                      controller: field == 'name' ? _nameController :
                                 field == 'description' ? _descriptionController :
                                 field == 'price' ? _priceController :
                                 _stockController,
                      inputFormatters: field == 'price' ? [CurrencyInputFormatter()] : [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number, // Asegúrate de que sea solo numérico
                      onSubmitted: (value) {
                        setEditing(false);
                      },
                      onTapOutside: (_) {
                        setEditing(false);
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () {
                            setEditing(false);
                          },
                        ),
                      ),
                      maxLines: field == 'description' ? null : 1, // Permitir múltiples líneas para la descripción
                    )
                  : Text(
                      value,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
            ],
          ),
        ),
        if (!isEditing)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setEditing(true);
            },
          ),
      ],
    );
  }

  Widget _buildDataCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataRow('Nombre del producto', _nameController.text, 'name', _isEditingName, (value) {
              setState(() {
                _isEditingName = value;
              });
            }),
            const SizedBox(height: 16),
            _buildDataRow('Descripción del producto', _descriptionController.text, 'description', _isEditingDescription, (value) {
              setState(() {
                _isEditingDescription = value;
              });
            }),
            const SizedBox(height: 16),
            _buildDataRow('Precio', _priceController.text, 'price', _isEditingPrice, (value) {
              setState(() {
                _isEditingPrice = value;
              });
            }),
            const SizedBox(height: 16),
            _buildDataRow('Stock', _stockController.text, 'stock', _isEditingStock, (value) {
              setState(() {
                _isEditingStock = value;
              });
            }),
            const SizedBox(height: 16),
            if (_imageUrl != null) 
              Row(
                children: [
                  if (_imageUrl == placeHolderImage)
                    Text(
                      'Producto sin imagen',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    if (_imageUrl == placeHolderImage)
                    Spacer(),
                    if (_imageUrl == placeHolderImage)
                    IconButton(
                      icon: const Icon(Icons.upload_file),
                      onPressed: _pickImage,
                      tooltip: 'Subir imagen',
                    ),
                  if (_imageUrl != placeHolderImage)
                    Text(
                      _imageUrl != widget.product.imageUrl ? 'Imagen seleccionada' : 'Imagen actual',
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(width: 8),
                  if (_imageUrl != placeHolderImage)
                  Spacer(),
                  if (_imageUrl != placeHolderImage)
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _showImage,
                      tooltip: 'Ver imagen del producto',
                    ),
                  if (_imageUrl != placeHolderImage)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _removeImage,
                      tooltip: 'Quitar imagen del producto',
                    ),
                ],
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, // Hacer que el contenedor ocupe todo el ancho disponible
              child: DropdownButton<String>(
                isExpanded: true, // Esto asegura que el DropdownButton ocupe todo el ancho del contenedor
                value: _status,
                hint: const Text('Selecciona el estado'),
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue;
                  });
                },
                items: <String>['Activo', 'Inactivo']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}