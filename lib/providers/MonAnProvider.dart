import 'dart:async';
import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/models/MonAn.dart';
import 'package:doan_nhom_cuoiky/models/ThucDon.dart';
import 'package:doan_nhom_cuoiky/services/MonAnService.dart';
import 'package:rxdart/rxdart.dart';

class MonAnProvider extends ChangeNotifier {
  final MonAnService _monAnService = MonAnService();

  // Sử dụng BehaviorSubject với broadcast để có thể listen từ nhiều nơi
  final BehaviorSubject<List<ThucDon>> _categoriesController =
  BehaviorSubject<List<ThucDon>>.seeded([]);

  // Tạo broadcast stream để có thể listen từ nhiều widget
  Stream<List<ThucDon>> get categoriesStream =>
      _categoriesController.stream.asBroadcastStream();

  ThucDon? _selectedCategory;
  ThucDon? get selectedCategory => _selectedCategory;

  // BehaviorSubject cho danh sách món ăn đầy đủ của danh mục hiện tại
  final BehaviorSubject<List<MonAn>> _currentMonAnListController =
  BehaviorSubject<List<MonAn>>.seeded([]);

  Stream<List<MonAn>> get currentMonAnListStream =>
      _currentMonAnListController.stream.asBroadcastStream();

  // BehaviorSubject để quản lý tìm kiếm
  final BehaviorSubject<String> _searchQueryController =
  BehaviorSubject<String>.seeded('');

  String get searchQuery => _searchQueryController.value;

  // Stream tổng hợp cho danh sách món ăn đã lọc
  late Stream<List<MonAn>> _filteredMonAnListStream;
  Stream<List<MonAn>> get filteredMonAnListStream => _filteredMonAnListStream;

  // Subscriptions để quản lý
  StreamSubscription<List<ThucDon>>? _categoriesListenerSubscription;
  StreamSubscription<List<MonAn>>? _categoryMonAnSubscription;

  // Giỏ hàng
  final Map<MonAn, int> _cartItems = <MonAn, int>{};
  Map<MonAn, int> get cartItems => Map.unmodifiable(_cartItems);

  int get totalCartItems => _cartItems.values.fold(0, (sum, quantity) => sum + quantity);

  // Trạng thái loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Thông báo lỗi
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MonAnProvider() {
    _initStreams();
    _loadCategories();
    _setupCategoriesListener();
  }

  void _initStreams() {
    // Kết hợp stream của món ăn hiện tại và stream của truy vấn tìm kiếm
    _filteredMonAnListStream = Rx.combineLatest2(
      _currentMonAnListController.stream,
      _searchQueryController.stream.debounceTime(
          const Duration(milliseconds: 300)
      ),
          (List<MonAn> monAnList, String query) {
        if (query.isEmpty) {
          return monAnList;
        } else {
          final lowerCaseQuery = query.toLowerCase();
          return monAnList.where((monAn) {
            return monAn.getTen.toLowerCase().contains(lowerCaseQuery);
          }).toList();
        }
      },
    ).distinct().asBroadcastStream(); // Thêm asBroadcastStream()
  }

  void _setupCategoriesListener() {
    _categoriesListenerSubscription = _categoriesController.stream.listen(
            (categories) {
          if (categories.isNotEmpty && _selectedCategory == null) {
            setSelectedCategory(categories.first);
          }
        },
        onError: (error) {
          _setError("Lỗi khi lắng nghe danh mục: $error");
        }
    );
  }

  Future<void> _loadCategories() async {
    try {
      _setLoading(true);
      _clearError();

      List<ThucDon> categories = await _monAnService.getAllThucDonCategories();

      if (!_categoriesController.isClosed) {
        _categoriesController.add(categories);
      }
    } catch (e) {
      _setError('Lỗi khi tải danh mục: $e');
      if (!_categoriesController.isClosed) {
        _categoriesController.addError(e);
      }
    } finally {
      _setLoading(false);
    }
  }

  void setSelectedCategory(ThucDon category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();

      _categoryMonAnSubscription?.cancel();
      _loadMonAnByCategory(category);
    }
  }

  void _loadMonAnByCategory(ThucDon category) {
    _categoryMonAnSubscription = _monAnService
        .getMonAnByThucDonStream(category.getMa)
        .listen(
          (monAnList) {
        if (!_currentMonAnListController.isClosed) {
          _currentMonAnListController.add(monAnList);
        }
      },
      onError: (error) {
        _setError('Lỗi khi tải món ăn: $error');
        if (!_currentMonAnListController.isClosed) {
          _currentMonAnListController.addError(error);
        }
      },
    );
  }

  void updateSearchQuery(String query) {
    if (!_searchQueryController.isClosed && _searchQueryController.value != query) {
      _searchQueryController.add(query);
    }
  }

  // Phương thức để refresh dữ liệu
  Future<void> refresh() async {
    await _loadCategories();
    if (_selectedCategory != null) {
      _loadMonAnByCategory(_selectedCategory!);
    }
  }

  // Quản lý giỏ hàng
  void addToCart(MonAn monAn) {
    if (_cartItems.containsKey(monAn)) {
      _cartItems[monAn] = _cartItems[monAn]! + 1;
    } else {
      _cartItems[monAn] = 1;
    }
    notifyListeners();
  }

  void removeFromCart(MonAn monAn) {
    if (_cartItems.containsKey(monAn)) {
      if (_cartItems[monAn]! > 1) {
        _cartItems[monAn] = _cartItems[monAn]! - 1;
      } else {
        _cartItems.remove(monAn);
      }
      notifyListeners();
    }
  }

  void updateCartItemQuantity(MonAn monAn, int quantity) {
    if (quantity <= 0) {
      _cartItems.remove(monAn);
    } else {
      _cartItems[monAn] = quantity;
    }
    notifyListeners();
  }

  void updateCartItems(Map<MonAn, int> newCart) {
    _cartItems.clear();
    _cartItems.addAll(newCart);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Phương thức tiện ích để quản lý trạng thái
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
    debugPrint(error);
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Phương thức để lấy thông tin giỏ hàng
  double get totalCartPrice {
    return _cartItems.entries.fold(0.0, (total, entry) {
      final monAn = entry.key;
      final quantity = entry.value;
      return total + (monAn.getGiaBan ?? 0.0) * quantity;
    });
  }

  List<MonAn> get cartMonAnList => _cartItems.keys.toList();

  int getQuantityInCart(MonAn monAn) => _cartItems[monAn] ?? 0;

  bool isInCart(MonAn monAn) => _cartItems.containsKey(monAn);

  @override
  void dispose() {
    // Hủy tất cả subscriptions
    _categoryMonAnSubscription?.cancel();
    _categoriesListenerSubscription?.cancel();

    // Đóng tất cả controllers
    _categoriesController.close();
    _currentMonAnListController.close();
    _searchQueryController.close();

    super.dispose();
  }
}