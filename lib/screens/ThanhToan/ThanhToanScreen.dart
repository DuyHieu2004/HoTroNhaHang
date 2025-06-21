import 'package:doan_nhom_cuoiky/models/DonGoiMon.dart';
import 'package:doan_nhom_cuoiky/providers/DonGoiMonProvider.dart';
import 'package:doan_nhom_cuoiky/screens/ThanhToan/ChiTietThanhToanScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThanhToanScreen extends StatefulWidget {
  const ThanhToanScreen({super.key});

  @override
  _ThanhToanScreenState createState() => _ThanhToanScreenState();
}

class _ThanhToanScreenState extends State<ThanhToanScreen> {
  String searchQuery = '';
  bool isRefreshing = false;
  Future<List<DonGoiMon>>? _donGoiMonFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });

    final provider = Provider.of<DonGoiMonProvider>(context, listen: false);

    _donGoiMonFuture = provider.layDonDangPhucVu();

    setState(() {
      isRefreshing = false;
    });
  }

  void _filterTables(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh Toán')),
      body: Consumer<DonGoiMonProvider>(
        builder: (context, donGoiMonProvider, child) {
          return FutureBuilder<List<DonGoiMon>>(
            future: _donGoiMonFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: ${snapshot.error}'),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Không có bàn nào để thanh toán'),
                );
              }

              final allTables = snapshot.data!;

              for (var element in allTables) {
                element.trangThai ??= 'Chưa xác định';
              }

              final filteredTables =
                  searchQuery.isEmpty
                      ? allTables
                      : allTables.where((table) {
                        final viTri = table.maBan?.viTri ?? '';
                        final tableName = 'Bàn $viTri';
                        return tableName.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        );
                      }).toList();

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm bàn',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: _filterTables,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        isRefreshing
                            ? const Center(child: CircularProgressIndicator())
                            : RefreshIndicator(
                              onRefresh: _refreshData,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredTables.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 1.1,
                                    ),
                                itemBuilder: (_, index) {
                                  final order = filteredTables[index];
                                  final tableName =
                                      'Bàn ${filteredTables[index].maBan?.viTri!}';
                                  final status = order.trangThai;
                                  final people =
                                      order.maBan?.sucChua;
                                  return _buildTableCard(
                                    context,
                                    order,
                                    tableName,
                                    status!,
                                    people.toString(),
                                  );
                                },
                              ),
                            ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTableCard(
    BuildContext context,
    dynamic order,
    String tableName,
    String status,
    String people,
  ) {
    return Card(
      color: Theme.of(context).cardTheme.color,
      shadowColor: Colors.blueGrey,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChiTietThanhToanScreen(order: order),
            ),
          ).then((_) => _refreshData());
        },
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tableName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    people.isEmpty ? "Không xác định" : '$people khách',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Xem chi tiết',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
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
