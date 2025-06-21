import 'dart:async';

import 'package:doan_nhom_cuoiky/models/Ban.dart';
import 'package:doan_nhom_cuoiky/services/BanService.dart';
import 'package:flutter/material.dart';

class BanProvider extends ChangeNotifier{
  final BanService _banService = BanService();
  List<Ban> _bans = [];
  StreamSubscription<List<Ban>>? _banSubscription;
  List<Ban> get bans => _bans;

  BanProvider() {
    _startListeningToBans();
    _loadBans();
  }

  // Phương thức để bắt đầu lắng nghe Stream
  void _startListeningToBans() {
    _banSubscription?.cancel(); // Hủy subscription cũ nếu có
    _banSubscription = _banService.getBansStream().listen(( List<Ban> list) {
      _bans = list;
      notifyListeners(); // Thông báo khi có dữ liệu mới từ stream
    }, onError: (error) {
      print("Lỗi khi lắng nghe danh sách bàn: $error");
      // Xử lý lỗi (ví dụ: hiển thị snackbar)
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _banSubscription?.cancel();
    super.dispose();
  }


  Future<void> _loadBans() async {
    _bans = await _banService.getBanList();
    notifyListeners();
  }

  Future<void> addBan(Ban ban) async {
    await _banService.addBan(ban);
    _loadBans();
  }

  Future<void> updateBan(Ban ban) async {
    await _banService.updateBan(ban);
    _loadBans();
  }

  Future<void> deleteBan(String id) async {
    await _banService.deleteBan(id);
    _loadBans();
  }

  Ban getBanById(String id) {
    return _bans.firstWhere((ban) => ban.ma == id);
  }
}