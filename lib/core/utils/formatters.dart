import 'package:intl/intl.dart';

class Formatters {
  static String _symbolFor(String curr) {
    switch (curr.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      default:
        return '\$';
    }
  }

  static String currency(double amount, {String currency = 'USD'}) {
    final fmt = NumberFormat.currency(
      locale: 'en_US',
      symbol: _symbolFor(currency),
      decimalDigits: 2,
    );
    return fmt.format(amount);
  }

  static String formatCurrency(double amount, {String currencyCode = 'USD'}) {
    return Formatters.currency(amount, currency: currencyCode);
  }

  static final _dateFormat = DateFormat('EEEE, MMM d');
  static final _shortDateFormat = DateFormat('MMM d, yyyy');
  static final _timeFormat = DateFormat('h:mm a');

  static String formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return _dateFormat.format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  static String dateShort(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return _shortDateFormat.format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatTime(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return _timeFormat.format(dateTime);
    } catch (_) {
      return '';
    }
  }

  static String timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (_) {
      return '';
    }
  }
}
