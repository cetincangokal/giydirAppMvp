// import 'package:flutter/material.dart';
// import 'package:giydir_mvp2/screens/addPost/addPost_screen.dart';
// import 'package:giydir_mvp2/screens/addPost/categories_screen.dart/bottom.dart';
// import 'package:giydir_mvp2/screens/addPost/categories_screen.dart/charms.dart';
// import 'package:giydir_mvp2/screens/addPost/categories_screen.dart/shoes.dart';
// import 'package:giydir_mvp2/screens/addPost/categories_screen.dart/top.dart';
// import 'package:giydir_mvp2/screens/addPost/categories_screen.dart/winterW.dart';
// import 'package:giydir_mvp2/utils/colors.dart';

// class AddClothesScreen extends StatefulWidget {
//   const AddClothesScreen({super.key, this.topData});
//   final String? topData;
//   @override
//   State<AddClothesScreen> createState() => _AddClothesScreenState();
// }

// class _AddClothesScreenState extends State<AddClothesScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: mobileBackgroundColor,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             color: Colors.black,
//           ),
//           onPressed: () async {
//             Navigator.pop(
//               context,
//               widget.topData,
//             );
//             print("Top Data After Pop Clothes: ${widget.topData}");
//           },
//         ),
//         title: const Text(
//           'Clothes',
//           style: TextStyle(color: Colors.black),
//         ),
//         centerTitle: false,
//         actions: <Widget>[
//           TextButton(
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AddPostScreen(
//                     topData: widget.topData,
//                   ),
//                 ),
//               );
//               print("Top Data After Pop Clothes push: ${widget.topData}");
//             },
//             child: const Text(
//               "Add category +",
//               style: TextStyle(
//                   color: Colors.grey,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16.0),
//             ),
//           )
//         ],
//       ),
//       body: Column(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: GestureDetector(
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const TopScreen()),
//                     ),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Top',
//                           style: TextStyle(color: Colors.grey, fontSize: 15),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios,
//                           color: Colors.grey,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Divider(
//                   color: Colors.grey,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: GestureDetector(
//                     onTap: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                           builder: (context) => const BottomScreen()),
//                     ),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Bottoms',
//                           style: TextStyle(color: Colors.grey, fontSize: 15),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios,
//                           color: Colors.grey,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Divider(
//                   color: Colors.grey,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: GestureDetector(
//                     onTap: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                           builder: (context) => const ShoesScreen()),
//                     ),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Shoes',
//                           style: TextStyle(color: Colors.grey, fontSize: 15),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios,
//                           color: Colors.grey,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Divider(
//                   color: Colors.grey,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: GestureDetector(
//                     onTap: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                           builder: (context) => const WinterWScreen()),
//                     ),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Winter Wear',
//                           style: TextStyle(color: Colors.grey, fontSize: 15),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios,
//                           color: Colors.grey,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Divider(
//                   color: Colors.grey,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: GestureDetector(
//                     onTap: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                           builder: (context) => const CharmsScreen()),
//                     ),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Charms',
//                           style: TextStyle(color: Colors.grey, fontSize: 15),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios,
//                           color: Colors.grey,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Divider(
//                   color: Colors.grey,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
