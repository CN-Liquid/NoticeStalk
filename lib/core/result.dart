class Result<T> {
  final T? _data;
  final String? _error;

  Result._init({this._data, this._error});

  factory Result.success(T data) {
    return Result<T>._init(data: data, error: null);
  }

  factory Result.failure(String error) {
    return Result<T>._init(data: null, error: error);
  }

  T? get data => _data;
  String? get error => _error;

  bool get isSuccess => error == null;
}
