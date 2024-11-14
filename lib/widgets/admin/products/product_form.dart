import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/widgets/admin/products/category_selection_screen.dart';
import '../../../utils/currency_input_formatter.dart';

class ProductForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final String? status;
  final String? category; // Nueva propiedad para la categoría
  final bool isEditingName;
  final bool isEditingDescription;
  final bool isEditingPrice;
  final bool isEditingStock;
  final Function(bool) setEditingName;
  final Function(bool) setEditingDescription;
  final Function(bool) setEditingPrice;
  final Function(bool) setEditingStock;
  final Function(String?) onStatusChanged;
  final Function(String?) onCategoryChanged; // Nueva función para manejar el cambio de categoría
  final Function() onPickImage;
  final Function() onShowImage;
  final Function() onRemoveImage;
  final String? imageUrl;
  final String? placeHolderImage;

  const ProductForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.stockController,
    required this.status,
    required this.category, // Agregar categoría
    required this.isEditingName,
    required this.isEditingDescription,
    required this.isEditingPrice,
    required this.isEditingStock,
    required this.setEditingName,
    required this.setEditingDescription,
    required this.setEditingPrice,
    required this.setEditingStock,
    required this.onStatusChanged,
    required this.onCategoryChanged, // Agregar función para categoría
    required this.onPickImage,
    required this.onShowImage,
    required this.onRemoveImage,
    required this.imageUrl,
    required this.placeHolderImage,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildDataRow('Nombre del producto', nameController.text, 'name', isEditingName, setEditingName, TextInputType.text),
            const SizedBox(height: 16),
            _buildDataRow('Descripción del producto', descriptionController.text, 'description', isEditingDescription, setEditingDescription, TextInputType.multiline),
            const SizedBox(height: 16),
            _buildDataRow('Precio', priceController.text, 'price', isEditingPrice, setEditingPrice, TextInputType.number, [CurrencyInputFormatter()]),
            const SizedBox(height: 16),
            _buildDataRow('Stock', stockController.text, 'stock', isEditingStock, setEditingStock, TextInputType.number, [FilteringTextInputFormatter.digitsOnly]),
            const SizedBox(height: 16),
            _buildCategoryDropdown(context), // Agregar el dropdown de categoría
            const SizedBox(height: 16),
            _buildImageRow(context),
            const SizedBox(height: 16),
            _buildStatusDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Categoría',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Color del texto del botón
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
            side: BorderSide(color: Colors.grey.shade300), // Borde gris claro
          ),
        ),
        onPressed: () async {
          // Navegar a la pantalla de selección de categorías
          final selectedCategory = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategorySelectionScreen(), // Pantalla de selección de categorías
            ),
          );
          if (selectedCategory != null) {
            onCategoryChanged(selectedCategory); // Actualizar la categoría seleccionada
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacio entre elementos
          children: [
            Expanded(
              child: Text(
                category ?? 'Seleccionar categoría', // Mostrar la categoría seleccionada o el texto por defecto
                style: TextStyle(
                  color: category != null ? Colors.black : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.edit, color: Colors.deepOrange), // Icono de lápiz
          ],
        ),
      ),
    ],
  );
}

  Widget _buildDataRow(String title, String value, String field, bool isEditing, Function(bool) setEditing, TextInputType keyboardType, [List<TextInputFormatter>? inputFormatters]) {
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
                      controller: field == 'name' ? nameController :
                                 field == 'description' ? descriptionController :
                                 field == 'price' ? priceController :
                                 stockController,
                      inputFormatters: inputFormatters,
                      keyboardType: keyboardType,
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
                      maxLines: field == 'description' ? null : 1,
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

  Widget _buildImageRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (imageUrl == placeHolderImage)
              Text(
                'Producto sin imagen',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              if (imageUrl == null)
              Text(
                'Subir imagen',
                style: const TextStyle(fontSize: 16),
              ),
            if (imageUrl == placeHolderImage || imageUrl == null) Spacer(),
            if (imageUrl == placeHolderImage || imageUrl == null)
              IconButton(
                icon: const Icon(Icons.upload_file),
                onPressed: onPickImage,
                tooltip: 'Subir imagen',
              ),
            if (imageUrl != placeHolderImage && imageUrl != null)
              Text(
                imageUrl != placeHolderImage ? 'Imagen actual' : 'Imagen seleccionada',
                style: const TextStyle(fontSize: 16),
              ),
            
            const SizedBox(width: 8),
            if (imageUrl != placeHolderImage && imageUrl != null) Spacer(),
            if (imageUrl != placeHolderImage && imageUrl != null)
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: onShowImage,
                tooltip: 'Ver imagen del producto',
              ),
            if (imageUrl != placeHolderImage && imageUrl != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onRemoveImage,
                tooltip: 'Quitar imagen del producto',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          isExpanded: true,
          value: status,
          hint: const Text('Selecciona el estado'),
          onChanged: onStatusChanged,
          items: <String>['Activo', 'Inactivo']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}