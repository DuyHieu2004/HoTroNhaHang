import 'package:doan_nhom_cuoiky/models/PhieuTamUng.dart';
import 'package:doan_nhom_cuoiky/services/PhieuTamUngService.dart';
import 'package:flutter/foundation.dart';

class PhieuTamUngProvider extends ChangeNotifier {
  List<PhieuTamUng> _phieuTamUngList = [];
  final PhieuTamUngService _phieuTamUngService = PhieuTamUngService();

  List<PhieuTamUng> get phieuTamUngList => _phieuTamUngList;

  PhieuTamUngProvider() {
    _loadPhieuTamUng();
  }

  Future<void> _loadPhieuTamUng() async {
    _phieuTamUngList = await _phieuTamUngService.getPhieuTamUng();
    notifyListeners();
  }

  Future<void> addPhieuTamUng(PhieuTamUng phieuTamUng) async {
    await _phieuTamUngService.addPhieuTamUng(phieuTamUng);
    await _loadPhieuTamUng();
  }

  Future<void> updatePhieuTamUng(PhieuTamUng phieuTamUng) async {
    await _phieuTamUngService.updatePhieuTamUng(phieuTamUng);
    await _loadPhieuTamUng();
  }

  Future<void> deletePhieuTamUng(PhieuTamUng phieuTamUng) async{
    await _phieuTamUngService.deletePhieuTamUng(phieuTamUng.ma!);
    await _loadPhieuTamUng();
  }

  Future<void> clear() async{
    _phieuTamUngList.clear();
    await _loadPhieuTamUng();
  }
}