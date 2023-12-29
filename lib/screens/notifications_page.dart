import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _saveDeviceToken();
    _configureFirebaseMessaging();
  }

  _configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // ignore: avoid_print
      print("onMessage: $message");
      // Uygulama ön planda olduğunda bildirimi işle
      _bildirimiListeyeEkle(message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // ignore: avoid_print
      print("onMessageOpenedApp: $message");
      // Uygulama, kapatıldıktan sonra bildirime tıklanınca işle
      _bildirimiListeyeEkle(message.notification?.body);
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _handleBackgroundMessage(RemoteMessage? message) async {
    // ignore: avoid_print
    print("onBackgroundMessage: $message");
    // Uygulama arka planda çalışırken bildirimi işle
    _bildirimiListeyeEkle(message!.notification?.body);
  }

  _saveDeviceToken() async {
    // Bu kısım, kullanıcı giriş yaptığında veya kaydolduğunda çağrılmalıdır.
    // Ayrıca, kullanıcının UID'sini almalısınız ve bunu Firestore'daki 'Users' koleksiyonunda saklamalısınız.
    String uid = 'jeffd23';

    // Bu cihaz için token'ı al
    String? fcmToken = await _fcm.getToken();

    // Firestore'a kaydet
    if (fcmToken != null) {
      // Token'ı ve UID'yi 'Tokens' alt koleksiyonuna kaydet
      await _fcm.subscribeToTopic(uid); // Kullanıcının kendi konusuna abone ol
    }
  }

  _bildirimiListeyeEkle(String? bildirim) {
    if (bildirim != null) {
      setState(() {
        notifications.add(bildirim);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler',
        style: TextStyle(
          color: Colors.black
        ),),
        backgroundColor: Colors.transparent, // Transparan arkaplan rengi
        elevation: 0, // Gölgeyi kaldırmak için
      ),
      body: _buildBildirimListesi(),
    );
  }

  Widget _buildBildirimListesi() {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(notifications[index]),
        );
      },
    );
  }
}
