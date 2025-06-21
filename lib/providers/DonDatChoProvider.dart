import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan_nhom_cuoiky/models/DonDatCho.dart';
import 'package:doan_nhom_cuoiky/services/BanService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../models/Ban.dart';
import '../models/ChiTietGoiMon.dart';
import '../models/DonGoiMon.dart';
import '../models/PhieuTamUng.dart';
import '../services/DonDatChoService.dart';
import '../services/DonGoiMonService.dart';
import '../services/NotificationService.dart';
import '../utils/QuickAlertService.dart';
import '../utils/Toast.dart';

class DonDatChoProvider extends ChangeNotifier {
  List<DonDatCho> _donDatChoList = [];
  final DonDatChoService _donDatChoService = DonDatChoService();
  final BanService _banService = BanService();
  final DonGoiMonService _donGoiMonService = DonGoiMonService();

  List<DonDatCho> get donDatChoList => _donDatChoList;

  DonDatChoProvider() {
    _loadDonDatCho();
    _startUpdateStatusTableWithTimer();
  }


  @override
  void dispose() {

  }

  List<ChiTietGoiMon> _selectedDishes =[];
  DateTime? _selectedDate= DateTime.now();
  TimeOfDay? _selectedTime = TimeOfDay.now();


  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;

  List<ChiTietGoiMon> get selectedDishes => _selectedDishes;
  Ban? _selectedTable;
  double _advancePayment = 100000.0;
  double get advancePayment => _advancePayment;


  Ban? get selectedTable => _selectedTable;

  void _updateAdvancePayment() {
    double _advancePaymentTemp =0.0;
    if (_selectedDishes.isEmpty) {
      _advancePaymentTemp = 100000.0;
    } else {
      double totalOrderAmount = 0.0;
      for (var dishDetail in _selectedDishes) {
        totalOrderAmount += dishDetail.tinhTien as double;
      }
      _advancePaymentTemp = totalOrderAmount * 0.40 + 100000.0;
    }
    _advancePayment = _advancePaymentTemp;
  }

  Future<void> _loadDonDatCho() async {
    _donDatChoList = await _donDatChoService.getDonDatCho();
    notifyListeners();
  }

  Future<void> addDonDatCho(DonDatCho donDatCho) async {
    await _donDatChoService.addDonDatCho(donDatCho);
    await _loadDonDatCho();
  }

  Future<void> deleteDonDatCho(String id) async {
    await _donDatChoService.deleteDonDatCho(id);
    await _loadDonDatCho();
  }

  Future<void> updateDonDatCho(DonDatCho donDatCho) async {
    await _donDatChoService.updateDonDatCho(donDatCho);
    await _loadDonDatCho();
  }

  bool isConformationButtonAlwaysEnabled(){
    return _selectedTable != null &&
        _selectedDate != null &&
        _selectedTime != null;
  }

  void setSelectedDishes(List<ChiTietGoiMon> result) {
    _selectedDishes = result;
    _updateAdvancePayment();
    notifyListeners();
  }

  void setSelectedDate(DateTime picked) {
    _selectedDate = picked;
    _selectedTable = null;
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay picked) {
    _selectedTime = picked;
    _selectedTable = null;
    notifyListeners();

  }

