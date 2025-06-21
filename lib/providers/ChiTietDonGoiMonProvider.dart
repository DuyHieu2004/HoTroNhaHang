import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan_nhom_cuoiky/models/ChiTietGoiMon.dart';
import 'package:doan_nhom_cuoiky/models/DonGoiMon.dart';
import 'package:doan_nhom_cuoiky/services/ChiTietDonGoiMonService.dart';
import 'package:flutter/foundation.dart';

import '../models/Ban.dart';
import '../models/MonAn.dart';
import 'BanProvider.dart';
import 'DonGoiMonProvider.dart';

class ChiTietDonGoiMonProvider extends ChangeNotifier {
  final ChiTietDonGoiMonService _service = ChiTietDonGoiMonService();
  List<ChiTietGoiMon> _chiTietDonGoiMonList = [];

  ChiTietDonGoiMonProvider() {
    _loadChiTietDonGoiMonList();
  }

  Future<void> _loadChiTietDonGoiMonList() async {
    _chiTietDonGoiMonList = await _service.getChiTietDonGoiMonList();
    notifyListeners();
  }

  List<ChiTietGoiMon> get chiTietDonGoiMonList => _chiTietDonGoiMonList;

  Future<void> addChiTietDonGoiMon(ChiTietGoiMon chiTiet) async {
    await _service.addChiTietDonGoiMon(chiTiet);
    await _loadChiTietDonGoiMonList();
  }

  Future<void> updateChiTietDonGoiMon(ChiTietGoiMon chiTiet) async {
    await _service.updateChiTietDonGoiMon(chiTiet);
    await _loadChiTietDonGoiMonList();
  }

  Future<void> deleteChiTietDonGoiMon(String id) async {
    await _service.deleteChiTietDonGoiMon(id);
    await _loadChiTietDonGoiMonList();
  }

  List<ChiTietGoiMon> getChiTietById(String id) {
    return _chiTietDonGoiMonList.where((chiTiet) => (chiTiet.getMaDonGoiMon as DonGoiMon).ma == id).toList();
  }

  // Đây là phương thức quan trọng, nơi chứa logic nghiệp vụ đặt món
  Future<void> confirmOrder({
    required Map<MonAn, int> cartItems,
    required Ban selectedBan,
    required String notes,
    required DonGoiMonProvider donGoiMonProvider, // Inject dependency
    required BanProvider banProvider, // Inject dependency
  }) async {
    // Logic xác nhận đơn hàng cũ của bạn từ ChiTietGoiMonScreen
    DonGoiMon? donGoiMonToUse;

    try {
      donGoiMonToUse = await donGoiMonProvider.getNewDocumentId(
        selectedBan.ma!,
      );
    } catch (e) {
      donGoiMonToUse = null; // Hoặc xử lý lỗi cụ thể hơn
    }

    Ban updatedBan = Ban(
      ma: selectedBan.ma,
      viTri: selectedBan.viTri,
      sucChua: selectedBan.sucChua,
      trangThai: "Đang phục vụ",
    );

    await banProvider.updateBan(updatedBan);

    if (donGoiMonToUse == null) {
      String donGoiMonId = "D${DateTime.now().microsecondsSinceEpoch}";
      donGoiMonToUse = DonGoiMon(
        ma: donGoiMonId,
        ngayLap: Timestamp.now().toDate(),
        trangThai: "Đang phục vụ",
        ghiChu: notes.trim(),
        maBan: updatedBan,
      );

      await donGoiMonProvider.addDonGoiMon(donGoiMonToUse);
    }

    if (donGoiMonToUse.ma == null) {
      throw Exception("Lỗi khi tạo đơn gọi món: ID không hợp lệ.");
    }

    // Lấy danh sách chi tiết đơn gọi món hiện tại cho đơn này (snapshot một lần)
    List<ChiTietGoiMon> dsChiTietDGM = await _service.getChiTietGoiMonForDonGoiMonOnce(
      donGoiMonToUse.ma!,
    );

    // Dùng Map để dễ dàng kiểm tra và cập nhật các món ăn đã có
    Map<String, ChiTietGoiMon> existingItemsMap = {
      for (var ctgm in dsChiTietDGM) (ctgm.getMonAn as MonAn).getMa!: ctgm
    };

    for (var entry in cartItems.entries) {
      MonAn monAn = entry.key;
      int soLuong = entry.value;

      if (existingItemsMap.containsKey(monAn.getMa)) {
        // Món ăn đã có trong đơn, cập nhật số lượng
        ChiTietGoiMon existingChiTiet = existingItemsMap[monAn.getMa]!;
        existingChiTiet.soLuong = (existingChiTiet.getSoLuong ?? 0) + soLuong; // Cộng dồn
        await _service.updateChiTietDonGoiMon(existingChiTiet);
      } else {
        // Món ăn chưa có, thêm mới chi tiết
        String chiTietId =
            'CTGM_${donGoiMonToUse.ma}_${monAn.getMa}_${DateTime.now().microsecondsSinceEpoch}';

        ChiTietGoiMon chiTiet = ChiTietGoiMon(
          ma: chiTietId,
          monAn: monAn,
          soLuong: soLuong,
          maDonGoiMon: donGoiMonToUse,
        );
        await _service.addChiTietDonGoiMon(chiTiet);
      }
    }

    notifyListeners(); // Notify nếu bạn muốn các listener của provider này phản ứng (ví dụ, màn hình tổng quan đơn hàng)
  }

  // Để phương thức này chỉ lấy data 1 lần từ service, không cần cache vào _chiTietDonGoiMonList
  // vì mục đích của nó là query cụ thể cho một DonGoiMon.
  Future<List<ChiTietGoiMon>> getChiTietByIdOnce(String id) async {
    return await _service.getChiTietGoiMonForDonGoiMonOnce(id);
  }


}