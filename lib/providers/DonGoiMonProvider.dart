import 'package:doan_nhom_cuoiky/models/ChiTietGoiMon.dart';
import 'package:doan_nhom_cuoiky/models/DonGoiMon.dart';
import 'package:doan_nhom_cuoiky/services/DonGoiMonService.dart';
import 'package:flutter/foundation.dart';

class DonGoiMonProvider extends ChangeNotifier{
  List<DonGoiMon> _donGoiMonList = [];
  final DonGoiMonService _donGoiMonService = DonGoiMonService();

  List<DonGoiMon> get donGoiMonList => _donGoiMonList;

  DonGoiMonProvider() {
    _loadDonGoiMon();
  }




  Future<void> _loadDonGoiMon() async {
    _donGoiMonList = await _donGoiMonService.getAllDonGoiMon();
    notifyListeners();
  }

  Future<void> addDonGoiMon(DonGoiMon donGoiMon) async {
    await _donGoiMonService.addDonGoiMon(donGoiMon);
    await _loadDonGoiMon();
  }

  Future<void> updateDonGoiMon(DonGoiMon donGoiMon) async {
    await _donGoiMonService.updateDonGoiMon(donGoiMon);
    await _loadDonGoiMon();
  }

  Future<void> deleteDonGoiMon(String id) async {
    await _donGoiMonService.deleteDonGoiMon(id);
    await _loadDonGoiMon();
  }

  Future<List<DonGoiMon>> layDonDangPhucVu() async{
    await _loadDonGoiMon();
    return _donGoiMonList.where((donGoiMon) => donGoiMon.trangThai == 'Đang phục vụ').toList();
  }

  Future<DonGoiMon?> getDonGoiMonByBan(String maBan) async{
    await _loadDonGoiMon();
    final donGoiMon = _donGoiMonList.firstWhere(
            (donGoiMon) => donGoiMon.maBan?.ma == maBan && donGoiMon.trangThai == 'Đang phục vụ');

    return donGoiMon.ma != null ? donGoiMon : null;
  }

  Future<DonGoiMon?> getNewDocumentId(String maBan) async {
    await _loadDonGoiMon();
    for (DonGoiMon ct in _donGoiMonList){
      if(ct.maBan!.ma! == maBan && ct.trangThai == 'Đang phục vụ'){
        return ct;
      }
    }
    return null;
  }
}