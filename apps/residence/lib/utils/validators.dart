/// Form validation utilities
class Validators {
  /// Email validator
  static String? Function(String?) email() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }

      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email';
      }

      return null;
    };
  }

  /// Phone number validator (Philippine format)
  static String? Function(String?) phone() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Phone number is required';
      }

      // Remove spaces, dashes, and parentheses
      final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

      // Check if it's a valid Philippine mobile number
      // Formats: 09XXXXXXXXX, +639XXXXXXXXX, 639XXXXXXXXX
      final phoneRegex = RegExp(
        r'^(\+?63|0)?9\d{9}$',
      );

      if (!phoneRegex.hasMatch(cleaned)) {
        return 'Please enter a valid Philippine mobile number';
      }

      return null;
    };
  }

  /// Required field validator
  static String? Function(String?) required(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  /// Min length validator
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }

    return null;
  }

  /// Max length validator
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for optional fields
    }

    if (value.length > max) {
      return '${fieldName ?? 'This field'} must be at most $max characters';
    }

    return null;
  }

  /// Number validator
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    return null;
  }

  /// Positive number validator
  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final num = int.tryParse(value);
    if (num == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    if (num <= 0) {
      return '${fieldName ?? 'This field'} must be greater than 0';
    }

    return null;
  }

  /// Date validator (not in past)
  static String? futureDate(DateTime? value, {String? fieldName}) {
    if (value == null) {
      return '${fieldName ?? 'Date'} is required';
    }

    if (value.isBefore(DateTime.now())) {
      return '${fieldName ?? 'Date'} cannot be in the past';
    }

    return null;
  }

  /// Date range validator (start < end)
  static String? dateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Both dates are required';
    }

    if (start.isAfter(end)) {
      return 'Start date must be before end date';
    }

    return null;
  }

  /// Max days duration validator
  static String? maxDuration(DateTime? start, DateTime? end, int maxDays) {
    if (start == null || end == null) {
      return 'Both dates are required';
    }

    final duration = end.difference(start).inDays;
    if (duration > maxDays) {
      return 'Duration cannot exceed $maxDays days';
    }

    return null;
  }

  /// Vehicle plate validator
  static String? vehiclePlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vehicle plate is required';
    }

    // Basic validation: 2-10 alphanumeric characters
    final plateRegex = RegExp(r'^[A-Z0-9]{2,10}$');
    final cleaned = value.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');

    if (!plateRegex.hasMatch(cleaned)) {
      return 'Please enter a valid vehicle plate';
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
