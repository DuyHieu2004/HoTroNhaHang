import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/models/MonAn.dart';
import 'package:doan_nhom_cuoiky/models/ChiTietGoiMon.dart';
import 'package:doan_nhom_cuoiky/services/MonAnService.dart';

class SelectDishesScreen extends StatefulWidget {
  final List<ChiTietGoiMon> initialSelectedDishes;

  const SelectDishesScreen({Key? key, required this.initialSelectedDishes})
    : super(key: key);

  @override
  _SelectDishesScreenState createState() => _SelectDishesScreenState();
}

class _SelectDishesScreenState extends State<SelectDishesScreen> {
  final MonAnService _monAnService = MonAnService();
  final Map<MonAn, int> _cartItem ={};

  @override
  void initState() {
    super.initState();

    for(var ctgm in widget.initialSelectedDishes){
      _cartItem[ctgm.getMonAn!] = ctgm.getSoLuong!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn món ăn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              List<ChiTietGoiMon> result = [];
              for(var entry in _cartItem.entries){
                int soLuong = entry.value;
                if(soLuong > 0){
                  ChiTietGoiMon ctgm = ChiTietGoiMon(monAn: entry.key, soLuong: soLuong);
                  result.add(ctgm);
                }
              }
              Navigator.pop(context, result);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MonAn>>(
        stream: _monAnService.getAllMonAn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải món ăn: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Không có món ăn nào trong thực đơn.'),
            );
          }

          final dishes = snapshot.data!;

          // Update _monAnMap with new dishes from the stream



          return ListView.builder(
            itemCount: dishes.length,
            itemBuilder: (context, index) {
              final monAn = dishes[index];
              int currentQuantity = (monAn != null) ?
                (_cartItem[monAn] ?? 0) : 0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(
                              monAn.getHinhAnh != null &&
                                      monAn.getHinhAnh!.isNotEmpty
                                  ? monAn.getHinhAnh!
                                  : 'https://via.placeholder.com/150',
                            ), // Placeholder
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monAn.getTen ?? 'Món không tên',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${monAn.getGiaBan?.toStringAsFixed(0) ?? '0'} VND',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (monAn != null) {
                                setState(() {
                                  int qty = _cartItem[monAn] ?? 0;
                                  if (qty > 0) {
                                    _cartItem[monAn] = qty - 1;
                                  }

                                });
                              }
                            },
                          ),
                          Text(
                            currentQuantity.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              if (monAn != null) {
                                setState(() {
                                  int qty = _cartItem[monAn] ?? 0;
                                  _cartItem[monAn] = qty + 1;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
