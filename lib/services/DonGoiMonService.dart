import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan_nhom_cuoiky/models/ChiTietGoiMon.dart';
import 'package:doan_nhom_cuoiky/models/DonDatCho.dart';
import 'package:doan_nhom_cuoiky/models/DonGoiMon.dart';
import 'package:doan_nhom_cuoiky/models/PhieuTamUng.dart';

class DonGoiMonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _donGoiMonCollection = FirebaseFirestore.instance
      .collection('DonGoiMon');

  Future<List<DonGoiMon>> getAllDonGoiMon() async {
    try {
      QuerySnapshot snapshot = await _donGoiMonCollection.get();
      return snapshot.docs
          .map((doc) => DonGoiMon.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateDonGoiMonStatus(String donGoiMonId, String newStatus) async {
    try {
      await _donGoiMonCollection.doc(donGoiMonId).update({
        'trangThai': newStatus,
      });
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái đơn gọi món: $e');
      rethrow;
    }
  }

  Future<void> addDonGoiMon(DonGoiMon donGoiMon) async {
    try {
      await _donGoiMonCollection.doc(donGoiMon.ma).set(donGoiMon.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDonGoiMon(DonGoiMon donGoiMon) async {
    try {
      await _donGoiMonCollection.doc(donGoiMon.ma).update(donGoiMon.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDonGoiMon(String id) async {
    try {
      await _donGoiMonCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<DonGoiMon>> getReservationsForDate(DateTime date) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
      999,
    );

    return _firestore
        .collection('DonGoiMon')
        .where(
          'NgayGioDenDuKien',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'NgayGioDenDuKien',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            try {
              return DonGoiMon.fromMap(data);
            } catch (e) {
              return DonGoiMon(ma: doc.id);
            }
          }).toList();
        });
  }

  Future<void> addReservation(
    DonGoiMon donGoiMon,
    List<ChiTietGoiMon> chiTietGoiMonList,
    DonDatCho donDatCho,
    PhieuTamUng? phieuTamUng,
    bool shouldUpdateTableStatusImmediately,
  ) async {
    DocumentReference donDatChoDocRef =
        _firestore.collection('DonDatCho').doc();
    donDatCho.ma = donDatChoDocRef.id;

    if (phieuTamUng != null) {
      DocumentReference phieuTamUngDocRef =
          _firestore.collection('PhieuTamUng').doc();
      phieuTamUng.ma = phieuTamUngDocRef.id;
      phieuTamUng.maDonDatCho = donDatCho.ma;
      await phieuTamUngDocRef.set(phieuTamUng.toMap());
      donDatCho.maPhieuTamUng = phieuTamUng.ma;
    }

    DocumentReference donGoiMonDocRef =
        _firestore.collection('DonGoiMon').doc();
    donGoiMon.ma = donGoiMonDocRef.id;
    donGoiMon.maDonDatCho = donDatCho.ma;

    if (shouldUpdateTableStatusImmediately) {
      donGoiMon.trangThai = "Đã đặt";
    } else {
      donGoiMon.trangThai = "Chờ đến";
    }

    await donGoiMonDocRef.set(donGoiMon.toMap());

    donDatCho.maDonGoiMon = donGoiMon.ma;
    await donDatChoDocRef.set(donDatCho.toMap());

    for (var chiTiet in chiTietGoiMonList) {
      await donGoiMonDocRef.collection('ChiTietGoiMon').add(chiTiet.toMap());
    }

    if (shouldUpdateTableStatusImmediately &&
        donGoiMon.maBan != null &&
        donGoiMon.maBan!.ma != null) {
      await _firestore.collection('Ban').doc(donGoiMon.maBan!.ma).update({
        'trangThai': 'Đã đặt',
      });
    }
  }

  Future<String> cancelReservation(String donGoiMonMa, String? banMa) async {
    String message = "Đơn đặt chỗ đã được hủy.";
    DocumentSnapshot donGoiMonDoc =
        await _firestore.collection('DonGoiMon').doc(donGoiMonMa).get();
    Map<String, dynamic>? donGoiMonData =
        donGoiMonDoc.data() as Map<String, dynamic>?;

    if (donGoiMonData == null) {
      throw Exception("Không tìm thấy đơn gọi món để hủy.");
    }

    DateTime? ngayGioDenDuKien =
        (donGoiMonData['NgayGioDenDuKien'] as Timestamp?)?.toDate();
    String? currentTableStatus = donGoiMonData['TrangThai']?.toString();

    if (ngayGioDenDuKien != null) {
      final DateTime now = DateTime.now();
      final Duration timeLeft = ngayGioDenDuKien.difference(now);
      final int cancellationGracePeriodMinutes = 30;

      if (timeLeft.isNegative ||
          timeLeft.inMinutes < cancellationGracePeriodMinutes) {
        message =
            "Đã hủy đơn. Hủy trước giờ đến ${cancellationGracePeriodMinutes} phút hoặc quá hạn, không hoàn tiền.";
      } else {
        message =
            "Đã hủy đơn. Hủy trước giờ đến đủ thời gian quy định, có thể hoàn tiền.";
      }
    } else {
      message = "Đã hủy đơn. Không xác định được thời gian đến dự kiến.";
    }

    await _firestore.collection('DonGoiMon').doc(donGoiMonMa).update({
      'TrangThai': 'Hủy',
    });
    if (banMa != null && currentTableStatus == 'Đã đặt') {
      await _firestore.collection('Ban').doc(banMa).update({
        'trangThai': 'Trống',
      });
    }
    return message;
  }

  Future<void> deleteReservation(String donGoiMonId) async {
    DocumentReference donGoiMonDocRef = _firestore
        .collection('DonGoiMon')
        .doc(donGoiMonId);

    DocumentSnapshot donGoiMonDoc = await donGoiMonDocRef.get();
    if (!donGoiMonDoc.exists) {
      throw Exception("DonGoiMon not found for deletion: $donGoiMonId");
    }
    Map<String, dynamic> donGoiMonData =
        donGoiMonDoc.data() as Map<String, dynamic>;
    String? maDonDatCho = donGoiMonData['MaDonDatCho']?.toString();
    String? maBan = donGoiMonData['MaBan']?['ma']?.toString();
    String? donGoiMonTrangThai = donGoiMonData['TrangThai']?.toString();

    QuerySnapshot chiTietSnapshot =
        await donGoiMonDocRef.collection('ChiTietGoiMon').get();
    for (QueryDocumentSnapshot doc in chiTietSnapshot.docs) {
      await doc.reference.delete();
    }

    await donGoiMonDocRef.delete();

    if (maDonDatCho != null && maDonDatCho.isNotEmpty) {
      DocumentReference donDatChoDocRef = _firestore
          .collection('DonDatCho')
          .doc(maDonDatCho);
      DocumentSnapshot donDatChoDoc = await donDatChoDocRef.get();
      if (donDatChoDoc.exists) {
        String? maPhieuTamUng =
            (donDatChoDoc.data() as Map<String, dynamic>?)?['maPhieuTamUng']
                ?.toString();

        if (maPhieuTamUng != null && maPhieuTamUng.isNotEmpty) {
          await _firestore
              .collection('PhieuTamUng')
              .doc(maPhieuTamUng)
              .delete();
        }

        await donDatChoDocRef.delete();
      }
    }

    if (maBan != null && donGoiMonTrangThai == 'Đã đặt') {
      DocumentSnapshot banDoc =
          await _firestore.collection('Ban').doc(maBan).get();
      if (banDoc.exists) {
        String? currentBanStatus =
            (banDoc.data() as Map<String, dynamic>?)?['trangThai']?.toString();
        if (currentBanStatus == 'Đã đặt') {
          await _firestore.collection('Ban').doc(maBan).update({
            'trangThai': 'Trống',
          });
        }
      }
    }
  }

  Future<List<DonGoiMon>> getDonGoiMonChoDen() async{
    List<DonGoiMon> dsDonGoiMonChoDen = [];
    final QuerySnapshot donGoiMonChoDenSnapshot = await _donGoiMonCollection
        .where('TrangThai', isEqualTo: 'Chờ đến')
        .get();

    dsDonGoiMonChoDen = donGoiMonChoDenSnapshot.docs.map(
        (doc) => DonGoiMon.fromMap(doc.data() as Map<String, dynamic>)
    ).toList();

    return dsDonGoiMonChoDen;

  }
}
