class ThucDon {
  String? _ma;
  String? _ten;

  ThucDon(this._ma, this._ten);

  Map<String, dynamic> toMap() {
    return {
      'ma': _ma,
      'ten': _ten,
    };
  }

  ThucDon.fromMap(Map<String, dynamic> map) {
    _ma = map['ma']?.toString();
    _ten = map['ten']?.toString();
  }

  get getMa => _ma;
  get getTen => _ten;

  set ma(String ma) {
    if (ma.isNotEmpty) {
      _ma = ma;
    }
  }

  set ten(String ten) {
    if (ten.isNotEmpty) {
      _ten = ten;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThucDon && other._ma == _ma;
  }

  @override
  int get hashCode => _ma.hashCode;
}