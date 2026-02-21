/// A validation function. Returns `null` if valid, or an error message string.
typedef Validator<T> = String? Function(T value);
