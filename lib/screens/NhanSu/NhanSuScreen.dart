import 'package:doan_nhom_cuoiky/models/NhanVien.dart';
import 'package:doan_nhom_cuoiky/providers/NhanSuProvider.dart';
import 'package:doan_nhom_cuoiky/providers/SettingProvider.dart';
import 'package:doan_nhom_cuoiky/screens/NhanSu/AddNhanSuScreen.dart';
import 'package:doan_nhom_cuoiky/screens/NhanSu/DetailNhanSuScreen.dart';
import 'package:doan_nhom_cuoiky/utils/QuickAlertService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NhanSuScreen extends StatefulWidget {
  const NhanSuScreen({super.key});

  @override
  State<NhanSuScreen> createState() => _NhanSuScreenState();
}

class _NhanSuScreenState extends State<NhanSuScreen> {
  TextEditingController search = TextEditingController();
  bool _sortAscending = true;

  String get _searchText => search.text.toLowerCase();

  @override
  Widget build(BuildContext context) {
    return Consumer<NhanSuProvider>(
      builder: (context, nhanSuProvider, child) {
        // Lọc danh sách theo search
        List<NhanVien> filteredList = nhanSuProvider.nhanSu.where((nv) {
          return _searchText.isEmpty ||
              (nv.ma?.toLowerCase().contains(_searchText) ?? false) ||
              (nv.ten?.toLowerCase().contains(_searchText) ?? false);
        }).toList();

        // Sắp xếp
        filteredList.sort((a, b) {
          if (_sortAscending) {
            return (a.ten ?? '').compareTo(b.ten ?? '');
          } else {
            return (b.ten ?? '').compareTo(a.ten ?? '');
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Text("Nhân sự"),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNhanSuScreen(),
                    ),
                  );
                  if (result == true) {
                    // Provider đã notifyListeners, chỉ cần setState để rebuild
                    setState(() {});
                  }
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: Column(
              children: [
                TextField(
                  controller: search,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Tìm kiếm nhân viên",
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Danh sách nhân sự",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                      icon: Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(child: Text('Không có nhân viên nào'))
                      : ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) => NhanSuItemCard(
                            nv: filteredList[index],
                            onRefresh: () => setState(() {}),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NhanSuItemCard extends StatelessWidget {
  final NhanVien? nv;
  final VoidCallback onRefresh;
  const NhanSuItemCard({super.key, required this.nv, required this.onRefresh});

  void _showDetailDialog(BuildContext context) {
    if (nv == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {                
        return AlertDialog(
          title: const Text('Thông tin nhân viên'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    (
                          (nv?.anh != null && nv!.anh!.isNotEmpty)
                        ? NetworkImage(nv!.anh!)
                            :
                        AssetImage('assets/images/default.png')
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(context, 'Mã nhân viên:', nv?.ma ?? 'Không có'),
                _buildInfoRow(context, 'Họ và tên:', nv?.ten ?? 'Không có'),
                _buildInfoRow(context, 'Số điện thoại:', nv?.SDT ?? 'Không có'),
                _buildInfoRow(context, 'CCCD:', nv?.CCCD ?? 'Không có'),
                _buildInfoRow(context, 'Tài khoản:', nv?.tk ?? 'Không có'),
                _buildInfoRow(
                  context,
                  'Vai trò:',
                  nv?.vaiTro?.toString() ?? 'Không có',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng', style: TextStyle(color: SettingProvider().themeMode == ThemeMode.dark ? Colors.amber: Theme.of(context).colorScheme.primary),),
            ),
            TextButton(
              onPressed: () async {
                if (nv?.ma == null) return;

                QuickAlertService.showAlertLoading(context, 'Đang xóa...');

                final nhanSuProvider = Provider.of<NhanSuProvider>(
                  context,
                  listen: false,
                );
                try {
                  await nhanSuProvider.deleteNhanVien(nv!);
                  Navigator.pop(context);
                  QuickAlertService.showAlertSuccess(context, 'Xóa thành công');
                  onRefresh();
                  Navigator.pop(context);
                } catch (e) {
                  Navigator.pop(context);
                  QuickAlertService.showAlertFailure(context, 'Xóa thất bại');
                }
              },
              child: Text('Xóa', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
            TextButton(
              onPressed: () async {
                if (nv?.ma == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailNhanSu(nhanVien: nv!),
                  ),
                ).then((_) => onRefresh());
              },
              child: Text(
                'Chỉnh sửa',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (nv == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            strokeAlign: 1,
          ),
        ),
      ),
      child: ListTile(
        onTap: () => _showDetailDialog(context),
        leading: CircleAvatar(
          backgroundImage:
          ( nv!.anh != null && nv!.anh!.isNotEmpty
              ? NetworkImage(nv!.anh!)
              : const AssetImage('assets/images/default.png')) as ImageProvider,
        ),
        title: Text(
          nv?.ten ?? 'Không có tên',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        subtitle: Text(
          nv?.vaiTro.toString() ?? '',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (nv == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailNhanSu(nhanVien: nv!),
                  ),
                ).then((_) => onRefresh());
              },
              icon: Icon(
                Icons.more_horiz_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}