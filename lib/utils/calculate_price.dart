double calculatePriceWithDolar(double productPrice, double? dolarPrice) {
  // Calcular el precio en base al dólar, asegurando que no se divida por cero
  double precioCalculado = productPrice / (dolarPrice ?? 1);
  
  // Redondear a dos decimales y mantenerlo como un número
  double precioFinal = double.parse(precioCalculado.toStringAsFixed(2));
  
  return precioFinal;
}

double fixPrice(double productPrice) {
  // Calcular el precio en base al dólar, asegurando que no se divida por cero
  double price = productPrice;
  
  // Redondear a dos decimales y mantenerlo como un número
  double fixedPrice = double.parse(price.toStringAsFixed(2));
  
  return fixedPrice;
}
