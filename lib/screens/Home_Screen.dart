import 'dart:async';
import 'package:doan_nhom_cuoiky/providers/HoaDonProvider.dart';
import 'package:doan_nhom_cuoiky/providers/SettingProvider.dart';
import 'package:doan_nhom_cuoiky/screens/CancelReservationListScreen.dart';
import 'package:doan_nhom_cuoiky/screens/ChangePassword_Screen.dart';
import 'package:doan_nhom_cuoiky/screens/GoiMonScreen.dart';
import 'package:doan_nhom_cuoiky/screens/NhanSu/NhanSuScreen.dart';
import 'package:doan_nhom_cuoiky/screens/SettingScreen.dart';
import 'package:doan_nhom_cuoiky/screens/ThanhToan/ThanhToanScreen.dart';
import 'package:doan_nhom_cuoiky/screens/ThongKeScreen.dart';
import 'package:doan_nhom_cuoiky/services/HoaDonSerivice.dart';
import 'package:doan_nhom_cuoiky/utils/QuickAlertService.dart';
import 'package:doan_nhom_cuoiky/utils/RoleBaseWidget.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../models/NhanVien.dart';
import 'Info_Screen.dart';
import 'LogIn_Screen.dart';
import 'ReservationListScreen.dart';

// ignore: camel_case_types
class Home_Screen1 extends StatefulWidget {
  final NhanVien? nhanVien;
  
  // ignore: prefer_const_constructors_in_immutables
  Home_Screen1({super.key, this.nhanVien});
  
  @override
  // ignore: library_private_types_in_public_api
  _Home_Screen1State createState() => _Home_Screen1State();
}

