import 'package:doan_nhom_cuoiky/providers/MonAnProvider.dart';
import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/models/MonAn.dart';
import 'package:doan_nhom_cuoiky/models/ThucDon.dart';
import 'package:doan_nhom_cuoiky/models/Ban.dart';
import 'package:doan_nhom_cuoiky/services/MonAnService.dart';
import 'package:doan_nhom_cuoiky/screens/ChiTietGoiMonScreen.dart';

class DetailBanAnScreen extends StatefulWidget {
  final Ban selectedBan;

  const DetailBanAnScreen({super.key, required this.selectedBan});

  @override
  State<DetailBanAnScreen> createState() => _DetailBanAnScreenState();
}

class _DetailBanAnScreenState extends State<DetailBanAnScreen> {
  final MonAnService _monAnService = MonAnService();
  late Future<List<ThucDon>> _categoriesFuture;


  List<MonAn> _currentMonAnList = [];
  ThucDon? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  List<MonAn> _filteredMonAnList = [];
  Map<MonAn, int> _cartItems = {};

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _monAnService.getAllThucDonCategories();
    _searchController.addListener(_filterMonAnList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMonAnList);
    _searchController.dispose();
    super.dispose();
  }

  void _loadMonAnByCategory(String? maThucDon) async {
    if (maThucDon == null) {
      setState(() {
        _currentMonAnList = [];
        _filteredMonAnList = [];
      });
      return;
    }
    List<MonAn> monAnList = await _monAnService.getMonAnByThucDon(maThucDon);
    setState(() {
      _currentMonAnList = monAnList;
      _filterMonAnList();
    });
  }

  void _filterMonAnList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMonAnList = _currentMonAnList.where((monAn) {
        return monAn.getTen.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addToCart(MonAn monAn) {
    setState(() {
      _cartItems.update(monAn, (value) => value + 1, ifAbsent: () => 1);
    });
  }

  void _removeFromCart(MonAn monAn) {
    setState(() {
      if (_cartItems.containsKey(monAn)) {
        if (_cartItems[monAn]! > 1) {
          _cartItems[monAn] = _cartItems[monAn]! - 1;
        } else {
          _cartItems.remove(monAn);
        }
      }
    });
  }

  int get _totalCartItems {
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.selectedBan.ma ?? 'Bàn'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          FutureBuilder<List<ThucDon>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có danh mục nào.'));
              } else {
                List<ThucDon> categories = snapshot.data!;
                if (_selectedCategory == null && categories.isNotEmpty) {
                  _selectedCategory = categories.first;
                  _loadMonAnByCategory(_selectedCategory!.getMa);
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: categories.map((category) {
                      bool isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(category.getTen),
                          selected: isSelected,
                          selectedColor: Colors.amber.shade700,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.amber.shade700 : Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategory = category;
                                _loadMonAnByCategory(category.getMa);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
          Expanded(
            child: _filteredMonAnList.isEmpty && _searchController.text.isNotEmpty
                ? const Center(child: Text('Không tìm thấy món ăn nào.'))
                : _filteredMonAnList.isEmpty && _selectedCategory != null
                ? const Center(child: Text('Danh mục này hiện không có món ăn nào.'))
                : ListView.builder(
              itemCount: _filteredMonAnList.length,
              itemBuilder: (context, index) {
                final monAn = _filteredMonAnList[index];
                final int quantityInCart = _cartItems[monAn] ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.shade100,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: (monAn.getHinhAnh != null && monAn.getHinhAnh!.isNotEmpty)
                                  ? NetworkImage(monAn.getHinhAnh!)
                                  : const AssetImage('assets/placeholder_food.png') as ImageProvider,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                monAn.getTen,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '${monAn.getGiaBan?.toStringAsFixed(0)} VNĐ',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            if (quantityInCart > 0) ...[
                              InkWell(
                                onTap: () => _removeFromCart(monAn),
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.remove, color: Colors.white, size: 20),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '$quantityInCart',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            InkWell(
                              onTap: () => _addToCart(monAn),
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _totalCartItems > 0
          ? Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton.extended(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.amber.shade700, width: 2),
            ),
            onPressed: () async {
              final updatedCart = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChiTietGoiMonScreen(
                    cartItems: _cartItems,
                    selectedBan: widget.selectedBan,
                  ),
                ),
              );
              if (updatedCart != null && updatedCart is Map<MonAn, int>) {
                setState(() {
                  _cartItems = updatedCart;
                });
              }
            },
            label: const Text('Xem chi tiết gọi món', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            backgroundColor: Colors.amber.shade700,
            elevation: 4,
          ),
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              child: Text(
                '$_totalCartItems',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      )
          : null,
    );
  }
}