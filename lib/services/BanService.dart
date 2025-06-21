import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/Ban.dart'; // Đảm bảo đường dẫn này đúng với vị trí của file Ban.dart

class BanService {
  final CollectionReference _banCollection = FirebaseFirestore.instance.collection('Ban');
  final CollectionReference _donGoiMonCollection  = FirebaseFirestore.instance.collection("DonGoiMon");
  
  Stream<List<Ban>> getBansStream() {
    return _banCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Ban.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<Ban>> getAvailableTables() {
    return _banCollection
        .where('trangThai', isEqualTo: 'Trống')
        .snapshots()
        .map(
            (snapshot) => snapshot.docs.map((doc) => Ban.fromMap(doc.data() as Map<String, dynamic>)).toList()
    );

  }

  Future<List<Ban>> getBanList() async {
    try {
      QuerySnapshot snapshot = await _banCollection.get();
      return snapshot.docs.map((doc) {
        return Ban.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Ban>> getDSBan(){
    return _banCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Ban.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addBan(Ban ban) async {
    try {
      await _banCollection.doc(ban.ma).set(ban.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBan(Ban ban) async {
    try {
      await _banCollection.doc(ban.ma).update(ban.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBan(String banId) async {
    try {
      await _banCollection.doc(banId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<Ban?> getBanById(String banId) async {
    try {
      DocumentSnapshot doc = await _banCollection.doc(banId).get();
      if (doc.exists) {
        return Ban.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateBanStatus(String banMa, String newStatus) async {
    try {
      await _banCollection.doc(banMa).update({'trangThai': newStatus});
      print('Cập nhật trạng thái bàn $banMa thành $newStatus thành công');
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái bàn $banMa: $e');
      rethrow;
    }
  }

  Future<List<Ban>> getBanByTrangThai(String trangThai) async {
    try {
      QuerySnapshot snapshot = await _banCollection
          .where('trangThai', isEqualTo: trangThai)
          .get();
      return snapshot.docs.map((doc) => Ban.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Ban>> getBanByTrangThaiStream(String trangThai){
    return _banCollection.where('trangThai', isEqualTo: trangThai).snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => Ban.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<List<Ban>> getBanBySucChuaMin(int sucChuaMin) async {
    try {
      QuerySnapshot snapshot = await _banCollection
          .where('sucChua', isGreaterThanOrEqualTo: sucChuaMin)
          .get();
      return snapshot.docs.map((doc) => Ban.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Ban>> getBanBySucChuaMinStream(int sucChuaMin){
    return _banCollection
        .where('sucChua', isGreaterThanOrEqualTo: sucChuaMin)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => Ban.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<bool> checkTableAvailability(String? banMa, DateTime reservationDateTime) async {
    if (banMa == null || banMa.isEmpty) {
      print("Lỗi: Mã bàn không được để trống.");
      return false;
    }

    final Duration reservationBuffer = Duration(hours: 2);
    try {

      QuerySnapshot conflictDonGoiMonSnapshot = await _donGoiMonCollection
          .where("MaBan.ma", isEqualTo: banMa)
          .where("TrangThai", isNotEqualTo: "Hủy")
          .get();

      print("Số đơn gọi món tiềm năng tìm thấy cho bàn $banMa: ${conflictDonGoiMonSnapshot.docs.length}");

      for (var doc in conflictDonGoiMonSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          print("Cảnh báo: Dữ liệu tài liệu ${doc.id} là null. Bỏ qua.");
          continue;
        }
        Timestamp? existingReservationTimestamp = data["NgayGioDenDuKien"] as Timestamp?;

        if (existingReservationTimestamp != null) {
          DateTime existReservationDateTime = existingReservationTimestamp.toDate();
          DateTime occupiedStart = existReservationDateTime.subtract(reservationBuffer);
          DateTime occupiedEnd = existReservationDateTime.add(reservationBuffer);

          print("Kiểm tra DonGoiMon (có đặt chỗ): $reservationDateTime vs Khoảng bận $occupiedStart - $occupiedEnd (từ NgayGioDenDuKien: $existReservationDateTime)");

          if (reservationDateTime.isBefore(occupiedEnd) && reservationDateTime.add(reservationBuffer).isAfter(occupiedStart)) {
            print("XUNG ĐỘT! Bàn $banMa bận do đặt chỗ.");
            return false;
          }
        } else {
          String? trangThai = data["TrangThai"] as String?;
          Timestamp? ngayLapTimestamp = data["NgayLap"] as Timestamp?;

          if (trangThai != null && ngayLapTimestamp != null) {
            DateTime ngayLap = ngayLapTimestamp.toDate();

            if (trangThai == "Đang phục vụ" || trangThai == "Chờ thanh toán") {
              final Duration maxOccupancyDuration = Duration(hours: 3); // Thời gian tối đa 1 đơn gọi món chiếm dụng bàn

              DateTime potentialBusyEndTime = ngayLap.add(maxOccupancyDuration);

              print("Kiểm tra DonGoiMon (không đặt chỗ): $reservationDateTime vs Khoảng bận (từ NgayLap) $ngayLap - $potentialBusyEndTime (Trạng thái: $trangThai)");

              if (reservationDateTime.isAfter(ngayLap.subtract(reservationBuffer)) &&
                  reservationDateTime.isBefore(potentialBusyEndTime.add(reservationBuffer))) {
                print("XUNG ĐỘT! Bàn $banMa bận do đơn gọi món đang hoạt động.");
                return false;
              }
            }
          } else {
            print("Cảnh báo: Tài liệu ${doc.id} thiếu 'TrangThai' hoặc 'NgayLap'. Bỏ qua.");
            continue;
          }
        }
      }
      return true;
    } catch (e) {
      print("Lỗi trong checkTableAvailability: $e");
      return false;
    }
  }
}