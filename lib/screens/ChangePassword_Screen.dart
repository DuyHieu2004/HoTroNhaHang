import 'package:doan_nhom_cuoiky/services/NhanSuService.dart';
import 'package:doan_nhom_cuoiky/services/SharedPreferencesHelper.dart';
import 'package:doan_nhom_cuoiky/utils/QuickAlertService.dart';
import 'package:doan_nhom_cuoiky/utils/Toast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doan_nhom_cuoiky/models/NhanVien.dart';

class ChangePassword_Screen extends StatefulWidget {
  final NhanVien? nhanVien;
  const ChangePassword_Screen({super.key, required this.nhanVien});

  @override
  _ChangePassword_ScreenState createState() => _ChangePassword_ScreenState();
}

class _ChangePassword_ScreenState extends State<ChangePassword_Screen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;
  bool _isUpdating = false;

  final NhanSuService _nhanVienService = NhanSuService();

  AnimationController? _buttonAnimationController;
  Animation<double>? _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _buttonAnimationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _buttonAnimationController?.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống.';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Xác nhận mật khẩu không được để trống.';
    }
    if (value != _newPasswordController.text) {
      return 'Mật khẩu xác nhận không khớp.';
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.email == null) {
      QuickAlertService.showAlertFailure(
        context,
        'Bạn cần đăng nhập để đổi mật khẩu.',
      );
      await Future.delayed(const Duration(seconds: 2));
      return;
    }

    setState(() {
      _isUpdating = true;
      _buttonAnimationController?.forward();
    });

    try {
      // Xác thực lại tài khoản
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: _currentPasswordController.text,
      );
      await currentUser.reauthenticateWithCredential(credential);

      final String newPassword = _newPasswordController.text;

      if (widget.nhanVien?.id == null) {
        ToastUtils.showError('Đổi mật khẩu thất bại. Vui lòng thử lại.');
        setState(() {
          _isUpdating = false;
          _buttonAnimationController?.reverse();
        });
        return;
      }

      // Đổi mật khẩu trên Firebase Auth
      await _nhanVienService.updateFirebaseAuthPassword(newPassword);

      // Đổi mật khẩu trên Firestore
      try {
        await _nhanVienService.updateNhanVienPasswordInFirestore(
          widget.nhanVien!.id!,
          newPassword,
        );
      } catch (e) {
        // Nếu lỗi Firestore, cảnh báo nhưng không rollback Auth
        QuickAlertService.showAlertWarning(
          context,
          "Đổi mật khẩu đăng nhập thành công, nhưng chưa cập nhật dữ liệu hệ thống. Vui lòng thử lại hoặc liên hệ quản trị viên.",
        );
        await Future.delayed(const Duration(seconds: 2));
      }

      // Cập nhật SharedPreferences
      await SharedPreferencesHelper.saveUserEmail(currentUser.email!);
     // await SharedPreferencesHelper.saveUserPassword(newPassword);
      await SharedPreferencesHelper.saveUserLoggedIn(true);

      QuickAlertService.showAlertSuccess(context, "Đổi mật khẩu thành công!");
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
    } catch (e) {
      QuickAlertService.showAlertFailure(
        context,
        "Đổi mật khẩu thất bại: ${e is FirebaseAuthException ? e.message : e.toString()}",
      );
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      setState(() {
        _isUpdating = false;
        _buttonAnimationController?.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đổi Mật Khẩu'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                validator: _validatePassword,
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                validator: _validatePassword,
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _confirmNewPasswordController,
                obscureText: _obscureConfirmNewPassword,
                decoration: InputDecoration(
                  labelText: 'Nhập lại mật khẩu mới',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmNewPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmNewPassword =
                            !_obscureConfirmNewPassword;
                      });
                    },
                  ),
                ),
                validator: _validateConfirmPassword,
              ),
              SizedBox(height: 30.0),
              ScaleTransition(
                scale: _buttonScaleAnimation!,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 3,
                  ),
                  child:
                      _isUpdating
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            'Cập nhật',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
