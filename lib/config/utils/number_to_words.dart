String numberToWords(double amount) {
  final int total = amount.floor();
  final int cents = ((amount - total) * 100).round();

  if (total == 0) return 'SON: CERO Y ${cents.toString().padLeft(2, "0")}/100 SOLES';

  final units = ['', 'UN', 'DOS', 'TRES', 'CUATRO', 'CINCO', 'SEIS', 'SIETE', 'OCHO', 'NUEVE'];
  final tens = ['', 'DIEZ', 'VEINTE', 'TREINTA', 'CUARENTA', 'CINCUENTA', 'SESENTA', 'SETENTA', 'OCHENTA', 'NOVENTA'];
  final teens = ['DIEZ', 'ONCE', 'DOCE', 'TRECE', 'CATORCE', 'QUINCE', 'DIECISEIS', 'DIECISIETE', 'DIECIOCHO', 'DIECINUEVE'];
  final hundreds = ['', 'CIENTO', 'DOSCIENTOS', 'TRESCIENTOS', 'CUATROCIENTOS', 'QUINIENTOS', 'SEISCIENTOS', 'SETECIENTOS', 'OCHOCIENTOS', 'NOVECIENTOS'];

  String convertGroup(int n) {
    String res = '';
    int u = n % 10;
    int t = (n % 100) ~/ 10;
    int c = n ~/ 100;

    if (c > 0) {
      if (c == 1 && t == 0 && u == 0) {
        res += 'CIEN ';
      } else {
        res += '${hundreds[c]} ';
      }
    }

    if (t == 1) {
      res += '${teens[u]} ';
    } else if (t > 1) {
      if (u > 0) {
        if (t == 2) {
          res += 'VEINTI${units[u]} ';
        } else {
          res += '${tens[t]} Y ${units[u]} ';
        }
      } else {
        res += '${tens[t]} ';
      }
    } else if (u > 0) {
      res += '${units[u]} ';
    }

    return res;
  }

  String words = '';
  int temp = total;

  int millions = temp ~/ 1000000;
  temp %= 1000000;
  int thousands = temp ~/ 1000;
  int unitsGroup = temp % 1000;

  if (millions > 0) {
    if (millions == 1) {
      words += 'UN MILLON ';
    } else {
      words += '${convertGroup(millions)}MILLONES ';
    }
  }

  if (thousands > 0) {
    if (thousands == 1) {
      words += 'MIL ';
    } else {
      words += '${convertGroup(thousands)}MIL ';
    }
  }

  if (unitsGroup > 0) {
    words += convertGroup(unitsGroup);
  }

  words = words.trim();
  return 'SON: $words Y ${cents.toString().padLeft(2, "0")}/100 SOLES';
}
