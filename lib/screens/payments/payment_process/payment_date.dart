import 'package:flutter/material.dart';
import '../../../data/payment_data.dart';
import '../../../widgets/custom_dialog.dart';
import 'confirm_amount.dart'; // Asegúrate de que la ruta sea correcta

class PaymentDateScreen extends StatefulWidget {
  final String confirmedPhone;
  final double totalAmount;
  final List<Map<String, dynamic>> products;
  final String referenceNumber;
  final String selectedBank;
  final String? action;

  const PaymentDateScreen({
    super.key,
    required this.confirmedPhone,
    required this.totalAmount,
    required this.products,
    required this.referenceNumber,
    required this.selectedBank,
    this.action,
  });

  @override
  _PaymentDateScreenState createState() => _PaymentDateScreenState();
}

class _PaymentDateScreenState extends State<PaymentDateScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime? customDate;

  @override
  void initState() {
    super.initState();
    customDate = DateTime.now();
    selectedDate = DateTime.now();
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
      body: SingleChildScrollView( // Permite el desplazamiento
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Confirmar fecha de pago',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona el día que realizaste el pago.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                // Abre el selector de fecha sin restricciones
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: customDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    customDate = pickedDate; // Actualiza la fecha personalizada
                    selectedDate = pickedDate; // Actualiza la fecha seleccionada
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Buscar otra fecha anterior',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildDateBox(DateTime.now().subtract(const Duration(days: 2))), // Antier
                const SizedBox(height: 8),
                _buildDateBox(DateTime.now().subtract(const Duration(days: 1))), // Ayer
                const SizedBox(height: 8),
                _buildDateBox(DateTime.now()), // Hoy
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(onPressed: () {
                  if (widget.action == 'edit') {
                    // Regresar a la pantalla anterior con la fecha seleccionada
                    Navigator.of(context).pop(selectedDate);
                    return;
                  }
                  // Navegar a la siguiente pantalla pasando los datos necesarios
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmAmountScreen(
                        confirmedPhone: widget.confirmedPhone,
                        totalAmount: widget.totalAmount,
                        products: widget.products,
                        referenceNumber: widget.referenceNumber,
                        selectedBank: widget.selectedBank,
                        selectedDate: selectedDate,
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
                  widget.action == 'edit' ? 'Actualizar fecha' : 'Confirmar fecha',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(DateTime date) {
    final int dayOfWeek = date.weekday % 7; // Ajustar para que coincida con el índice del mapa
    final String day = date.day.toString(); // Día del mes
    final String month = monthsOfTheYear[date.month]!; // Mes en español

    // Determina si la fecha es la seleccionada
    bool isSelected = isSameDay(selectedDate, date);

    // Etiquetas para los días
    String label;
    
    if (isSameDay(date, DateTime.now())) {
      label = 'Hoy ${daysOfTheWeek[dayOfWeek]}'; // Hoy
    } else if (isSameDay(date, DateTime.now().subtract(const Duration(days: 1)))) {
      label = 'Ayer ${daysOfTheWeek[dayOfWeek]}'; // Ayer
    } else {
      label = '${daysOfTheWeek[dayOfWeek]}'; // Antier
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date; // Actualiza la fecha seleccionada
          customDate = null; // Resetea la fecha personalizada si se selecciona una de los cuadros
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange[100] : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, // Muestra "Hoy", "Ayer" o el día de la semana
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.deepOrange : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
            // Coloca el día y el mes a la derecha
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  day, // Día del mes
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.deepOrange : Colors.black87,
                  ),
                ),
                Text(
                  month, // Mes
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.deepOrange : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
}