import 'package:doan_nhom_cuoiky/models/DonGoiMon.dart';
import 'package:doan_nhom_cuoiky/services/DonGoiMonService.dart';
import 'package:doan_nhom_cuoiky/utils/QuickAlertService.dart';
import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/screens/CreateReservationScreen.dart';
import 'package:doan_nhom_cuoiky/screens/OrderDetailScreen.dart';
import 'package:intl/intl.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReservationListScreenState createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  final DonGoiMonService _reservationService = DonGoiMonService();
  DateTime _selectedDate = DateTime.now();

  Future<void> _confirmCancelReservation(
    BuildContext context,
    DonGoiMon reservation,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận hủy đặt chỗ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Bạn có chắc chắn muốn hủy đơn đặt chỗ "${reservation.ma ?? 'N/A'}" cho bàn "${reservation.maBan?.viTri ?? 'N/A'}" không?',
                ),
                Text('Trạng thái hiện tại: ${reservation.trangThai ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Có'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _cancelReservation(reservation);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelReservation(DonGoiMon reservation) async {
    try {
      QuickAlertService.showAlertLoading(context, "Đang hủy đơn đặt chỗ...");
      await _reservationService.cancelReservation(
        reservation.ma!,
        reservation.maBan?.ma,
      );
      Navigator.of(context).pop();
      QuickAlertService.showAlertSuccess(
        context,
        "Đã hủy đơn đặt chỗ thành công.",
      );
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      Navigator.of(context).pop();
      QuickAlertService.showAlertFailure(
        context,
        "Đã xảy ra lỗi khi hủy đơn đặt chỗ. Vui lòng thử lại sau.",
      );
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _confirmDeleteReservation(
    BuildContext context,
    DonGoiMon reservation,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa đơn hàng'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Bạn có chắc chắn muốn XÓA VĨNH VIỄN đơn đặt chỗ "${reservation.ma ?? 'N/A'}" không?',
                ),
                const Text('Hành động này không thể hoàn tác.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Có'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteReservation(reservation);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReservation(DonGoiMon reservation) async {
    try {
      QuickAlertService.showAlertLoading(context, "Đang xóa đơn đặt chỗ...");
      await _reservationService.deleteReservation(reservation.ma!);
      Navigator.of(context).pop();
      QuickAlertService.showAlertSuccess(
        context,
        "Đã xóa đơn đặt chỗ thành công.",
      );
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      Navigator.of(context).pop();
      QuickAlertService.showAlertFailure(
        context,
        "Đã xảy ra lỗi khi xóa đơn đặt chỗ. Vui lòng thử lại sau.",
      );
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đặt chỗ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Danh sách đặt chỗ ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DonGoiMon>>(
              stream: _reservationService.getReservationsForDate(_selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Không có đơn đặt chỗ nào cho ngày này.'),
                  );
                }

                final reservations = snapshot.data!;
                return ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    DonGoiMon reservation = reservations[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(
                          reservation.trangThai == 'Hủy'
                              ? Icons.cancel_outlined
                              : Icons.table_bar,
                          color:
                              reservation.trangThai == 'Hủy'
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                        title: Text(
                          'Mã Đơn: ${reservation.ma ?? 'N/A'} - Bàn: ${reservation.maBan?.ma ?? 'N/A'}',
                        ),
                        subtitle: Text(
                          'Vị trí: ${reservation.maBan?.viTri ?? 'N/A'} - Thời gian: ${reservation.ngayLap != null ? DateFormat('HH:mm').format(reservation.ngayLap!.toLocal()) : 'N/A'}\nTrạng thái: ${reservation.trangThai ?? 'N/A'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (reservation.trangThai != 'Hủy' &&
                                reservation.trangThai != 'Hoàn thành')
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.orange,
                                ),
                                tooltip: 'Hủy đơn này',
                                onPressed: () {
                                  _confirmCancelReservation(
                                    context,
                                    reservation,
                                  );
                                },
                              ),
                            if (reservation.trangThai == 'Hủy')
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                tooltip: 'Xóa vĩnh viễn đơn này',
                                onPressed: () {
                                  _confirmDeleteReservation(
                                    context,
                                    reservation,
                                  );
                                },
                              ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      OrderDetailScreen(donGoiMon: reservation),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateReservationScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
