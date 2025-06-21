import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan_nhom_cuoiky/models/DonDatCho.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class DonDatChoService {
  final CollectionReference _donDatChoCollection = FirebaseFirestore.instance.collection('DonDatCho');
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  DonDatChoService() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<List<DonDatCho>> getDonDatCho() async {
    QuerySnapshot snapshot = await _donDatChoCollection.get();
    return snapshot.docs.map((doc) => DonDatCho.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addDonDatCho(DonDatCho donDatCho) async {
    await _donDatChoCollection.doc(donDatCho.ma).set(donDatCho.toMap());
    if (donDatCho.ngayDat != null) {
      await _scheduleReservationNotification(donDatCho);
    }
  }

  Future<void> updateDonDatCho(DonDatCho donDatCho) async {
    await _donDatChoCollection.doc(donDatCho.ma).update(donDatCho.toMap());
    if (donDatCho.ma != null) {
      await _cancelReservationNotification(donDatCho.ma!);
      if (donDatCho.ngayDat != null) {
        await _scheduleReservationNotification(donDatCho);
      }
    }
  }

  Future<void> deleteDonDatCho(String id) async {
    await _cancelReservationNotification(id);
    await _donDatChoCollection.doc(id).delete();
  }

  Future<DonDatCho?> getDonDatChoById(String? donDatChoId) async {
    if (donDatChoId == null || donDatChoId.isEmpty) return null;
    try {
      DocumentSnapshot doc = await _donDatChoCollection.doc(donDatChoId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print("DonDatCho data fetched: $data");
        return DonDatCho.fromMap(data);
      } else {
        print("DonDatCho with ID $donDatChoId does not exist.");
      }
    } catch (e) {
      print("Lỗi khi lấy DonDatCho $donDatChoId: $e");
    }
    return null;
  }

  Future<void> _scheduleReservationNotification(DonDatCho donDatCho) async {
    if (donDatCho.ngayDat == null) return;

    final scheduledTime = tz.TZDateTime.from(
      donDatCho.ngayDat!.subtract(const Duration(minutes: 30)),
      tz.local,
    );

    final now = tz.TZDateTime.now(tz.local);
    if (scheduledTime.isBefore(now)) return;

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'reservation_channel',
      'Đơn đặt chỗ',
      channelDescription: 'Thông báo về đơn đặt chỗ',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      donDatCho.ma.hashCode,
      'Sắp có khách đặt chỗ',
      'Khách hàng ${donDatCho.tenKhachHang} sẽ đến trong 30 phút nữa. SĐT: ${donDatCho.soDienThoai}',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _cancelReservationNotification(String donDatChoId) async {
    await _flutterLocalNotificationsPlugin.cancel(donDatChoId.hashCode);
  }
}