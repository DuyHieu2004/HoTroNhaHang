// File: lib/screens/OrderDetailScreen.dart
import 'package:doan_nhom_cuoiky/models/DonGoiMon.dart';
import 'package:doan_nhom_cuoiky/services/BanService.dart';
import 'package:doan_nhom_cuoiky/services/ChiTietDonGoiMonService.dart';
import 'package:doan_nhom_cuoiky/services/DonDatChoService.dart';
import 'package:doan_nhom_cuoiky/services/DonGoiMonService.dart';
import 'package:doan_nhom_cuoiky/services/PhieuTamUngService.dart';
import 'package:doan_nhom_cuoiky/utils/QuickAlertService.dart';
import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/models/ChiTietGoiMon.dart';
import 'package:doan_nhom_cuoiky/models/DonDatCho.dart';
import 'package:doan_nhom_cuoiky/models/PhieuTamUng.dart';
import 'package:intl/intl.dart';


class OrderDetailScreen extends StatefulWidget {
  final DonGoiMon donGoiMon;

  const OrderDetailScreen({super.key, required this.donGoiMon});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final DonGoiMonService _goiMonService = DonGoiMonService();
  final ChiTietDonGoiMonService _ctgoiMonService = ChiTietDonGoiMonService();
  final PhieuTamUngService _tamUngService = PhieuTamUngService();
  final DonDatChoService _datChoService = DonDatChoService();
  final BanService _banService = BanService();
  late Stream<List<ChiTietGoiMon>> _chiTietGoiMonStream;

  DonDatCho? _donDatCho;
  PhieuTamUng? _phieuTamUng;

  @override
  void initState() {
    super.initState();
    _initializeData(); //
  }

  void _initializeData() async {
    if (widget.donGoiMon.ma != null) {
      _chiTietGoiMonStream = _ctgoiMonService.getChiTietGoiMonForDonGoiMon(widget.donGoiMon.ma!);
    } else {
      _chiTietGoiMonStream = Stream.value([]);
    }

    if (widget.donGoiMon.maDonDatCho != null) {
      final fetchedDonDatCho = await _datChoService.getDonDatChoById(widget.donGoiMon.maDonDatCho);
      setState(() {
        _donDatCho = fetchedDonDatCho;
      });

      if (_donDatCho?.maPhieuTamUng != null) {
        final fetchedPhieuTamUng = await _tamUngService.getPhieuTamUngById(_donDatCho!.maPhieuTamUng);
        setState(() {
          _phieuTamUng = fetchedPhieuTamUng;
        });
      }
    }

    if (widget.donGoiMon.ngayGioDenDuKien != null &&
        widget.donGoiMon.trangThai == "Chờ xử lý") {
      final now = DateTime.now();
      final expectedArrivalTime = widget.donGoiMon.ngayGioDenDuKien!;
      final difference = expectedArrivalTime.difference(now);

      if (difference.inMinutes <= 30 && difference.inMinutes >= 0) {
        await _updateTableStatusToReserved();
      } else if (now.difference(expectedArrivalTime).inHours >= 1 && widget.donGoiMon.trangThai != "Hủy") {

        _autoCancelReservation();
      }
    }

    if (widget.donGoiMon.ngayGioDenDuKien != null &&
        widget.donGoiMon.trangThai != "Hủy" &&
        DateTime.now().difference(widget.donGoiMon.ngayGioDenDuKien!).inHours >= 1
        && widget.donGoiMon.maBan?.trangThai == "Đã đặt"
    ) {
      _autoCancelReservation();
    }
  }

  Future<void> _updateTableStatusToReserved() async {
    try {
      if (widget.donGoiMon.maBan?.ma != null && widget.donGoiMon.trangThai != "Đã đặt") {
        await _banService.updateBanStatus(widget.donGoiMon.maBan!.ma!, "Đã đặt");
        await _goiMonService.updateDonGoiMonStatus(widget.donGoiMon.ma!, "Đã đặt");
        setState(() {
          widget.donGoiMon.trangThai = "Đã đặt";
        });
        QuickAlertService.showAlertSuccess(context, "Bàn đã được đặt thành công!");
      }
    } catch (e) {
      QuickAlertService.showAlertFailure(context, "Không thể cập nhật trạng thái bàn.");
    }
  }


