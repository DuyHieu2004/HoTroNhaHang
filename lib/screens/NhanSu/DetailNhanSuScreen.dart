import 'package:doan_nhom_cuoiky/screens/NhanSu/NhanSuScreen.dart';
import 'package:doan_nhom_cuoiky/utils/QuickAlertService.dart';
import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/models/NhanVien.dart';
import 'package:doan_nhom_cuoiky/providers/NhanSuProvider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../../models/VaiTro.dart';

class DetailNhanSu extends StatefulWidget {
  final NhanVien nhanVien;

  const DetailNhanSu({Key? key, required this.nhanVien}) : super(key: key);

  @override
  _DetailNhanSuState createState() => _DetailNhanSuState();
}

class _DetailNhanSuState extends State<DetailNhanSu> {
  late TextEditingController maController;
  late TextEditingController tenController;
  late TextEditingController sdtController;
  late TextEditingController cccdController;
  late TextEditingController tkController;
  late TextEditingController mkController;
  late TextEditingController anhController;
  File? _image;
  String selectedVaiTro = '';
  bool _isPasswordVisible = false;

  final List<String> vaiTroOptions = ['Quản lý', 'Thu ngân', 'Phục vụ'];

  @override
  void initState() {
    super.initState();
    maController = TextEditingController(text: widget.nhanVien.ma);
    tenController = TextEditingController(text: widget.nhanVien.ten);
    sdtController = TextEditingController(text: widget.nhanVien.SDT);
    cccdController = TextEditingController(text: widget.nhanVien.CCCD);
    tkController = TextEditingController(text: widget.nhanVien.tk);
    mkController = TextEditingController(text: widget.nhanVien.mk);
    anhController = TextEditingController(text: widget.nhanVien.anh);
    selectedVaiTro = widget.nhanVien.vaiTro.toString();
  }

  Widget _buildInfoRow(BuildContext context, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: value,
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
  }

  Future<void> _pickImage() async {
    await _requestPermission();
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() {
      _image = imageTemp;
      anhController.text = image.path;
    });
  }

  Future<void> _updateNhanVien(BuildContext context) async {
    final nhanSuProvider = Provider.of<NhanSuProvider>(context, listen: false);
    try {
      final updatedNhanVien = NhanVien(
        ma: maController.text,
        ten: tenController.text,
        SDT: sdtController.text,
        CCCD: cccdController.text,
        tk: tkController.text,
        mk: mkController.text,
        vaiTro: VaiTro.fromString(selectedVaiTro),
        anh: anhController.text.isNotEmpty ? anhController.text : null,
      );
      await nhanSuProvider.updateNhanVien(updatedNhanVien);
      QuickAlertService.showAlertSuccess(context, 'Cập nhật thành công');
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context, true);
    } catch (e) {
      QuickAlertService.showAlertFailure(context, 'Cập nhật thất bại');
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Text('Xác nhận xóa'),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn xóa nhân viên này? Hành động này không thể hoàn tác.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () async {
                QuickAlertService.showAlertLoading(context, "Đang xử lý");
                final nhanSuProvider = Provider.of<NhanSuProvider>(context, listen: false);
                try {
                  await nhanSuProvider.deleteNhanVien(widget.nhanVien);
                  Navigator.pop(context);
                  QuickAlertService.showAlertSuccess(context, 'Xóa nhân viên thành công');
                  await Future.delayed(const Duration(seconds: 2));
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NhanSuScreen()), (route) => route.isFirst);
                } catch (e) {
                  Navigator.pop(context);
                  QuickAlertService.showAlertFailure(context, 'Xóa nhân viên thất bại');
                  await Future.delayed(const Duration(seconds: 2));
                  Navigator.pop(context);
                }
              },
              child: Text('Xóa', style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết nhân viên',
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmDialog(context),
            tooltip: 'Xóa nhân viên',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: (_image != null
                            ? FileImage(_image!)
                            : (widget.nhanVien.anh != null && widget.nhanVien.anh!.isNotEmpty
                            ? NetworkImage(widget.nhanVien.anh!)
                            : const AssetImage('assets/images/default.png'))) as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: _pickImage,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Card(
              elevation: 4,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      'Mã nhân viên',
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: TextFormField(
                          controller: maController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Mã nhân viên',
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          enabled: false,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    _buildInfoRow(
                      context,
                      'Họ và tên',
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: TextFormField(
                          controller: tenController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập họ và tên',
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    _buildInfoRow(
                      context,
                      'Số điện thoại',
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: TextFormField(
                          controller: sdtController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập số điện thoại',
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    _buildInfoRow(
                      context,
                      'CCCD',
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: TextFormField(
                          controller: cccdController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập số CCCD',
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    _buildInfoRow(
                      context,
                      'Tài khoản',
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: TextFormField(
                          controller: tkController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tài khoản',
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          enabled: false,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    _buildInfoRow(
                      context,
                      'Vai trò',
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: DropdownButton<String>(
                          value: selectedVaiTro,
                          isExpanded: true,
                          underline: Container(),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedVaiTro = newValue!;
                            });
                          },
                          items: vaiTroOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    _buildInfoRow(
                      context,
                      'Mật khẩu',
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: TextFormField(
                          controller: mkController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập mật khẩu',
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _updateNhanVien(context),
                        child: const Text(
                          "Cập nhật"
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}