class NumberToWords {
  static final List<String> _ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen'
  ];

  static final List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety'
  ];

  static String convertToWords(int number) {
    if (number == 0) return 'Zero';

    if (number < 0) {
      return 'Minus ${convertToWords(number.abs())}';
    }

    String words = '';

    if ((number ~/ 10000000) > 0) {
      words += '${convertToWords(number ~/ 10000000)} Crore ';
      number %= 10000000;
    }

    if ((number ~/ 100000) > 0) {
      words += '${convertToWords(number ~/ 100000)} Lakh ';
      number %= 100000;
    }

    if ((number ~/ 1000) > 0) {
      words += '${convertToWords(number ~/ 1000)} Thousand ';
      number %= 1000;
    }

    if ((number ~/ 100) > 0) {
      words += '${convertToWords(number ~/ 100)} Hundred ';
      number %= 100;
    }

    if (number > 0) {
      if (number < 20) {
        words += _ones[number];
      } else {
        words += _tens[number ~/ 10];
        if ((number % 10) > 0) {
          words += ' ${_ones[number % 10]}';
        }
      }
    }

    return words.trim();
  }
}
