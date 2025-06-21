import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan_nhom_cuoiky/models/HoaDon.dart';

class HoaDonService{
  final CollectionReference _hoadon = FirebaseFirestore.instance.collection('HoaDon');

  Future<List<HoaDon>> getHoaDon() async {
    QuerySnapshot snapshot = await _hoadon.get();
    return snapshot.docs.map((doc) => HoaDon.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Stream<List<HoaDon>> getDSHoaDon(){
    return _hoadon.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => HoaDon.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addHoaDon(HoaDon hoaDon) async {

    await _hoadon.doc(hoaDon.ma).set(hoaDon.toMap());
  }

  Future<void> updateHoaDon(HoaDon hoaDon) async {
    await _hoadon.doc(hoaDon.ma).update(hoaDon.toMap());
  }

  Future<void> deleteHoaDon(String id) async {
    await _hoadon.doc(id).delete();
  }

  Stream<int> getTodayHoaDonCount() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _hoadon
        .where('ngayThanhToan', isGreaterThanOrEqualTo: startOfDay)
        .where('ngayThanhToan', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<double> getTodayRevenue() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _hoadon
        .where('ngayThanhToan', isGreaterThanOrEqualTo: startOfDay)
        .where('ngayThanhToan', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) {
      double totalRevenue = 0.0;
      for (var doc in snapshot.docs) {
        HoaDon hoaDon = HoaDon.fromMap(doc.data() as Map<String, dynamic>);
        totalRevenue += hoaDon.tongTien ?? 0.0;
      }
      return totalRevenue;
    });
  }

}