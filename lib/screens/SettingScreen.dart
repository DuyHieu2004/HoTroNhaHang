import 'package:doan_nhom_cuoiky/utils/Toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/SettingProvider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: Consumer<SettingProvider>(
        builder: (context, settings, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    settings.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                    ToastUtils.showInfo(value? 'Đã bật chế độ tối' : 'Đã tắt chế độ tối');
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chọn font chữ:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: settings.fontFamily,
                  isExpanded: true,
                  items:
                      settings.availableFonts.map((font) {
                        return DropdownMenuItem<String>(
                          value: font,
                          child: Text(
                            font == 'OpenSans' ? 'Open Sans' : font,
                            style: TextStyle(fontFamily: font),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settings.changeFont(value);
                      ToastUtils.showInfo('Đã thay đổi font chữ');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
