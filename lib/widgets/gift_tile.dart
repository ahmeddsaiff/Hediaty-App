// import 'package:flutter/material.dart';
// import '../models/gift.dart';
//
// class GiftTile extends StatelessWidget {
//   final Gift gift;
//
//   GiftTile({required this.gift});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(gift.name),
//       subtitle: Text(gift.description),
//       leading: gift.imageUrl != null
//           ? Image.network(gift.imageUrl!)  // If image URL exists, show the image
//           : Icon(Icons.image),            // If no image URL, show a default icon
//       trailing: Icon(
//         gift.isPledged ? Icons.check_circle : Icons.circle,
//         color: gift.isPledged ? Colors.green : Colors.red,
//       ),
//       onTap: () {
//         // Handle the onTap action, maybe navigate to the gift details page
//       },
//     );
//   }
// }
