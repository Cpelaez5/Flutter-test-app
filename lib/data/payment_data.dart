final List<String> phonePrefixes = [
  '0416',
  '0426',
  '0414',
  '0424',
  '0412',
];

final List<String> banks = [
  '0134 - Banesco',
  '0102 - Banco de Venezuela',
  '0108 - BBVA Provincial',
  '0172 - Bancamiga',
  '0156 - 100% Banco',
  '0114 - Bancaribe',
  '0171 - Banco Activo',
  '0166 - Banco Agricola de Venezuela',
  '0175 - Banco Bicentenario del pueblo',
  '0128 - Banco Caroní',
  '0163 - Banco del Tesoro',
  '0115 - Banco Exterior',
  '0151 - Banco Fondo Común',
  '0173 - Banco Internacional de Desarrollo',
  '0105 - Banco Mercantil',
  '0191 - Banco Nacional de Crédito',
  '0138 - Banco Plaza',
  '0137 - Banco Sofitasa',
  '0104 - Banco Venezolano de Crédito',
  '0168 - Bancrecer',
  '0177 - Banfanb',
  '0146 - Bangente',
  '0174 - Banplus',
  '0157 - Delsur',
  '0169 - Mi Banco',
  '0178 - N58 Banco Digital'
];

const Map<int, String> daysOfTheWeek = {
  0: 'Domingo',
  1: 'Lunes',
  2: 'Martes',
  3: 'Miércoles',
  4: 'Jueves',
  5: 'Viernes',
  6: 'Sábado',
};

const Map<int, String> monthsOfTheYear = {
  1: 'Enero',
  2: 'Febrero',
  3: 'Marzo',
  4: 'Abril',
  5: 'Mayo',
  6: 'Junio',
  7: 'Julio',
  8: 'Agosto',
  9: 'Septiembre',
  10: 'Octubre',
  11: 'Noviembre',
  12: 'Diciembre',
};

String formatDate(DateTime date) {
  String day = date.day.toString().padLeft(2, '0');
  String month = date.month.toString().padLeft(2, '0');
  String year = date.year.toString();
  return '$day/$month/$year';
}
