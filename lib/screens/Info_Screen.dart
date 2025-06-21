import 'package:doan_nhom_cuoiky/providers/NhanSuProvider.dart';
import 'package:doan_nhom_cuoiky/utils/QuickAlertService.dart';
import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/models/NhanVien.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class Info_Screen extends StatefulWidget {
  //final NhanVien? nhanVien;

  const Info_Screen({super.key});

  @override
  _Info_ScreenState createState() => _Info_ScreenState();
}

// ignore: camel_case_types
class _Info_ScreenState extends State<Info_Screen> {
  final _tenNVController = TextEditingController();
  final _cccdController = TextEditingController();
  final _maController = TextEditingController();
  final _sdtController = TextEditingController();
  final _ngayVLController = TextEditingController();
  final _tkController = TextEditingController();
  final _mkController = TextEditingController();
  final _chucVuController = TextEditingController();

  bool _obscureText = true;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {});
    }
  }

  // Define a color scheme
  final Color _primaryColor = const Color(0xFFFFD700);
  final Color _accentColor = const Color(0xFFE65100);
  final Color _backgroundColor = const Color(0xFFF8F8F8);
  final Color _textColor = const Color(0xFF212121);
  final Color _subtitleColor = Colors.grey[600]!;

  @override
  void initState() {
    super.initState();
  }

  void _setupControllers() {
    final nhanSuProvider = Provider.of<NhanSuProvider>(context, listen: false);
    nhanSuProvider.currentNhanVienStream.listen((nhanVien) {
      if (nhanVien != null && mounted) {
        setState(() {
          _tenNVController.text = nhanVien?.ten ?? "";
          _chucVuController.text = nhanVien?.vaiTro?.ten ?? "";
          _cccdController.text = nhanVien?.CCCD ?? "";
          _maController.text = nhanVien?.ma ?? "";
          _sdtController.text = nhanVien?.SDT ?? "";
          _ngayVLController.text =
          nhanVien?.ngayVL != null
              ? ' ${DateFormat('dd/MM/yyyy').format(nhanVien!.ngayVL!.toDate())}'
              : 'Chưa cập nhật';
          _tkController.text = nhanVien?.tk ?? "";
          _mkController.text = nhanVien?.mk ?? "";
        });
      }
    });

  }


  @override
  void dispose() {
    _tenNVController.dispose();
    _cccdController.dispose();
    _maController.dispose();
    _sdtController.dispose();
    _ngayVLController.dispose();
    _tkController.dispose();
    _mkController.dispose();
    _chucVuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thông tin nhân viên',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: _backgroundColor,
      body: Consumer<NhanSuProvider>(
        builder: (context, nhanSuProvider, child) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return StreamBuilder<NhanVien?>(
                stream: nhanSuProvider.currentNhanVienStream,
                builder: (context, snapshot) {
                  debugPrint('Info_Screen: StreamBuilder rebuilding. Connection State: ${snapshot.connectionState}, Has Data: ${snapshot.hasData}, Has Error: ${snapshot.hasError}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    debugPrint('Info_Screen: Displaying CircularProgressIndicator.');
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    debugPrint('Info_Screen: Displaying error: ${snapshot.error}');
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    debugPrint('Info_Screen: Displaying "Không tìm thấy nhân viên".');
                    return Center(child: Text("Không tìm thấy nhân viên"));
                  }

                  final NhanVien? nhanVien = snapshot.data as NhanVien;
                  debugPrint('Info_Screen: NhanVien data received. Ten: ${nhanVien?.ten}, MK: ${nhanVien?.mk}');
                  _tenNVController.text = nhanVien?.ten ?? "";
                  _chucVuController.text = nhanVien?.vaiTro?.ten ?? "";
                  _cccdController.text = nhanVien?.CCCD ?? "";
                  _maController.text = nhanVien?.ma ?? "";
                  _sdtController.text = nhanVien?.SDT ?? "";
                  _ngayVLController.text =
                      nhanVien?.ngayVL != null
                          ? ' ${DateFormat('dd/MM/yyyy').format(nhanVien!.ngayVL!.toDate())}'
                          : 'Chưa cập nhật';
                  _tkController.text = nhanVien?.tk ?? "";
                  _mkController.text = nhanVien?.mk ?? "";

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                    child: Column(
                      children: [
                        _buildProfileHeader(nhanVien),
                        SizedBox(height: constraints.maxHeight * 0.03),
                        _buildInfoCard(),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(NhanVien? nhanVien) {
    ImageProvider<Object> avatarImage;
    if (nhanVien?.anh != null && nhanVien!.anh!.isNotEmpty) {
      avatarImage = NetworkImage(nhanVien!.anh!);
    } else {
      avatarImage = const NetworkImage(
        'https://via.placeholder.com/150/000000/FFFFFF?text=',
      ); // A transparent placeholder
    }
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_primaryColor, _accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child:
                    nhanVien?.anh != null && nhanVien!.anh!.isNotEmpty
                        ? Image(image: avatarImage, fit: BoxFit.cover)
                        : Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(Icons.camera_alt, size: 20, color: _primaryColor),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _tenNVController.text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        Text(
          'Mã NV: ${_maController.text}',
          style: TextStyle(fontSize: 16, color: _subtitleColor),
        ),
        if (_tkController.text.isNotEmpty)
          Text(
            'Tài khoản: ${_tkController.text}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: _accentColor),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('CCCD', _cccdController.text),
            Divider(height: 20, color: Colors.grey[200]),
            _buildInfoRow('Số điện thoại', _sdtController.text),
            Divider(height: 20, color: Colors.grey[200]),
            _buildPasswordRow('Mật khẩu', _mkController.text),
            Divider(height: 20, color: Colors.grey[200]),
            _buildInfoRow('Chức vụ', _chucVuController.text),

            Divider(height: 20, color: Colors.grey[200]),
            _buildInfoRow(
              'Ngày vào làm',
              _ngayVLController.text.isNotEmpty
                  ? _ngayVLController.text
                  : 'Chưa cập nhật',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _subtitleColor,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRow(String label, String value) { // 'value' ở đây sẽ là _mkController.text
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _subtitleColor,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                // Luôn hiển thị '••••••••' hoặc một placeholder
                _obscureText ? '••••••••' : value, // Hoặc bất kỳ chuỗi thông báo nào khác
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: _primaryColor,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

}
