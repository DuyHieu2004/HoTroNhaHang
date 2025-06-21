// screens/GoiMonScreen.dart
import 'package:doan_nhom_cuoiky/screens/DetailBanAnScreen.dart';
import 'package:flutter/material.dart';
import 'package:doan_nhom_cuoiky/models/Ban.dart';
import 'package:provider/provider.dart';
import 'package:doan_nhom_cuoiky/providers/BanProvider.dart';

class GoiMonScreen extends StatefulWidget {
  const GoiMonScreen({super.key});

  @override
  State<GoiMonScreen> createState() => _GoiMonScreenState();
}

class _GoiMonScreenState extends State<GoiMonScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterTables(
        _searchController.text,
        Provider.of<BanProvider>(context, listen: false).bans,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTables(String query, List<Ban> allBansFromProvider) {
    setState(() {
      if (query.isEmpty) {
      } else {}
    });
  }

  Color _getTableColor(String? trangThai) {
    switch (trangThai) {
      case "Đã đặt":
        return Colors.blue.shade200;
      case "Đang phục vụ":
        return Colors.red.shade200;
      case "Trống":
        return Colors.green.shade200;
      case "Chờ đến":
        return Colors.green.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Widget _buildStatusLegend(String text, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildTableCard(Ban ban) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailBanAnScreen(selectedBan: ban),
          ),
        );
      },
      child: Card(
        color: _getTableColor(ban.trangThai),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                ban.ma ?? 'N/A',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.table_bar,
                size: 30,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 16),
                  SizedBox(width: 4,),
                  Text(
                    '${ban.sucChua ?? '0'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.table_bar, color: color, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gọi món'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<BanProvider>(
              builder: (context, banProvider, child) {
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bàn...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      onPressed: () {
                        _filterTables(_searchController.text, banProvider.bans);
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (query) {
                    _filterTables(query, banProvider.bans);
                  },
                  onSubmitted: (query) {
                    _filterTables(query, banProvider.bans);
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusLegend('Trống', Colors.green),
                _buildStatusLegend('Đang phục vụ', Colors.red),
                _buildStatusLegend('Đã đặt', Colors.blue),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Consumer<BanProvider>(
                builder: (context, banProvider, child) {
                  final List<Ban> allBans = banProvider.bans;
                  final List<Ban> bansToDisplay;

                  if (_searchController.text.isEmpty) {
                    bansToDisplay = allBans;
                  } else {
                    bansToDisplay =
                        allBans.where((ban) {
                          return (ban.ma != null &&
                                  ban.ma!.toLowerCase().contains(
                                    _searchController.text.toLowerCase(),
                                  )) ||
                              (ban.viTri != null &&
                                  ban.viTri!.toLowerCase().contains(
                                    _searchController.text.toLowerCase(),
                                  )) ||
                              (ban.trangThai != null &&
                                  ban.trangThai!.toLowerCase().contains(
                                    _searchController.text.toLowerCase(),
                                  ));
                        }).toList();
                  }

                  if (allBans.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (bansToDisplay.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy bàn nào phù hợp.'),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: bansToDisplay.length,
                    itemBuilder: (context, index) {
                      Ban ban = bansToDisplay[index];
                      return _buildTableCard(ban);
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: const Text(
                'Thống kê bàn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(color: Colors.grey),
            Consumer<BanProvider>(
              builder: (context, banProvider, child) {
                final List<Ban> allBans = banProvider.bans;
                final dangPhucVuCount =
                    allBans
                        .where((ban) => ban.trangThai == "Đang phục vụ")
                        .length;
                final daDatCount =
                    allBans.where((ban) => ban.trangThai == "Đã đặt").length;
                final trongCount =
                    allBans.where((ban) => ban.trangThai == "Trống").length;

                return Column(
                  children: [
                    _buildStatisticRow('Đang phục vụ', dangPhucVuCount, Colors.red,),
                    _buildStatisticRow('Đã đặt', daDatCount, Colors.blue),
                    _buildStatisticRow('Trống', trongCount, Colors.green),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
