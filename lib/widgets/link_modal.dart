import 'package:flutter/material.dart';
import 'package:giydir_mvp2/resources/firestore_methods.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkModal extends StatelessWidget {
  final String postId;

  const LinkModal({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FireStoreMethods().getPostLinks(postId),
      builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Veri yükleniyor ise gösterilecek widget
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Hata durumunda gösterilecek widget
          return Text('Hata: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          // Veri yoksa veya null ise gösterilecek widget
          return const Text('Link bilgisi bulunamadı');
        } else {
          // Veri varsa gösterilecek widget
          Map<String, dynamic> links = snapshot.data!;
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kıyafet Detayları',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  // Kategori ve linkleri göstermek için ListView.builder kullanımı
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      var entry = links.entries.elementAt(index);
                      var category = entry.key;
                      var categoryLinks = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Kategori: $category',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Kategorinin içindeki her bir link
                          for (var link in categoryLinks)
                            GestureDetector(
                              onTap: () async {
                                print('Link tıklandı: $link');
                                await launchUrl(Uri.parse(link));
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Link: $link',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 227, 224, 224))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:  const Text('Kapat', style: TextStyle(color: Colors.black),),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
