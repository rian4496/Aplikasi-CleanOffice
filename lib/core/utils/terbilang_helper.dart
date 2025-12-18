class TerbilangHelper {
  static final List<String> _satuan = [
    '', 'satu', 'dua', 'tiga', 'empat', 'lima', 'enam', 'tujuh', 'delapan', 'sembilan', 'sepuluh', 'sebelas'
  ];

  static String convert(double number) {
    if (number < 0) return "minus ${convert(number.abs())}";
    
    var words = _convertRecursive(number.floor());
    return "${words.toUpperCase()} RUPIAH";
  }

  static String _convertRecursive(int n) {
    if (n < 12) {
      return _satuan[n];
    } else if (n < 20) {
      return "${_convertRecursive(n - 10)} belas";
    } else if (n < 100) {
      return "${_convertRecursive(n ~/ 10)} puluh ${_convertRecursive(n % 10)}";
    } else if (n < 200) {
      return "seratus ${_convertRecursive(n - 100)}";
    } else if (n < 1000) {
      return "${_convertRecursive(n ~/ 100)} ratus ${_convertRecursive(n % 100)}";
    } else if (n < 2000) {
      return "seribu ${_convertRecursive(n - 1000)}";
    } else if (n < 1000000) {
      return "${_convertRecursive(n ~/ 1000)} ribu ${_convertRecursive(n % 1000)}";
    } else if (n < 1000000000) {
      return "${_convertRecursive(n ~/ 1000000)} juta ${_convertRecursive(n % 1000000)}";
    } else if (n < 1000000000000) {
      return "${_convertRecursive(n ~/ 1000000000)} milyar ${_convertRecursive(n % 1000000000)}";
    } else {
      return "Angka terlalu besar";
    }
  }
}
