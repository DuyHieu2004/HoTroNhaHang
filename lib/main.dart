import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan_nhom_cuoiky/models/NhanVien.dart';
import 'package:doan_nhom_cuoiky/providers/BanProvider.dart';
import 'package:doan_nhom_cuoiky/providers/ChiTietDonGoiMonProvider.dart';
import 'package:doan_nhom_cuoiky/providers/DonDatChoProvider.dart';
import 'package:doan_nhom_cuoiky/providers/DonGoiMonProvider.dart';
import 'package:doan_nhom_cuoiky/providers/KhachHangProvider.dart';
import 'package:doan_nhom_cuoiky/providers/MonAnProvider.dart';
import 'package:doan_nhom_cuoiky/providers/NhanSuProvider.dart';
import 'package:doan_nhom_cuoiky/providers/PhieuTamUngProvider.dart';
import 'package:doan_nhom_cuoiky/providers/SettingProvider.dart';
import 'package:doan_nhom_cuoiky/providers/HoaDonProvider.dart';
import 'package:doan_nhom_cuoiky/screens/GoiMonScreen.dart';
import 'package:doan_nhom_cuoiky/screens/Home_Screen.dart';
import 'package:doan_nhom_cuoiky/screens/LogIn_Screen.dart';
import 'package:doan_nhom_cuoiky/screens/NhanSu/NhanSuScreen.dart';
import 'package:doan_nhom_cuoiky/screens/ThanhToan/ThanhToanScreen.dart';
import 'package:doan_nhom_cuoiky/services/Auth_Service.dart';
import 'package:doan_nhom_cuoiky/services/BanService.dart';
import 'package:doan_nhom_cuoiky/services/DonGoiMonService.dart';
import 'package:doan_nhom_cuoiky/services/NotificationService.dart';
import 'package:doan_nhom_cuoiky/services/SharedPreferencesHelper.dart';
import 'package:doan_nhom_cuoiky/utils/AppTheme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/DonGoiMon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService().init();
  // await initializeService();
  String? email = await SharedPreferencesHelper.getUserEmail();
  String? password = await SharedPreferencesHelper.getUserPassword();
  bool? isLoggedIn = await SharedPreferencesHelper.getUserLoggedIn();

  NhanVien? loggedInNhanVien;
  if (isLoggedIn != null && isLoggedIn && email != null && password != null) {
    Auth_Service authService = Auth_Service();
    loggedInNhanVien = await authService.signInWithEmailAndPassword(email, password);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider(create: (_) => NhanSuProvider()),
        ChangeNotifierProvider(create: (_) => HoaDonProvider()),
        ChangeNotifierProvider(create: (_) => DonGoiMonProvider()),
        ChangeNotifierProvider(create: (_) => ChiTietDonGoiMonProvider()),
        ChangeNotifierProvider(create: (_) => BanProvider()),
        ChangeNotifierProvider(create: (_) => DonDatChoProvider()),
        ChangeNotifierProvider(create: (_) => KhachHangProvider()),
        ChangeNotifierProvider(create: (_) => PhieuTamUngProvider()),
        ChangeNotifierProvider(create: (_) => MonAnProvider())
      ],
      child: MyApp(loggedInNhanVien: loggedInNhanVien,),
    ),
  );
}

class MyApp extends StatelessWidget {
  final NhanVien? loggedInNhanVien;
  
  const MyApp({super.key, this.loggedInNhanVien});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(
      builder: (context, settingProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quản lý nhà hàng',
          theme: AppTheme.lightTheme(settingProvider.fontFamily),
          darkTheme: AppTheme.darkTheme(settingProvider.fontFamily),
          themeMode: settingProvider.themeMode,
          home: loggedInNhanVien != null ? Home_Screen1(nhanVien: loggedInNhanVien!) : const LogIn_Screen(),
          routes: {
            '/login': (context) => const LogIn_Screen(),
            '/goiMon': (context) => const GoiMonScreen(),
            '/nhanSu': (context) => const NhanSuScreen(),
            '/thanhToan': (context) => const ThanhToanScreen(),
          },
        );
      },
    );
  }
}