// ignore: camel_case_types
class _Home_Screen1State extends State<Home_Screen1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<bool> _childrenVisibility = List.filled(7, false);

  int _selectedIndex = 0;
  late PageController _pageController;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _screens = [
      _homeScreenBodyContent,
      const GoiMonScreen(),
      const ThanhToanScreen(),
      Info_Screen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }


  Widget _buildDashboardIconButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onPressed,
    required Color colorText,
  }) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundColor,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: colorText, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: iconBackgroundColor,
                  radius: 12,
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to show logout confirmation dialog
  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) async {
  Completer<bool?> completer = Completer();

  QuickAlertService.showAlertCustom(
    context: context,
    title: 'Xác nhận đăng xuất',
    message: 'Bạn có chắc chắn muốn đăng xuất?',
    type: QuickAlertType.confirm,
    confirmText: 'OK',
    cancelText: 'Hủy',
    dismissible: false,
    onConfirm: () {
      completer.complete(true);
    },
    onCancel: () {
      completer.complete(false);
    },
  );

  return completer.future;
}

  // Main home screen body content
  Widget get _homeScreenBodyContent {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    final String tenNhanVien = widget.nhanVien?.ten ?? '';
    
    _childrenVisibility = List.filled(7, false);
    bool showStatsSection = false;
    
    // Set visibility based on role
    switch (widget.nhanVien?.vaiTro?.ten) {
      case "Quản lý":
        _childrenVisibility = List.filled(7, true);
        showStatsSection = true;
        break;
      case "Thu ngân":
        _childrenVisibility[0] = true;
        _childrenVisibility[1] = true;
        _childrenVisibility[2] = true;
        _childrenVisibility[3] = true;
        _childrenVisibility[6] = true;
        break;
      case "Phục vụ":
        _childrenVisibility[0] = true;
        _childrenVisibility[1] = true;
        _childrenVisibility[6] = true;
        showStatsSection = true;
        break;
      default:
        _childrenVisibility = List.filled(7, false);
        showStatsSection = false;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      controller: ScrollController(
        initialScrollOffset: 0.0,
        debugLabel: tenNhanVien,
        keepScrollOffset: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting section
          Text(
            'Xin chào, $tenNhanVien',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ngày: $formattedDate',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          // Dashboard buttons section
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth - 32;
              final itemWidth = (availableWidth / 2.2) + 22;
              const aspectRatio = 1.0;
              final itemHeight = itemWidth * aspectRatio;
              
              final children = [
                // Gọi món button
                SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: RoleBasedWidget(
                    isVisible: _childrenVisibility[0],
                    child: _buildDashboardIconButton(
                      icon: Icons.restaurant_menu,
                      label: 'Gọi món',
                      backgroundColor: Colors.green.shade100,
                      iconColor: Colors.green.shade700,
                      colorText: Color(0xFF1A1A1A),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const GoiMonScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Thanh toán button
                SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: RoleBasedWidget(
                    isVisible: _childrenVisibility[1],
                    child: _buildDashboardIconButton(
                      icon: Icons.payment,
                      label: 'Thanh toán',
                      backgroundColor: Colors.blue.shade100,
                      iconColor: Colors.blue.shade700,
                      colorText: Color(0xFF1A1A1A),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ThanhToanScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Đặt chỗ button
                SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: RoleBasedWidget(
                    isVisible: _childrenVisibility[2],
                    child: _buildDashboardIconButton(
                      icon: Icons.calendar_today,
                      label: 'Đặt chỗ',
                      backgroundColor: Colors.green,
                      iconColor: Colors.orangeAccent,
                      colorText: Color(0xFF1A1A1A),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Hủy đặt chỗ button
                SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: RoleBasedWidget(
                    isVisible: _childrenVisibility[3],
                    child: _buildDashboardIconButton(
                      icon: Icons.cancel,
                      label: 'Hủy đặt chỗ',
                      backgroundColor: Colors.red.shade100,
                      iconColor: Colors.red.shade700,
                      colorText: Color(0xFF1A1A1A),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CancelReservationListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Thống kê button
                SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: RoleBasedWidget(
                    isVisible: _childrenVisibility[4],
                    child: _buildDashboardIconButton(
                      icon: Icons.analytics,
                      label: 'Thống kê',
                      backgroundColor: Colors.yellow.shade100,
                      iconColor: Colors.yellow.shade700,
                      colorText: Color(0xFF1A1A1A),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ThongKeScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Nhân sự button
                SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: RoleBasedWidget(
                    isVisible: _childrenVisibility[5],
                    child: _buildDashboardIconButton(
                      icon: Icons.people,
                      label: 'Nhân sự',
                      backgroundColor: Colors.brown.shade50,
                      iconColor: Colors.brown.shade200,
                      colorText: Color(0xFF1A1A1A),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NhanSuScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Cài đặt button
                SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: RoleBasedWidget(
                    isVisible: _childrenVisibility[6],
                    child: _buildDashboardIconButton(
                      icon: Icons.settings,
                      label: 'Cài đặt',
                      backgroundColor: Colors.grey.shade200,
                      iconColor: Colors.grey.shade700,
                      colorText: Color(0xFF1A1A1A),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ];
              
              return Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.spaceBetween,
                children: children
                    .where(
                      (widget) =>
                          (widget).child != null &&
                          (widget.child as RoleBasedWidget).isVisible,
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),

          if (showStatsSection) ...[
            const Text(
              'Thống Kê Hôm Nay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<HoaDonProvider>(
              builder: (context, hoaDonProvider, child) {
                return Column(
                  children: [
                    Row(
                      children: [
                        // Order count statistics
                        Expanded(
                          child: StreamBuilder<int>(
                            stream: hoaDonProvider.todayOrderCountStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildStatisticItem(
                                  label: 'Đơn',
                                  value: 'Đang tải...',
                                  icon: Icons.list_alt_outlined,
                                  iconBackgroundColor: Colors.pink.shade100,
                                  iconColor: Colors.pink.shade700,
                                  onPressed: () {},
                                );
                              } else if (snapshot.hasError) {
                                return _buildStatisticItem(
                                  label: 'Đơn',
                                  value: 'Lỗi!',
                                  icon: Icons.error_outline,
                                  iconBackgroundColor: Colors.red.shade100,
                                  iconColor: Colors.red.shade700,
                                  onPressed: () {},
                                );
                              } else {
                                return _buildStatisticItem(
                                  label: 'Đơn',
                                  value: snapshot.data?.toString() ?? '0',
                                  icon: Icons.list_alt_outlined,
                                  iconBackgroundColor: Colors.pink.shade100,
                                  iconColor: Colors.pink.shade700,
                                  onPressed: () {},
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Revenue statistics
                        Expanded(
                          child: StreamBuilder<double>(
                            stream: hoaDonProvider.todayRevenueStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildStatisticItem(
                                  label: 'Doanh thu',
                                  value: 'Đang tải...',
                                  icon: Icons.list_alt_outlined,
                                  iconBackgroundColor: Colors.pink.shade100,
                                  iconColor: Colors.pink.shade700,
                                  onPressed: () {},
                                );
                              } else if (snapshot.hasError) {
                                return _buildStatisticItem(
                                  label: 'Doanh thu',
                                  value: 'Lỗi!',
                                  icon: Icons.error_outline,
                                  iconBackgroundColor: Colors.red.shade100,
                                  iconColor: Colors.red.shade700,
                                  onPressed: () {},
                                );
                              } else {
                                return _buildStatisticItem(
                                  label: 'Doanh thu',
                                  value: snapshot.data?.toString() ?? '0',
                                  icon: Icons.attach_money_outlined,
                                  iconBackgroundColor: Colors.green.shade100,
                                  iconColor: Colors.green.shade700,
                                  onPressed: () {},
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
            )

          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingProvider settingProvider = Provider.of<SettingProvider>(context);
    // Set role-based visibility
    _childrenVisibility = List.filled(7, false);
    
    switch (widget.nhanVien?.vaiTro?.ten) {
      case "Quản lý":
        _childrenVisibility = List.filled(7, true);
        break;
      case "Thu ngân":
        _childrenVisibility[0] = true;
        _childrenVisibility[1] = true;
        _childrenVisibility[2] = true;
        _childrenVisibility[3] = true;
        _childrenVisibility[6] = true;
        break;
      case "Phục vụ":
        _childrenVisibility[0] = true;
        _childrenVisibility[1] = true;
        _childrenVisibility[6] = true;
        break;
      default:
        _childrenVisibility = List.filled(7, false);
    }

    final String tenNhanVien = widget.nhanVien?.ten ?? '';
    final String? anh = widget.nhanVien?.anh;
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Quản lý nhà hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _openDrawer,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer header
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              padding: const EdgeInsets.only(
                top: 50,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: (anh != null && anh.isNotEmpty)
                            ? NetworkImage(anh) as ImageProvider
                            : const AssetImage('assets/images/default.png'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tenNhanVien,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.nhanVien?.ngayVL != null
                        ? 'Ngày vào làm: ${DateFormat('dd/MM/yyyy').format(widget.nhanVien!.ngayVL!.toDate())}'
                        : 'Ngày vào làm: Chưa cập nhật',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Drawer menu items
            RoleBasedWidget(
              isVisible: true,
              child: ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Thông tin cá nhân',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Info_Screen(),
                    ),
                  );
                },
              ),
            ),
            RoleBasedWidget(
              isVisible: true,
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.blue),
                title: const Text(
                  'Đổi mật khẩu',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ChangePassword_Screen(nhanVien: widget.nhanVien),
                    ),
                  );
                },
              ),
            ),
            const Divider(),

            // Logout button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  bool? confirmLogout = await _showLogoutConfirmationDialog(context);
                  if (confirmLogout == true) {
                    try {
                      await _auth.signOut();
                      Navigator.pushReplacement(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogIn_Screen(),
                        ),
                      );
                    } catch (e) {
                      QuickAlertService.showAlertFailure(
                        // ignore: use_build_context_synchronously
                        context,
                        'Đã xảy ra lỗi khi đăng xuất: $e',
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: settingProvider.themeMode == ThemeMode.dark
                ? Colors.grey.shade800
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, -2),
                spreadRadius: 0.5,
                blurStyle: BlurStyle.normal,
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: GNav(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 650),
            gap: 8,
            padding: const EdgeInsets.all(16),
            iconSize: 24,
            tabMargin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            rippleColor: settingProvider.themeMode == ThemeMode.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.blue.shade100,
            backgroundColor:settingProvider.themeMode == ThemeMode.dark ? Colors.grey.shade800 : Colors.white,
            color: settingProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.grey,
            activeColor: settingProvider.themeMode == ThemeMode.dark ? Colors.black : Colors.blue,
            tabBackgroundColor: settingProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.blue.shade100,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              GButton(icon: Icons.home_outlined, text: 'Trang chủ'),
              GButton(icon: Icons.restaurant_menu, text: 'Gọi món'),
              GButton(icon: Icons.payment_outlined, text: 'Thanh toán'),
              GButton(icon: Icons.person, text: 'Thông tin nhân viên'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
                _pageController.jumpToPage(_selectedIndex);
              });
            },
          ),
        ),
      ),
    );
  }
}