  Future<void> _autoCancelReservation() async {
    try {
      await _goiMonService.cancelReservation(
        widget.donGoiMon.ma!,
        widget.donGoiMon.maBan?.ma,
      );

      setState(() {
        widget.donGoiMon.trangThai = "Hủy";
      });
      QuickAlertService.showAlertSuccess(context, "Đơn đặt đã tự động hủy do quá hạn.");
    } catch (e) {
      QuickAlertService.showAlertFailure(context, "Không thể tự động hủy đơn đặt.");
    }
  }

  Future<void> _cancelReservation() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận hủy?'),
          content: const Text('Bạn có chắc chắn muốn hủy đơn đặt này không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                _banService.updateBanStatus(widget.donGoiMon.maBan!.ma!, "Trống");
                    Navigator.of(context).pop(true);
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _goiMonService.cancelReservation(
          widget.donGoiMon.ma!,
          widget.donGoiMon.maBan?.ma,
        );
        QuickAlertService.showAlertSuccess(context, "Đã hủy đặt bàn thành công");
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      } catch (e) {
        QuickAlertService.showAlertFailure(context, "Đã hủy đặt bàn thất bại");
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String customerName = "N/A";
    String phoneNumber = "N/A";
    String customerContact = "N/A";
    double advancePayment = 0.0;

    if (_donDatCho != null) {
      customerName = _donDatCho!.tenKhachHang ?? "N/A";
      phoneNumber = _donDatCho!.soDienThoai ?? "N/A";
      customerContact = _donDatCho!.ghiChu ?? "N/A";
    }

    if (_phieuTamUng != null) {
      advancePayment = _phieuTamUng!.soTien ?? 0.0;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn đặt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thông tin khách hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Tên khách hàng: $customerName'),
              Text('Số điện thoại: $phoneNumber'),
              Text('Liên hệ khách: $customerContact'),
              const SizedBox(height: 20),
              const Text('Thông tin đơn đặt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Mã đơn: ${widget.donGoiMon.ma ?? 'N/A'}'),
              Text('Bàn: ${widget.donGoiMon.maBan?.ma ?? 'N/A'} - ${widget.donGoiMon.maBan?.viTri ?? 'N/A'}'),
              Text('Giờ đến: ${widget.donGoiMon.ngayGioDenDuKien != null ? DateFormat('HH:mm - dd/MM/yyyy').format(widget.donGoiMon.ngayGioDenDuKien!.toLocal()) : 'N/A'}'),
              Text('Trạng thái: ${widget.donGoiMon.trangThai ?? 'N/A'}'),
              const SizedBox(height: 10),
              const Text('Món ăn:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<List<ChiTietGoiMon>>(
                stream: _chiTietGoiMonStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Lỗi tải món ăn: ${snapshot.error}');
                  }
                  final dishes = snapshot.data ?? [];
                  if (dishes.isEmpty) {
                    return const Text('Chưa có món ăn nào trong đơn này.');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dishes.map((item) {
                      double itemTotal = (item.getMonAn?.getGiaBan ?? 0) * (item.getSoLuong ?? 0);
                      return Text('- ${item.getMonAn?.getTen ?? 'N/A'} x ${item.getSoLuong ?? 0} = ${itemTotal.toStringAsFixed(0)} VND');
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 10),
              Text('Tiền tạm ứng: ${advancePayment.toStringAsFixed(0)} VND', style: const TextStyle(fontWeight: FontWeight.bold)),
              StreamBuilder<List<ChiTietGoiMon>>(
                stream: _chiTietGoiMonStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  }
                  final dishes = snapshot.data ?? [];
                  double totalAmount = 0.0;
                  for (var item in dishes) {
                    totalAmount += (item.getMonAn?.getGiaBan ?? 0) * (item.getSoLuong ?? 0);
                  }
                  return Text('Tổng cộng: ${totalAmount.toStringAsFixed(0)} VND', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange));
                },
              ),
              const SizedBox(height: 20),
              if (widget.donGoiMon.trangThai != "Hủy")
                ElevatedButton(
                  onPressed: _cancelReservation,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}