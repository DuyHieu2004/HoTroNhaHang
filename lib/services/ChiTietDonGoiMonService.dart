import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan_nhom_cuoiky/models/ChiTietGoiMon.dart';

class ChiTietDonGoiMonService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('ChiTietDonGoiMon');

  Future<List<ChiTietGoiMon>> getChiTietDonGoiMonList() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => ChiTietGoiMon.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addChiTietDonGoiMon(ChiTietGoiMon chiTiet) async {
    await _collection.doc(chiTiet.getMa).set(chiTiet.toMap());
  }

  Future<void> updateChiTietDonGoiMon(ChiTietGoiMon chiTiet) async {
    await _collection.doc(chiTiet.getMa).update(chiTiet.toMap());
  }

  Future<void> deleteChiTietDonGoiMon(String id) async {
    await _collection.doc(id).delete();
  }

  Stream<List<ChiTietGoiMon>> getChiTietGoiMonForDonGoiMon(String donGoiMonId) {
    return FirebaseFirestore.instance
        .collection('DonGoiMon')
        .doc(donGoiMonId)
        .collection('ChiTietGoiMon')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChiTietGoiMon.fromMap(doc.data()))
            .toList());
  }

  Future<List<ChiTietGoiMon>> getChiTietGoiMonForDonGoiMonOnce(String donGoiMonId) async {
    final QuerySnapshot snapshot = await _collection
        .where('maDonGoiMon.Ma', isEqualTo: donGoiMonId)
        .get();
    return snapshot.docs
        .map((doc) => ChiTietGoiMon.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

}