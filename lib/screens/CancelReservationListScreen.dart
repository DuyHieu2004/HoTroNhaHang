import 'package:doan_nhom_cuoiky/models/DonGoiMon.dart';
import 'package:doan_nhom_cuoiky/services/DonGoiMonService.dart';
import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/screens/OrderDetailScreen.dart';
import 'package:intl/intl.dart';

class CancelReservationListScreen extends StatefulWidget {
  const CancelReservationListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CancelReservationListScreenState createState() => _CancelReservationListScreenState();
}

class _CancelReservationListScreenState extends State<CancelReservationListScreen> {
  final DonGoiMonService _donGoiMon = DonGoiMonService();
  DateTime _selectedDate = DateTime.now();

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
              stream: _donGoiMon.getReservationsForDate(_selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {                 
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {                 
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {                 
                  return const Center(child: Text('Không có đơn đặt chỗ nào cho ngày này.'));
                }

                final reservations = snapshot.data!;               
                return ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];                   

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: Icon(
                          reservation.trangThai == 'Hủy' ? Icons.cancel_outlined : Icons.table_bar,
                          color: reservation.trangThai == 'Hủy' ? Colors.red : Colors.blue,
                        ),
                        title: Text('Mã Đơn: ${reservation.ma ?? 'N/A'} - Bàn: ${reservation.maBan?.ma ?? 'N/A'}'),
                        subtitle: Text(
                          'Vị trí: ${reservation.maBan?.viTri ?? 'N/A'} - Thời gian: ${
                              reservation.ngayLap != null ? DateFormat('HH:mm').format(reservation.ngayLap!.toLocal()) : 'N/A'
                          }\nTrạng thái: ${reservation.trangThai ?? 'N/A'}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(donGoiMon: reservation),
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
    );
  }
}