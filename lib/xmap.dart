library xmap;

class XMap {
  Map<String, dynamic> data;

  XMap._internal() {
    this.data = Map<String, dynamic>();
  }

  factory XMap() => XMap._internal();

  factory XMap.from(Map<String, dynamic> other) {
    var x = XMap();
    if (other != null) {
      x.data = other;
    }
    return x;
  }

  bool _isPath(String value) {
    if (value != null && value.contains('.')) {
      return true;
    }
    return false;
  }

  int getInt(String keyOrPath, {int defaultValue}) {
    return _get<int>(keyOrPath, defaultValue: defaultValue);
  }

  double getDouble(String keyOrPath, {double defaultValue}) {
    return _get<double>(keyOrPath, defaultValue: defaultValue);
  }

  bool getBool(String keyOrPath, {bool defaultValue}) {
    return _get<bool>(keyOrPath, defaultValue: defaultValue);
  }

  String getString(String keyOrPath, {String defaultValue}) {
    return _get<String>(keyOrPath, defaultValue: defaultValue);
  }

  XMap getXMap(String keyOrPath) {
    return _get<XMap>(keyOrPath, defaultValue: null);
  }

  Map<String, dynamic> getMap(String keyOrPath) {
    return _get<Map<String, dynamic>>(keyOrPath, defaultValue: null);
  }

  List<T> getList<T>(String keyOrPath) {
    if (!this._isPath(keyOrPath) && !this.data.containsKey(keyOrPath)) {
      return null;
    }
    try {
      return _toList<T>(this._getValueByPath(keyOrPath));
    } catch (_) {
      return null;
    }
  }

  T _get<T>(String keyOrPath, {T defaultValue}) {
    if (!this._isPath(keyOrPath) && !this.data.containsKey(keyOrPath)) {
      return defaultValue;
    }
    try {
      dynamic value = this._getValueByPath(keyOrPath);
      switch (T.toString()) {
        case "int":
          return _toInt(value, defaultValue: defaultValue as int) as T;
        case "double":
          return _toDouble(value, defaultValue: defaultValue as double) as T;
        case "bool":
          return _toBool(value, defaultValue: defaultValue as bool) as T;
        case "String":
          return _toString(value, defaultValue: defaultValue as String) as T;
        case "XMap":
          return _toXMap(value) as T;
        case "Map<String, dynamic>":
          return _toMap(value) as T;
      }
      return defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  dynamic _getValueByPath(String path) {
    var keys = path.split('.');
    dynamic v = this.data;
    for (int i = 0; i < keys.length; i++) {
      if (v == null) {
        break;
      }
      if (v is List) {
        var index = int.tryParse(keys[i]);
        if (index == null) {
          throw XMapException("illegal index: ${keys[i]} in path: $path");
        }
        if (index < 0 || index >= v.length) {
          throw XMapException(
              "illegal index: ${keys[i]} out of bounds in path: $path");
        }
        v = v[index];
      } else if (v is Map<String, dynamic>) {
        v = v[keys[i]];
      } else if (v is XMap) {
        v = v.data[keys[i]];
      } else {
        throw XMapException(
            "value of key(${keys[i]}) is ${v.runtimeType.toString()}, expect Map<String, dynamic>, XMap or List");
      }
    }
    return v;
  }

  Map<String, dynamic> toMap() => this.data;

  String toString() => this.data.toString();

  dynamic operator [](String keyOrPath) => this._getValueByPath(keyOrPath);

  void operator []=(String key, dynamic value) {
    if (key == null) {
      throw XMapException('illegal key: key is null');
    }
    if (key.contains('.')) {
      throw XMapException('illegal key: $key, should not contain "."');
    }
    this.data[key] = value;
  }
}

int _toInt(dynamic value, {int defaultValue}) {
  if (value == null) return defaultValue;
  var t = value.runtimeType;
  switch (t.toString()) {
    case "int":
      return value as int;
    case "double":
      return (value as double).toInt();
    case "String":
      return int.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

double _toDouble(dynamic value, {double defaultValue}) {
  if (value == null) return defaultValue;
  var t = value.runtimeType;
  switch (t.toString()) {
    case "int":
      return (value as int).toDouble();
    case "double":
      return value as double;
    case "String":
      return double.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

bool _toBool(dynamic value, {bool defaultValue}) {
  if (value == null) return defaultValue;
  var t = value.runtimeType;
  switch (t.toString()) {
    case "bool":
      return value as bool;
  }
  return defaultValue;
}

String _toString(dynamic value, {String defaultValue}) {
  if (value == null) return defaultValue;
  return value.toString();
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value == null) return null;

  if (value is Map<String, dynamic>) return value;

  if (value is XMap) return value.data;
  return null;
}

XMap _toXMap(dynamic value) {
  if (value == null) return null;

  if (value is Map<String, dynamic>) return XMap.from(value);

  if (value is XMap) return value;
  return null;
}

List<T> _toList<T>(dynamic value) {
  if (value == null || !(value is List)) return null;
  List origin = value as List;
  var target = List<T>();
  for (int i = 0; i < origin.length; i++) {
    T item;
    switch (T.toString()) {
      case "int":
        var res = _toInt(origin[i]);
        item = res ?? res as T;
        break;
      case "double":
        var res = _toDouble(origin[i]);
        item = res ?? res as T;
        break;
      case "bool":
        var res = _toBool(origin[i]);
        item = res ?? res as T;
        break;
      case "XMap":
        var res = _toXMap(origin[i]);
        item = res ?? res as T;
        break;
      case 'String':
        var res = _toString(origin[i]);
        item = res ?? res as T;
        break;
    }
    target.add(item);
  }
  return target;
}

class XMapException implements Exception {
  final String msg;

  const XMapException([this.msg]);

  @override
  String toString() => msg ?? 'XMapException';
}
