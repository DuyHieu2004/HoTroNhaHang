import 'package:doan_nhom_cuoiky/models/DonGoiMon.dart';
import 'package:doan_nhom_cuoiky/providers/DonDatChoProvider.dart';
import 'package:doan_nhom_cuoiky/services/BanService.dart';
import 'package:doan_nhom_cuoiky/services/DonGoiMonService.dart';
import 'package:doan_nhom_cuoiky/services/NotificationService.dart';
import 'package:doan_nhom_cuoiky/utils/QuickAlertService.dart';
import 'package:doan_nhom_cuoiky/utils/Toast.dart';
import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/models/Ban.dart';
import 'package:doan_nhom_cuoiky/models/ChiTietGoiMon.dart';
import 'package:doan_nhom_cuoiky/models/DonDatCho.dart';
import 'package:doan_nhom_cuoiky/models/PhieuTamUng.dart';
import 'package:doan_nhom_cuoiky/screens/SelectDishesScreen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateReservationScreenState createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _customerContactController = TextEditingController();
  final TextEditingController _advancePaymentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  List<ChiTietGoiMon> _selectedDishes = [];



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<DonDatChoProvider>(context, listen:  false);
      _advancePaymentController.text = provider.advancePayment.toStringAsFixed(0);
      _dateController.text = DateFormat('dd/MM/yyyy').format(provider.selectedDate!);
      _timeController.text = provider.selectedTime!.format(context);
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<DonDatChoProvider>(context);
    _dateController.text = DateFormat('dd/MM/yyyy').format(provider.selectedDate!);
    _timeController.text = provider.selectedTime!.format(context);
    _advancePaymentController.text = provider.advancePayment.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _customerContactController.dispose();
    _advancePaymentController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }


  Future<void> _selectDate(BuildContext context) async {
    final provider = Provider.of<DonDatChoProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      provider.setSelectedDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {

    final provider = Provider.of<DonDatChoProvider>(context, listen: false);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: provider.selectedTime!,
    );
    if (picked != null ) {
      provider.setSelectedTime(picked);
    }
  }

  Future<void> _selectDishes() async {
    final provider = Provider.of<DonDatChoProvider>(context, listen: false);
    final List<ChiTietGoiMon>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SelectDishesScreen(initialSelectedDishes: _selectedDishes),
      ),
    );

    if (result != null) {
      provider.setSelectedDishes(result);
      ToastUtils.showInfo("Đã chọn ${result.length} món ăn.");
    }
  }



  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DonDatChoProvider>(context,listen:  false);
    bool isConfirmButtonAlwaysEnabled = provider.isConformationButtonAlwaysEnabled();
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo phiếu đặt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Thông tin khách hàng',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Tên khách hàng'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Vui lòng nhập tên khách hàng' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _customerContactController,
                decoration: const InputDecoration(labelText: 'Liên hệ khách'),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Thông tin đặt bàn',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              InkWell(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Ngày đến',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Vui lòng chọn ngày đến' : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectTime(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Giờ đến',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Vui lòng chọn giờ đến' : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Consumer<DonDatChoProvider>(
                builder: (context, donDatChoProvider, child) {
                  return FutureBuilder<List<Ban>>(
                    future: donDatChoProvider.GetAvalableTableForSelectedDateTime(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Lỗi: ${snapshot.error}'));
                      }

                      List<Ban> displayTables = snapshot.data ?? [];

                      print("Selected Table: ${provider.selectedTable?.ma}, Display Tables: ${displayTables.map((ban) => ban.ma).toList()}");


                      if (displayTables.isEmpty) {
                        donDatChoProvider.setSelectedTable(null); // Reset selectedTable nếu không có bàn
                        return const Text('Không có bàn nào phù hợp để đặt.');
                      }

                      // Kiểm tra nếu selectedTable không nằm trong displayTables, reset nó
                      if (donDatChoProvider.selectedTable != null &&
                          !displayTables.contains(donDatChoProvider.selectedTable)) {
                        donDatChoProvider.setSelectedTable(null);
                      }

                      if (displayTables.isEmpty) {
                        return const Text('Không có bàn nào phù hợp để đặt.');
                      }

                      return DropdownButtonFormField<Ban>(
                        decoration: const InputDecoration(labelText: 'Bàn'),
                        value: provider.selectedTable,
                        items:
                        displayTables.map((ban) {
                          return DropdownMenuItem<Ban>(
                            value: ban,
                            child: Text("Vị trí: ${ban.viTri ?? 'N/A'}"),
                          );
                        }).toList(),
                        onChanged: (Ban? newBan) {
                         provider.setSelectedTable(newBan);
                        },
                        validator:
                            (value) => value == null ? 'Vui lòng chọn bàn' : null,
                      );
                    },
                  );
              },),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectDishes,
                child: const Text('Chọn món ăn'),
              ),
              if (_selectedDishes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Món đã chọn:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._selectedDishes.map(
                      (ctgm) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '${ctgm.getMonAn?.getTen ?? 'Món không tên'} x ${ctgm.getSoLuong ?? 0}',
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: false,
                controller: _advancePaymentController,
                decoration: const InputDecoration(labelText: 'Tiền tạm ứng'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Vui lòng nhập số tiền hợp lệ';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:()=>
                    isConfirmButtonAlwaysEnabled ?
                    CreateReservation(
                      _customerNameController.text,
                      _phoneNumberController.text,
                      _customerContactController.text
                    ) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isConfirmButtonAlwaysEnabled ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> CreateReservation(String customerName, String phoneNumber, String customerContact) async {
    try{
      final provider = Provider.of<DonDatChoProvider>(context, listen: false);
      bool isSucessCreateReservation = await provider.CreateReservation(customerName, phoneNumber, customerContact) ;
      if(isSucessCreateReservation){
        QuickAlertService.showAlertSuccess(context, "Đặt bàn thành công");
        Navigator.pop(context);
      }
      else
        QuickAlertService.showAlertFailure(context, "Đặt bàn thất bại");

    }catch(e){
      print("Lỗi: "+e.toString());
      QuickAlertService.showAlertFailure(context, "Đặt bàn thất bại");
    }

  }


}