  Future<bool> CreateReservation(
     String customerName,
      String phoneNumber,
     String customerContact
      ) async {

    if (_selectedTable == null) {
      ToastUtils.showError("Vui lòng chọn bàn trước khi đặt món ăn.");
      return false;
    }

    final availableTables = await GetAvalableTableForSelectedDateTime();
    if (!availableTables.contains(_selectedTable)) {
      ToastUtils.showError("Bàn đã chọn không còn khả dụng. Vui lòng chọn lại.");
      _selectedTable = null;
      notifyListeners();
      return false;
    }

    try {
      final DateTime now = DateTime.now();
      final DateTime reservationDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      bool isTableAvailable = await _banService.checkTableAvailability(_selectedTable!.ma, reservationDateTime);

      if(!isTableAvailable){
        print( "Bàn ${_selectedTable!.ma} đã có người đặt trước rồi!");
        return false;
      }

      final bool isToday =
          _selectedDate!.year == now.year &&
              _selectedDate!.month == now.month &&
              _selectedDate!.day == now.day;

      if (isToday && _selectedTable!.trangThai != "Trống") {
         print("Bàn ${_selectedTable!.ma} đang ở trạng thái ${_selectedTable!.trangThai} không thể đặt cho hôm nay.");
        return false;
      }

      final bool isWithinNextHour =
          reservationDateTime.isAfter(now) &&
              reservationDateTime.difference(now).inMinutes <= 60;


      DonDatCho newDonDatCho = DonDatCho(
        tenKhachHang: customerName,
        soDienThoai: phoneNumber,
        ghiChu: customerContact,
        ngayDat: reservationDateTime,
      );

      PhieuTamUng? newPhieuTamUng;
      if (advancePayment > 0) {
        newPhieuTamUng = PhieuTamUng(
          soTien: advancePayment,
          ngayLap: DateTime.now(),
        );
      }

      DonGoiMon newDonGoiMon = DonGoiMon(
        ngayLap: DateTime.now(),
        ngayGioDenDuKien: reservationDateTime,
        trangThai: "Đã đặt",
        ghiChu: "",
        maBan: _selectedTable,
      );

      await _donGoiMonService.addReservation(
        newDonGoiMon,
        _selectedDishes,
        newDonDatCho,
        newPhieuTamUng,
        isWithinNextHour,
      );

      await NotificationService().scheduleReservationNotification(newDonDatCho);

      String newTableStatus;

      if (_selectedTable?.ma != null ) {
        newTableStatus = isWithinNextHour? "Đã đặt" : "Chờ đến";
        await _banService.updateBanStatus(_selectedTable!.ma!, newTableStatus);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Lỗi: "+e.toString());
      return false;
    }
    return false;
  }

  Future<List<Ban>> GetAvalableTableForSelectedDateTime() async {
    List<Ban> availableTable = [];
    final DateTime now = DateTime.now();
    bool isToday = (
        now.year == _selectedDate!.year &&
            now.month == _selectedDate!.month &&
            now.day == _selectedDate!.day
    );
    List<Ban> allBan = await _banService.getBanList();
    final DateTime reservationDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    for (var ban in allBan) {
      if (ban.ma == null) continue;
      bool isAvailableTableInDateTime = await _banService.checkTableAvailability(ban.ma, reservationDateTime);
      print("Bàn ${ban.ma}, isAvailable: $isAvailableTableInDateTime, trangThai: ${ban.trangThai}");
      if (isAvailableTableInDateTime) {
        if (isToday) {
          if (ban.trangThai == "Trống") {
            availableTable.add(ban);
          }
        } else {
          Ban tableAvailable = Ban(
            ma: ban.ma!,
            sucChua: ban.sucChua!,
            viTri: ban.viTri!,
            trangThai: "Trống",
          );
          availableTable.add(tableAvailable);
        }
      }
    }

    print("Số bàn khả dụng: ${availableTable.length}");
    return availableTable;
  }

  void setSelectedTable(Ban? newBan) {
    if(_selectedTable != newBan)
    _selectedTable = newBan;
    notifyListeners();
  }

  final Duration _durationUpdateStatus = Duration(minutes: 1);
  void _startUpdateStatusTableWithTimer() {

    Timer.periodic(_durationUpdateStatus, (timer) {
      _CheckUpdateStatusTable();
    },);
  }

  Future<void> _CheckUpdateStatusTable() async{
    final List<DonGoiMon> listDonGoiMonTrangThaiChoDen =
       await _donGoiMonService.getDonGoiMonChoDen();

    for (var donGoiMon in listDonGoiMonTrangThaiChoDen) {
      if(donGoiMon.trangThai =="Chờ đến" && withNextStatus(donGoiMon)){
        await _banService.updateBanStatus(donGoiMon.maBan!.ma!, "Đã đặt");
        await _donGoiMonService.updateDonGoiMonStatus(donGoiMon!.ma!, "Đã đặt");
      }
    }

  }

  bool withNextStatus(DonGoiMon donGoiMon) {
    DateTime? reservation = donGoiMon.ngayGioDenDuKien;
    if (reservation == null) {
      return false;
    }
    DateTime today = DateTime.now();
    final Duration difference = reservation.difference(today);
    if(difference.inMinutes <= 60  && difference.inMinutes >= 60){
      return true;
    }
    return false;
  }


}