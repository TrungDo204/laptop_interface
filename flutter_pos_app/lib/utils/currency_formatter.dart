import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

  static String formatPrice(double price) {
    return '${_formatter.format(price)}đ';
  }

  static String formatPriceWithoutSymbol(double price) {
    return _formatter.format(price);
  }

  static String formatQuantityPrice(double price, int quantity, {String? unit}) {
    String formattedPrice = formatPriceWithoutSymbol(price);
    String quantityText = quantity.toString();

    if (unit != null && unit.isNotEmpty) {
      quantityText += ' $unit';
    }

    return '$formattedPrice x $quantityText';
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('dd/MM HH:mm').format(dateTime);
  }

  static String formatTimeRange(DateTime start, DateTime end) {
    String startTime = DateFormat('dd/MM HH:mm').format(start);
    String endTime = DateFormat('dd/MM HH:mm').format(end);
    return '$startTime → $endTime';
  }
}