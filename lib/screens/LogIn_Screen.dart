import 'package:doan_nhom_cuoiky/utils/QuickAlertService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/SharedPreferencesHelper.dart';
import '../models/NhanVien.dart';
import '../services/Auth_Service.dart';
import 'Home_Screen.dart';

// ignore: camel_case_types
class LogIn_Screen extends StatefulWidget {
  const LogIn_Screen({super.key});

  @override
  State<LogIn_Screen> createState() => _LogIn_ScreenState();
}

// ignore: camel_case_types
class _LogIn_ScreenState extends State<LogIn_Screen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  bool _rememberMe = false;
  final Auth_Service _authService = Auth_Service();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {});
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng nhập với Firebase
  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    QuickAlertService.showAlertLoading(context, "Đang đăng nhập");
  
    NhanVien? loggedInNhanVien;
    String? errorMessage;

  try {
    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Thực hiện đăng nhập
    loggedInNhanVien = await _authService.signInWithEmailAndPassword(email, password);

    // Nếu đăng nhập thành công và người dùng chọn "Ghi nhớ đăng nhập"
    if (loggedInNhanVien != null && _rememberMe) {
      await SharedPreferencesHelper.saveUserEmail(email);
      await SharedPreferencesHelper.saveUserPassword(password);
      await SharedPreferencesHelper.saveUserLoggedIn(true);
    }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'Không tìm thấy người dùng với email này.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mật khẩu không đúng.';
      } else if (e.code == 'invalid-email') {
        errorMessage = "Email không hợp lệ.";
      } else {
        errorMessage = 'Có lỗi xảy ra khi đăng nhập: ${e.message}';
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      errorMessage = 'Đã xảy ra lỗi không mong muốn: $e';
    }
   
    await Future.delayed(const Duration(seconds: 2));

    // ignore: use_build_context_synchronously
    if (Navigator.of(context).canPop()) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }

    if (loggedInNhanVien != null) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => Home_Screen1(nhanVien: loggedInNhanVien),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      QuickAlertService.showAlertFailure(context, errorMessage ?? 'Đăng nhập không thành công. Vui lòng kiểm tra lại.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4C3),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/restaurant_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ScaleTransition(
                      scale: _logoAnimation,
                      child: const Icon(
                        Icons.restaurant_outlined,
                        size: 80.0,
                        color:  Color(
                          0xFF7CB342,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08),
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Color(0xFF558B2F)),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Color(0xFF558B2F)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF8BC34A),
                          ), // Viền màu xanh lá
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF689F38),
                            width: 2.0,
                          ), // Viền đậm hơn khi focus
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF558B2F),
                        ), // Đổi icon thành email
                        filled: true,
                        fillColor: Colors.white.withOpacity(
                          0.8,
                        ), // Nền trắng mờ
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!RegExp(
                          r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(value)) {
                          return 'Email không hợp lệ.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: Color(0xFF558B2F)),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        labelStyle: const TextStyle(color: Color(0xFF558B2F)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF8BC34A),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF689F38),
                            width: 2.0,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF558B2F),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Color(0xFF558B2F),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF689F38),
                        ),
                        const Text(
                          'Ghi nhớ đăng nhập',
                          style: TextStyle(color: Color(0xFF558B2F)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signInWithEmailAndPassword(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: const Color(
                          0xFF689F38,
                        ), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
