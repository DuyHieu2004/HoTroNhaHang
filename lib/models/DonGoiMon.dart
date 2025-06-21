import 'package:doan_nhom_cuoiky/models/Ban.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import CloudFirestore để dùng Timestamp

class DonGoiMon {
  String? _ma;
  DateTime? _ngayLap;
  String? _trangThai;
  String? _ghiChu;
  Ban? _maBan;
  DateTime? _ngayGioDenDuKien;
  String? _maDonDatCho;

  // Constructors
  DonGoiMon({
    String? ma,
    DateTime? ngayLap,
    String? trangThai,
    String? ghiChu,
    Ban? maBan,
    DateTime? ngayGioDenDuKien,
    String? maDonDatCho,
  }) {
    _ma = ma ?? '';
    _ngayLap = ngayLap ?? DateTime.now();
    _trangThai = trangThai ?? "Đang phục vụ";
    _ghiChu = ghiChu ?? "";
    _maBan = maBan ?? Ban();
    _ngayGioDenDuKien = ngayGioDenDuKien ?? DateTime.now();
    _maDonDatCho = maDonDatCho;
  }

  DonGoiMon.fromMap(Map<String, dynamic> map) {
    _ma = map['Ma']?.toString();
    _ngayLap = (map['NgayLap'] as Timestamp?)?.toDate();
    _trangThai = map['TrangThai']?.toString();
    _ghiChu = map['GhiChu']?.toString();
    _maBan =
        map['MaBan'] != null
            ? Ban.fromMap(map['MaBan'] as Map<String, dynamic>)
            : null;
    _ngayGioDenDuKien = (map['NgayGioDenDuKien'] as Timestamp?)?.toDate();
    _maDonDatCho = map['MaDonDatCho']?.toString();
  }


  Map<String, dynamic> toMap() {
    return {
      'Ma': _ma,
      'NgayLap': _ngayLap != null ? Timestamp.fromDate(_ngayLap!) : null,
      'TrangThai': _trangThai,
      'GhiChu': _ghiChu,
      'MaBan': _maBan?.toMap(),
      'NgayGioDenDuKien':
          _ngayGioDenDuKien != null
              ? Timestamp.fromDate(_ngayGioDenDuKien!)
              : null,
      'MaDonDatCho': _maDonDatCho,
    };
  }

  // Getters
  String? get ma => _ma;
  DateTime? get ngayLap => _ngayLap;
  String? get trangThai => _trangThai;
  String? get ghiChu => _ghiChu;
  Ban? get maBan => _maBan;
  DateTime? get ngayGioDenDuKien => _ngayGioDenDuKien;
  String? get maDonDatCho => _maDonDatCho;

  // Setters (giữ nguyên, chúng hoạt động với các trường _ma, v.v.)
  set ma(String? ma) {
    if (ma != null && ma.isNotEmpty) {
      _ma = ma;
    }
  }

  set ngayLap(DateTime? ngayLap) {
    if (ngayLap != null) {
      _ngayLap = ngayLap;
    }
  }

  set trangThai(String? trangThai) {
    if (trangThai != null && trangThai.isNotEmpty) {
      _trangThai = trangThai;
    }
  }

  set ghiChu(String? ghiChu) {
    if (ghiChu != null) {
      _ghiChu = ghiChu;
    }
  }

  set maBan(Ban? maBan) {
    if (maBan != null) {
      _maBan = maBan;
    }
  }

  set ngayGioDenDuKien(DateTime? ngayGioDenDuKien) {
    _ngayGioDenDuKien = ngayGioDenDuKien;
  }

  set maDonDatCho(String? maDonDatCho) {
    _maDonDatCho = maDonDatCho;
  }
}
