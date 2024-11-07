import 'package:flutter/material.dart';
import '../../../data/payment_data.dart';
import '../../../widgets/custom_dialog.dart';
import 'payment_date.dart'; // Asegúrate de que esta ruta sea correcta

class BankSelectionScreen extends StatefulWidget {
  final String confirmedPhone;
  final double totalAmount;
  final List<Map<String, dynamic>> products;
  final String referenceNumber;
  final String? action;

  const BankSelectionScreen({
    super.key,
    required this.confirmedPhone,
    required this.totalAmount,
    required this.products,
    required this.referenceNumber,
    this.action,
  });

  @override
  _BankSelectionScreenState createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  String? selectedBank;
  List<String> filteredBanks = banks; // Lista filtrada de bancos
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el texto del campo de búsqueda
    searchController.addListener(_filterBanks);
  }

  @override
  void dispose() {
    searchController.dispose(); // Limpiar el controlador al eliminar la pantalla
    super.dispose();
  }

  void _filterBanks() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredBanks = banks
          .where((bank) => bank.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Pago'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              String title = 'No olvides registrar tu pago';
              String message;

              if (widget.products.isNotEmpty) {
                message = 'Si te retrasas en el pago de ${widget.products.length > 1 ? "los artículos" : "una orden"}, podrías perder la reserva del artículo.';
              } else {
                message = 'Si hiciste un pago, no olvides registrarlo.';
              }

              // Usa el CustomSnackbar para mostrar el Snackbar
              CustomDialog.show(context, title, message);
            }, // Muestra el Snackbar al presionar el icono
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              '¿Qué banco utilizaste?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Busca tu banco aquí',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredBanks.length,
                itemBuilder: (context, index) {
                  final bank = filteredBanks[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBank = bank;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: selectedBank == bank ? Colors.deepOrange[100] : Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: selectedBank == bank ? Colors.deepOrange : Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        bank,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selectedBank == bank ? FontWeight.bold : FontWeight.normal,
                          color: selectedBank == bank ? Colors.deepOrange : Colors.black87,
                        ),
                      ),
                  ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (selectedBank != null) // Mostrar el botón solo si hay un banco seleccionado
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.action == 'edit') {
                      setState(() {
                        selectedBank = selectedBank;
                      });
                      // Regresar a payment verification con el nuevo banco
                      return Navigator.of(context).pop(selectedBank);
                    }
                    // Navegar a la siguiente pantalla pasando los datos necesarios
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentDateScreen(
                          confirmedPhone: widget.confirmedPhone,
                          totalAmount: widget.totalAmount,
                          products: widget.products,
                          referenceNumber: widget.referenceNumber,
                          selectedBank: selectedBank!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(
                    widget.action == 'edit' ? 'Actualizar Banco' : 'Confirmar Banco',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}