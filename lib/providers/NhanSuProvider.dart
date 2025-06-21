import 'dart:async';

import 'package:doan_nhom_cuoiky/models/NhanVien.dart';
import 'package:doan_nhom_cuoiky/services/NhanSuService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class NhanSuProvider extends ChangeNotifier {
  List<NhanVien> _nhanSu = [];
  final NhanSuService _nhanSuService = NhanSuService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sử dụng BroadcastStreamController để quản lý stream NhanVien
  // Đây là stream chính mà UI sẽ lắng nghe

  final BehaviorSubject<NhanVien?> _currentNhanVienController =
  BehaviorSubject<NhanVien?>(); // Không cần .broadcast() vì BehaviorSubject đã là broadcast
  Stream<NhanVien?> get currentNhanVienStream => _currentNhanVienController.stream;

  NhanVien? _currentNhanVien;
  NhanVien? get currentNhanVien => _currentNhanVien;

  // Subscription để lắng nghe thay đổi của authState
  StreamSubscription<User?>? _authStateSubscription;
  // Subscription để lắng nghe stream NhanVien từ Firestore
  StreamSubscription<NhanVien?>? _nhanVienStreamSubscription;


  NhanSuProvider() {
    _loadNhanSu(); // Có lẽ bạn muốn gọi hàm này một lần khi provider được khởi tạo
    _listenToAuthAndNhanVienChanges(); // Thay thế _ListenToCurrentChangeNhanVien
  }

  // Đảm bảo dispose các stream khi Provider không còn được sử dụng
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _nhanVienStreamSubscription?.cancel();
    _currentNhanVienController.close();
    super.dispose();
  }

  Future<void> _loadNhanSu() async {
    _nhanSu = await _nhanSuService.getNhanSu();
    notifyListeners();
  }

  void _listenToAuthAndNhanVienChanges() {
    debugPrint('NhanSuProvider: _listenToAuthAndNhanVienChanges called.');
    _authStateSubscription = _auth.authStateChanges().listen(
          (User? user) {
        debugPrint('NhanSuProvider: Auth State Changed. User ID: ${user?.uid ?? 'null'}');
        // Hủy subscription cũ nếu có để tránh listener rác
        _nhanVienStreamSubscription?.cancel();
        _nhanVienStreamSubscription = null; // Đặt về null để đảm bảo không có listener nào còn sót

        if (user != null) {
          debugPrint('NhanSuProvider: User logged in, listening to NhanVien stream for authUid: ${user.uid}');
          _nhanVienStreamSubscription =
              _nhanSuService.getNhanVienByAuthUid(user.uid).listen(
                    (NhanVien? nhanVien) {
                  debugPrint('NhanSuProvider: NhanVien Stream received data. NhanVien ID: ${nhanVien?.id ?? 'null'}, Ten: ${nhanVien?.ten ?? 'null'}');
                  if (nhanVien != null) {
                    _currentNhanVien = nhanVien;
                    _currentNhanVienController.add(_currentNhanVien);
                    notifyListeners();
                    debugPrint('NhanSuProvider: _currentNhanVien updated and listeners notified.');
                  } else {
                    debugPrint('NhanSuProvider: NhanVien Stream received NULL data. User might not have a linked NhanVien profile.');
                    _currentNhanVien = null; // Quan trọng: nếu không tìm thấy, set về null
                    _currentNhanVienController.add(null);
                    notifyListeners();
                  }
                },
                onError: (error) {
                  debugPrint("NhanSuProvider: NhanVien Stream ERROR: $error");
                  _currentNhanVien = null;
                  _currentNhanVienController.addError(error);
                  notifyListeners();
                },
                onDone: () {
                  debugPrint('NhanSuProvider: NhanVien Stream DONE.');
                },
                cancelOnError: false, // Để stream không bị cancel nếu có lỗi tạm thời
              );
        } else {
          debugPrint('NhanSuProvider: User logged out. Setting _currentNhanVien to null and adding to controller.');
          _currentNhanVien = null;
          _currentNhanVienController.add(null);
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint("NhanSuProvider: Auth State Changes ERROR: $error");
      },
      onDone: () {
        debugPrint('NhanSuProvider: Auth State Changes DONE.');
      },
    );
  }

  List<NhanVien> get nhanSu => _nhanSu;

  Future<void> addNhanVien(NhanVien nhanVien) async {
    await _nhanSuService.addNhanSu(nhanVien);
    await _loadNhanSu();
  }

  Future<void> updateNhanVien(NhanVien nhanVien) async {
    await _nhanSuService.updateNhanSu(nhanVien);
    await _loadNhanSu();
  }

  Future<void> deleteNhanVien(NhanVien nv) async {
    await _nhanSuService.deleteNhanSu(nv);
    await _loadNhanSu();
  }

  Future<bool> checkNhanVienExists(String ma) async {
    return _nhanSu.any((nv) => nv.ma == ma);
  }

String getMaNhanVien() {
  try {
    if (_nhanSu.isNotEmpty) {
      int maxNumber = 0;
      for (NhanVien nv in _nhanSu) {
        if (nv.ma != null) {
          String so = nv.ma!.replaceAll(RegExp(r'\D'), '');
          if (so.isNotEmpty) {
            int currentNumber = int.parse(so);
            if (currentNumber > maxNumber) {
              maxNumber = currentNumber;
            }
          }
        }
      }
      
      int nextNumber = maxNumber + 1;
      return 'NV${nextNumber.toString().padLeft(3, '0')}';
    } else {
      return 'NV001';
    }
  } catch (e) {
    return 'NV001';
  }
}



}
